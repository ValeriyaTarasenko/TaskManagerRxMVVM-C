//
//  AppDelegate.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/11/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let container = DIContainer.defaultResolver
        container.register(UserManager.self) { _ in UserManagerImplementation() }
             .inObjectScope(.container)
        container.register(TaskManager.self) { TaskManagerImplementation(resolver: $0) }
        container.register(NotificationManager.self) { NotificationManagerImplementation(resolver: $0) }
        
        container.register(AppCoordinator.self) { AppCoordinator(resolver: $0) }
            .inObjectScope(.container)
        container.register(SignInCoordinator.self) { SignInCoordinator(resolver: $0) }
            .inObjectScope(.container)
        container.register(TasksListCoordinator.self) { TasksListCoordinator(resolver: $0) }
            .inObjectScope(.container)
        container.register(DetailTaskCoordinator.self) { DetailTaskCoordinator(resolver: $0) }
            .inObjectScope(.container)
        container.register(NewTaskCoordinator.self) { NewTaskCoordinator(resolver: $0) }
            .inObjectScope(.container)
        container.register(NotificationCoordinator.self) { NotificationCoordinator(resolver: $0) }
            .inObjectScope(.container)
        container.register(SettingsCoordinator.self) { SettingsCoordinator(resolver: $0) }
            .inObjectScope(.container)
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (_, _) in}
        let appCoordinator = container.resolve(AppCoordinator.self)
        appCoordinator?.start()

        return true
    }
}

