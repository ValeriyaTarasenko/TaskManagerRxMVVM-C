//
//  NewTaskCoordinator.swift
//  DOITTarasenko
//
//  Created by Valeriia Tarasenko on 04/05/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class NewTaskCoordinator: BaseCoordinator {
    
    var task: TaskModel?
    var notificaion: UserNotification?
    var didTaskUpdate: BehaviorRelay<Void> = BehaviorRelay(value: ())
    
    override func start() {
        let newTaskViewController = NewTaskViewController.instantiate(with: "EditTask")
        let newTaskViewModel = NewTaskViewModel(taskManager: taskManager,
                                                notificationManager: notificationManager,
                                                coordinator: self)
        newTaskViewController.viewModel = newTaskViewModel
        newTaskViewController.viewModel.didTaskUpdate = didTaskUpdate
        newTaskViewController.viewModel.task = task
        newTaskViewController.viewModel.notification = notificaion
        self.navigationController.pushViewController(newTaskViewController, animated: true)
    }
}
