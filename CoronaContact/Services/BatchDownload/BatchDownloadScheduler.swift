//
//  BatchDownloadScheduler.swift
//  CoronaContact
//

import BackgroundTasks
import Foundation
import Resolver

final class BatchDownloadScheduler {
    @Injected private var localStorage: LocalStorage
    @Injected private var healthRepository: HealthRepository
    @Injected private var batchDownloadService: BatchDownloadService
    @Injected private var riskCalculationController: RiskCalculationController

    weak var exposureManager: ExposureManager?

    private let log = ContextLogger(context: .batchDownload)
    private let backgroundTaskIdentifier = Bundle.main.bundleIdentifier! + ".exposure-notification"
    private let backgroundTaskScheduler = BGTaskScheduler.shared

    private func startBatchDownload(_ task: BGTask) -> Progress {
        let downloadRequirement = determineDownloadRequirement()
        let progress = batchDownloadService.startBatchDownload(downloadRequirement) { result in
            switch result {
            case let .success(batches):
                self.riskCalculationController.processBatches(batches, completionHandler: self.handleRiskCalculationResult)
                self.log.debug("Successfully completed the background batch download task.")
                task.setTaskCompleted(success: true)
                self.localStorage.batchDownloadSchedulerResult = BatchDownloadSchedulerResult(task: task, error: nil).description
            case let .failure(error):
                task.setTaskCompleted(success: false)
                self.log.error("Failed to complete the background batch download task due to an error: \(error).")
                self.localStorage.batchDownloadSchedulerResult = BatchDownloadSchedulerResult(task: task, error: .download(error)).description
            }
        }
        return progress
    }

    func registerBackgroundTask() {
        backgroundTaskScheduler.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: .main) { task in

            self.log.debug("Starting background batch download task.")

            // Schedule the next background task
            self.scheduleBackgroundTaskIfNeeded()

            if let lastTime = self.timeSinceLastBatchProcessing(), lastTime < BatchDownloadConfiguration.taskCooldownTime {
                self.log.debug("Skipping batch processing background task, because it already happened \(Int(lastTime / 60)) minutes ago.")
                self.localStorage.batchDownloadSchedulerResult = "\(Date()): Cancelled because done \(Int(lastTime / 60)) minutes ago."
                task.setTaskCompleted(success: true)
                return
            }

            let progress = self.startBatchDownload(task)

            // Handle running out of time
            task.expirationHandler = {
                progress.cancel()
                self.log.error("Failed to complete the background batch download task, because the task ran out of time.")
                self.localStorage.batchDownloadSchedulerResult = BatchDownloadSchedulerResult(task: task, error: .backgroundTimeout).description
                task.setTaskCompleted(success: false)
            }
        }

        scheduleBackgroundTaskIfNeeded()
    }

    private func timeSinceLastBatchProcessing() -> TimeInterval? {
        guard let performedBatchProcessingAt = localStorage.performedBatchProcessingAt else {
            return nil
        }

        return Date().timeIntervalSince1970 - performedBatchProcessingAt.timeIntervalSince1970
    }

    private func determineDownloadRequirement() -> BatchDownloadService.DownloadRequirement {
        switch healthRepository.userHealthStatus {
        case .isHealthy:
            return .sevenDaysBatchAndDailyBatches
        case .hasAttestedSickness, .isProbablySick, .isUnderSelfMonitoring:
            return .onlyFourteenDaysBatch
        }
    }

    private func handleRiskCalculationResult(_ result: Result<RiskCalculationResult, RiskCalculationError>) {
        if case let .success(riskResult) = result {
            log.debug("Passing the risk calculation result to the quarantine time controller.")
            localStorage.performedBatchProcessingAt = Date()
            localStorage.performedBatchProcessingDates.managingBatchProcessingDates(insert: Date())
            QuarantineTimeController.quarantineTimeCalculation(riskResult: riskResult)
        }

        batchDownloadService.removeBatches()
    }

    func scheduleBackgroundTaskIfNeeded() {
        guard exposureManager?.authorizationStatus == .authorized else {
            return
        }

        backgroundTaskScheduler.getPendingTaskRequests { pendingRequests in
            self.log.debug("Pending task requests: \(pendingRequests)")
            if pendingRequests.isEmpty {
                self.scheduleBackgroundTask(at: self.nextDateToSchedule())
            }
        }
    }

    private func nextDateToSchedule() -> Date {
        let config = BatchDownloadConfiguration.Scheduler.self
        var dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
        dateComponents.minute = config.startTime.minute
        var nextRunDate = dateComponents.date!
        while true {
            let hour = Calendar.current.component(.hour, from: nextRunDate)
            if hour >= config.startTime.hour,
                hour <= config.lastRunHour,
                nextRunDate > Date()
            {
                break
            }
            nextRunDate = Calendar.current.date(byAdding: .hour, value: config.intervalInHours, to: nextRunDate)!
        }
        return nextRunDate
    }

    private func scheduleBackgroundTask(at date: Date) {
        let taskRequest = BGProcessingTaskRequest(identifier: backgroundTaskIdentifier)
        taskRequest.earliestBeginDate = date
        taskRequest.requiresNetworkConnectivity = true

        do {
            try backgroundTaskScheduler.submit(taskRequest)
            log.debug("Successfully scheduled background batch download task at date \(date): \(backgroundTaskIdentifier)")
        } catch {
            log.error("Failed to schedule background batch download task: \(error)")
        }
    }

    #if DEBUG
        func scheduleBackgroundTaskForDebuggingPurposes() {
            backgroundTaskScheduler.cancelAllTaskRequests()
            let oneMinuteFromNow = Date(timeIntervalSinceNow: 60)
            scheduleBackgroundTask(at: oneMinuteFromNow)
        }
    #endif
}
