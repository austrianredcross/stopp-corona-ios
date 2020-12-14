//
//  AppDelegate.swift
//  CoronaContact
//

import BackgroundTasks
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

    private var servicesInitialized: Bool = false

    @Injected private var configService: ConfigurationService
    @Injected private var appUpdateService: AppUpdateService
    @Injected private var notificationService: NotificationService
    @Injected private var databaseService: DatabaseService
    @Injected private var healthRepository: HealthRepository
    @Injected private var localStorage: LocalStorage
    @Injected private var exposureManager: ExposureManager
    @Injected private var batchDownloadScheduler: BatchDownloadScheduler
    @Injected private var appStartBatchController: AppStartBatchController

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
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        registerFontStyles()
        styleNavigationBar()

        log.info("Application starting with launchOptions: \(String(describing: launchOptions))")

        appUpdateService.performMaintenanceTasks()
        batchDownloadScheduler.registerBackgroundTask()

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
        guard servicesInitialized == false else {
            return
        }
        configService.update()
        servicesInitialized = true
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        LoggingService.error("Unable to register for remote notifications: \(error.localizedDescription)",
                             context: .application)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        appUpdateService.showUpdateAlertIfNecessary()
        if localStorage.hasSeenOnboarding {
            appStartBatchController.startBatchProcessing()
        }
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

// MARK: Deep Link

extension AppDelegate {
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if url.scheme == DeepLinkConstants.deepLinkScheme && url.host == DeepLinkConstants.deepLinkHost {
            
            let path = url.path
            let correctPath = String(path.dropFirst())
            
            switch correctPath {
            case Website.termsOfUse.rawValue:
                appCoordinator.openWebView(websiteType: .termsOfUse)
            case Website.privacy.rawValue:
                appCoordinator.openWebView(websiteType: .privacy)
            default:
                log.error("Error while trying to open a webview with path: \(correctPath)")
            }
        }
        
        return true
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
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold),
        ]
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void)
    {
        if response.notification.request.identifier == NotificationServiceKeys.selfTestPush {
            appCoordinator?.startSelfTestExternally()
        }
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .sound])
    }
}
