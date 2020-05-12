//
//  Coordinator.swift
//  DOITTarasenko
//
//  Created by Valeriia Tarasenko on 01/05/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Swinject

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var parentCoordinator: Coordinator? { get set }
    var childCoordinators: [Coordinator] { get set }//from other tutorial
    
    func start()
    func start(coordinator: Coordinator)
    func didFinish(coordinator: Coordinator)
}

class BaseCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var parentCoordinator: Coordinator?
    var navigationController = UINavigationController()
    
    var window = UIWindow(frame: UIScreen.main.bounds)
    let taskManager: TaskManager!
    let notificationManager: NotificationManager!
    let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.taskManager = resolver.resolve(TaskManager.self)!
        self.notificationManager = resolver.resolve(NotificationManager.self)!
    }
    
    func start() {
        fatalError("Start method must be implemented")
    }
    
    func start(coordinator: Coordinator) {
        self.childCoordinators.append(coordinator)
        coordinator.parentCoordinator = self
        coordinator.start()
    }
    
    func didFinish(coordinator: Coordinator) {
        if let index = self.childCoordinators.firstIndex(where: { $0 === coordinator }) {
            self.childCoordinators.remove(at: index)
        }
    }
    
    func showLogin() {
        guard let signInCoordinator = resolver.resolve(SignInCoordinator.self) else {
            return
        }
        self.navigationController.navigationBar.isHidden = true
        signInCoordinator.navigationController = self.navigationController
        self.start(coordinator: signInCoordinator)
    }
    
    func showErrorMessage(_ message: String) {
        let alertController = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.navigationController.present(alertController, animated: true, completion: nil)
    }
    
    func showConfirmationAlert(title: String?,
                               message: String? = nil,
                               buttonFirstTitle: String? = "OK",
                               buttonFirstStyle: UIAlertAction.Style = .default,
                               buttonSecondTitle: String? = "Cancel",
                               buttonSecondStyle: UIAlertAction.Style = .default,
                               firstAction: (() -> Void)? = nil,
                               secondAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonFirstTitle, style: buttonFirstStyle) { _ in
            if let action = firstAction { action() }
        })
        alert.addAction(UIAlertAction(title: buttonSecondTitle, style: buttonSecondStyle) { _ in
            if let action = secondAction { action() }
        })
        self.navigationController.present(alert, animated: true, completion: nil)
    }
    
    func handleError(_ error: AppError) {
        if case AppError.expiredToken = error {
            taskManager.logout()
            showLogin()
            return
        }
        self.showErrorMessage(error.localizedDescription)
    }
}

