//
//  DetailTaskCoordinator.swift
//  DOITTarasenko
//
//  Created by Valeriia Tarasenko on 02/05/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Swinject

class DetailTaskCoordinator: BaseCoordinator {
    
    var id: Int?
    var notification:UserNotification?
    var didTaskUpdate: BehaviorRelay<Void> = BehaviorRelay(value: ())
    private let newTaskCoordinator: NewTaskCoordinator
    
    override init(resolver: Resolver) {
        self.newTaskCoordinator = resolver.resolve(NewTaskCoordinator.self)!
        super.init(resolver: resolver)
    }
    
    override func start() {
        let detailTaskViewController = DetailTaskViewController.instantiate(with: "DetailTask")
        let detailTaskViewModel = DetailTaskViewModel(taskManager: taskManager, coordinator: self, didTaskUpdate: didTaskUpdate)
        detailTaskViewController.viewModel = detailTaskViewModel
        //detailTaskViewController.viewModel.didTaskUpdate = didTaskUpdate
        detailTaskViewController.viewModel.id = id
        detailTaskViewController.viewModel.notification = notification
        self.navigationController.pushViewController(detailTaskViewController, animated: true)
    }
    
    func showNewTaskViewController(task: TaskModel?, notificaion: UserNotification?, didTaskUpdate: BehaviorRelay<Void>) {
        newTaskCoordinator.navigationController = self.navigationController
        newTaskCoordinator.didTaskUpdate = didTaskUpdate
        newTaskCoordinator.task = task
        newTaskCoordinator.notificaion = notificaion
        self.start(coordinator: newTaskCoordinator)
    }
    
    func didFinishDetail() {
        parentCoordinator?.didFinish(coordinator: self)
    }
}
