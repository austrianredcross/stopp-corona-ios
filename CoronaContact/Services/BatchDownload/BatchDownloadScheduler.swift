//
//  BatchDownloadScheduler.swift
//  CoronaContact
//

import BackgroundTasks
import Foundation
import Resolver

final class BatchDownloadScheduler {
    struct Timing {
        private let startDate: Date
        private let endDate: Date
        private let dateInterval: DateInterval
        private let datesToSchedule: [Date]

        var nextDateToSchedule: Date? {
            datesToSchedule.first { $0 > Date() }
        }

        init() {
            startDate = Calendar.current.date(
                bySettingHour: BatchDownloadConfiguration.Scheduler.startTime.hour,
                minute: BatchDownloadConfiguration.Scheduler.startTime.minute,
                second: 0,
                of: Date()
            )!
            endDate = Calendar.current.date(
                bySettingHour: BatchDownloadConfiguration.Scheduler.endTime.hour,
                minute: BatchDownloadConfiguration.Scheduler.endTime.minute,
                second: 0,
                of: Date()
            )!
            dateInterval = DateInterval(start: startDate, end: endDate)
            datesToSchedule = dateInterval.divide(
                by: .hour,
                value: BatchDownloadConfiguration.Scheduler.intervalInHours
            )
        }
    }

    @Injected private var localStorage: LocalStorage
    @Injected private var healthRepository: HealthRepository
    @Injected private var batchDownloadService: BatchDownloadService

    weak var exposureManager: ExposureManager?

    private let log = ContextLogger(context: .batchDownload)
    private let backgroundTaskIdentifier = Bundle.main.bundleIdentifier! + ".exposure-notification"
    private let backgroundTaskScheduler = BGTaskScheduler.shared
    private let timing = Timing()

    func registerBackgroundTask() {
        backgroundTaskScheduler.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: .main) { task in
            let downloadRequirement = self.determineDownloadRequirement()

            let progress = self.batchDownloadService.startBatchDownload(downloadRequirement) { result in
                switch result {
                case .success:
                    task.setTaskCompleted(success: true)
                    self.localStorage.batchDownloadSchedulerResult = BatchDownloadSchedulerResult(task: task, error: nil).description
                case let .failure(error):
                    task.setTaskCompleted(success: false)
                    self.localStorage.batchDownloadSchedulerResult = BatchDownloadSchedulerResult(task: task, error: .download(error)).description
                }
            }

            // Handle running out of time
            task.expirationHandler = {
                progress.cancel()
                self.localStorage.batchDownloadSchedulerResult = BatchDownloadSchedulerResult(task: task, error: .backgroundTimeout).description
            }

            // Schedule the next background task
            self.scheduleBackgroundTaskIfNeeded()
        }

        scheduleBackgroundTaskIfNeeded()
    }

    func determineDownloadRequirement() -> BatchDownloadService.DownloadRequirement {
        switch healthRepository.userHealthStatus {
        case .isHealthy:
            return .sevenDaysBatchAndDailyBatches
        case .hasAttestedSickness, .isProbablySick, .isUnderSelfMonitoring:
            return .onlyFourteenDaysBatch
        }
    }

    func scheduleBackgroundTaskIfNeeded() {
        guard exposureManager?.authorizationStatus == .authorized else {
            return
        }

        backgroundTaskScheduler.getPendingTaskRequests { pendingRequests in
            guard pendingRequests.isEmpty else {
                return
            }

            if let nextScheduledDate = self.timing.nextDateToSchedule {
                self.scheduleBackgroundTask(at: nextScheduledDate)
            }
        }
    }

    private func scheduleBackgroundTask(at date: Date) {
        let taskRequest = BGProcessingTaskRequest(identifier: backgroundTaskIdentifier)
        taskRequest.earliestBeginDate = date
        taskRequest.requiresNetworkConnectivity = true

        do {
            try backgroundTaskScheduler.submit(taskRequest)
            log.debug("Background task at date \(date) scheduled: \(backgroundTaskIdentifier)")
        } catch {
            log.error("Unable to schedule background task: \(error)")
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

private extension DateInterval {
    func divide(by component: Calendar.Component, value divisor: Int) -> [Date] {
        var dates: [Date] = [start]

        var previousDate = start
        while let nextDate = Calendar.current.date(byAdding: component, value: divisor, to: previousDate),
            contains(nextDate) {
            dates.append(nextDate)
            previousDate = nextDate
        }

        return dates
    }
}
