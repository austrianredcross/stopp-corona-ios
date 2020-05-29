//
//  AppDelegate.swift
//  CoronaContact
//

import BackgroundTasks
import Firebase
import Lottie
import Resolver
import UIKit
import UserNotifications

enum ScreenSize {
    case small, medium, large
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var appCoordinator: ApplicationCoordinator!
    let log = ContextLogger(context: .application)
    private var observers = [NSObjectProtocol]()

    private var serivcesInitialized: Bool = false

    @Injected private var configService: ConfigurationService
    @Injected private var appUpdateService: AppUpdateService
    @Injected private var notificationService: NotificationService
    @Injected private var databaseService: DatabaseService
    @Injected private var healthRepository: HealthRepository
    @Injected private var localStorage: LocalStorage
    @Injected private var exposureManager: ExposureManager

    lazy var screenSize: ScreenSize = {
        let width = UIScreen.main.bounds.size.width
        if width >= 414 {
            return .large
        } else if width >= 375 {
            return .medium
        }
        return .small
    }()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerFontStyles()
        styleNavigationBar()

        log.info("Application starting with launchOptions: \(String(describing: launchOptions))")

        appUpdateService.cleanupOldData()
        registerBackgroundTask()

        UNUserNotificationCenter.current().delegate = self

        window = UIWindow(frame: UIScreen.main.bounds)
        appCoordinator = ApplicationCoordinator(window: window)
        appCoordinator.start()


        if localStorage.hasSeenOnboarding {
            initializeExternalServices(application)
        } else {
            observers.append(localStorage.$hasSeenOnboarding.addObserver { [unowned self] in
                self.initializeExternalServices(application)
            })
        }

        return true
    }

    func initializeExternalServices(_ application: UIApplication) {
        guard serivcesInitialized == false else {
            return
        }

        configService.update()

        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        serivcesInitialized = true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // TODO: what should happen on push notification?
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        LoggingService.error("Unable to register for remote notifications: \(error.localizedDescription)",
                             context: .application)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        appUpdateService.showUpdateAlertIfNecessary()
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

// MARK: exposure notification background task

@available(iOS 13.5, *)
extension AppDelegate {
    static let backgroundTaskIdentifier = Bundle.main.bundleIdentifier! + ".exposure-notification"

    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: AppDelegate.backgroundTaskIdentifier, using: .main) { task in

            // Perform the exposure detection
            let progress = self.exposureManager.detectExposures { success in
                task.setTaskCompleted(success: success)
            }

            // Handle running out of time
            task.expirationHandler = {
                progress.cancel()
                // LocalStore.shared.exposureDetectionErrorLocalizedDescription = NSLocalizedString("BACKGROUND_TIMEOUT", comment: "Error")
            }

            // Schedule the next background task
            self.scheduleBackgroundTaskIfNeeded()
        }

        scheduleBackgroundTaskIfNeeded()
    }

    func scheduleBackgroundTaskIfNeeded() {
        guard exposureManager.authorizationStatus == .authorized else {
            return
        }
        let taskRequest = BGProcessingTaskRequest(identifier: AppDelegate.backgroundTaskIdentifier)
        taskRequest.requiresNetworkConnectivity = true
        do {
            try BGTaskScheduler.shared.submit(taskRequest)
            log.debug("background task scheduled \(AppDelegate.backgroundTaskIdentifier)")
        } catch {
            log.error("Unable to schedule background task: \(error)")
        }
    }
}

// MARK: Messaging

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        Messaging.messaging().subscribe(toTopic: "all")
    }
}

// MARK: Styling

extension AppDelegate {
    func styleNavigationBar() {
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.barTintColor = .white
        navigationBarAppearace.isTranslucent = false
        navigationBarAppearace.setBackgroundImage(UIImage(), for: .default)
        navigationBarAppearace.shadowImage = UIImage()
        navigationBarAppearace.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler
                                completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == NotificationServiceKeys.selfTestPush {
            appCoordinator?.startSelfTestExternally()
        }
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler
                                completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
