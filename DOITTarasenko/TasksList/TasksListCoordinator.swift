//
//  TasksListCootdinator.swift
//  DOITTarasenko
//
//  Created by Valeriia Tarasenko on 02/05/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Swinject

class TasksListCoordinator: BaseCoordinator {
    
    private let detailTaskCoordinator: DetailTaskCoordinator
    private let newTaskCoordinator: NewTaskCoordinator
    private let notificationCoordinator: NotificationCoordinator
    private let settingsCoordinator: SettingsCoordinator
    
    override init(resolver: Resolver) {
        self.detailTaskCoordinator = resolver.resolve(DetailTaskCoordinator.self)!
        self.newTaskCoordinator = resolver.resolve(NewTaskCoordinator.self)!
        self.notificationCoordinator = resolver.resolve(NotificationCoordinator.self)!
        self.settingsCoordinator = resolver.resolve(SettingsCoordinator.self)!
        super.init(resolver: resolver)
    }

    override func start() {
        let taskListViewController = TaskListViewController.instantiate(with: "TasksList")
        let taskListViewModel = TaskListViewModel(taskManager: taskManager,
                                                  notificationManager: notificationManager,
                                                  coordinator: self)
        taskListViewController.viewModel = taskListViewModel
        self.navigationController.navigationBar.isHidden = false
        self.navigationController.viewControllers = [taskListViewController]
    }
    
    func showDetailTaskViewController(_ id: Int, notification: UserNotification?, didTaskUpdate: BehaviorRelay<Void>) {
        detailTaskCoordinator.navigationController = self.navigationController
        detailTaskCoordinator.id = id
        detailTaskCoordinator.notification = notification
        detailTaskCoordinator.didTaskUpdate = didTaskUpdate
        self.start(coordinator: detailTaskCoordinator)
    }
    
    func showNewTaskViewController(didTaskUpdate: BehaviorRelay<Void>) {
        newTaskCoordinator.navigationController = self.navigationController
        newTaskCoordinator.didTaskUpdate = didTaskUpdate
        self.start(coordinator: newTaskCoordinator)
    }
    
    func showNotificationViewController(didNotificationUpdate: BehaviorRelay<Void>) {
        notificationCoordinator.navigationController = self.navigationController
        notificationCoordinator.didNotificationUpdate = didNotificationUpdate
        self.start(coordinator: notificationCoordinator)
    }
    
    func showSettingsViewController() {
        settingsCoordinator.navigationController = self.navigationController
        self.start(coordinator: settingsCoordinator)
    }
}
