//
//  SignInCoordinator.swift
//  DOITTarasenko
//
//  Created by Valeriia Tarasenko on 02/05/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import RxSwift
import Swinject

//protocol SignInListener {
//    func didSignIn()
//}

class SignInCoordinator: BaseCoordinator {

    private let disposeBag = DisposeBag()
    
    private let tasksListCoordinator: TasksListCoordinator
    
    override init(resolver: Resolver) {
        self.tasksListCoordinator = resolver.resolve(TasksListCoordinator.self)!
        super.init(resolver: resolver)
    }

    override func start() {
        let loginViewController = LoginViewController.instantiate(with: "Main")
        let loginViewModel = LoginViewModel(userManager: DIContainer.defaultResolver.resolve(UserManager.self)!,
                                            coordinator: self)
        loginViewController.viewModel = loginViewModel
        loginViewController.coordinator = self

        self.navigationController.viewControllers = [loginViewController]
    }
    
    func showTasksViewController() {
        tasksListCoordinator.navigationController = self.navigationController
        self.start(coordinator: tasksListCoordinator)
    }
}
