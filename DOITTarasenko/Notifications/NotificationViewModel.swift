//
//  NotificationViewModel.swift
//  DOITTarasenko
//
//  Created by Valeriia Tarasenko on 04/05/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class NotificationViewModel {
    
    var notifications: BehaviorRelay<[UserNotification]> = BehaviorRelay(value: [])
    private let disposeBag = DisposeBag()
    
    private var taskManager: TaskManager
    private var notificationManager: NotificationManager
    private weak var coordinator: BaseCoordinator?
    
    var didNotificationUpdate: BehaviorRelay<Void> = BehaviorRelay(value: ())
    let getNotificationsAction = PublishSubject<Void>()
    let deleteNotificationAction = PublishSubject<Int>()
    
    init(taskManager: TaskManager, notificationManager: NotificationManager, coordinator: BaseCoordinator) {
        self.taskManager = taskManager
        self.coordinator = coordinator
        self.notificationManager = notificationManager
        
        getNotificationsAction.subscribe(onNext: { [weak self] in
            self?.getNotifications()
            }).disposed(by: disposeBag)
        
        deleteNotificationAction.subscribe(onNext: { [weak self] index in
            self?.removeNotification(index)
            }).disposed(by: disposeBag)
    }
    
    func getNotifications() {
        notificationManager.getAllNotifications() { [weak self] notifications in
            guard let `self` = self else { return }
            let newValue = self.notifications.value + notifications
            self.notifications.accept(newValue)
        }
    }
    
    func removeNotification(_ index: Int) {
        notificationManager.deleteNotification(notifications.value[index].id)
        var newValue = notifications.value//.remove(at: index)
        newValue.remove(at: index)
        notifications.accept(newValue)
    }
    
    func didFinishNotifications() {
        (coordinator as? NotificationCoordinator)?.didFinisNotifications()
    }
}
