//
//  NotificationCoordinator.swift
//  DOITTarasenko
//
//  Created by Valeriia Tarasenko on 04/05/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class NotificationCoordinator: BaseCoordinator {
    
    var didNotificationUpdate: BehaviorRelay<Void> = BehaviorRelay(value: ())
    
    override func start() {
        let notificationsViewController = NotificationsViewController.instantiate(with: "UserNotifications")
        let notificationViewModel = NotificationViewModel(taskManager: taskManager,
                                                          notificationManager: notificationManager,
                                                          coordinator: self)
        notificationsViewController.viewModel = notificationViewModel
        notificationsViewController.viewModel?.didNotificationUpdate = didNotificationUpdate

        self.navigationController.pushViewController(notificationsViewController, animated: true)
    }
    
    func didFinisNotifications() {
        parentCoordinator?.didFinish(coordinator: self)
    }
}
