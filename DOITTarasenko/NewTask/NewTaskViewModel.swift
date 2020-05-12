//
//  NewTaskViewModel.swift
//  DOITTarasenko
//
//  Created by Valeriia Tarasenko on 26/04/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class NewTaskViewModel {
    
    private var taskManager: TaskManager
    private var notificationManager: NotificationManager
    private let disposeBag = DisposeBag()
    private weak var coordinator: BaseCoordinator?
    
    var task: TaskModel?
    var notification: UserNotification?
    
    let title = BehaviorSubject(value: "")
    private var priority: TaskModel.Priority = .low
    private var dateInterval: TimeInterval?
    private var notificationDate: TimeInterval?
    
    // events
    let didAddTask = PublishSubject<Void>()
    let didDeleteTask = PublishSubject<Void>()
    var didTaskUpdate: BehaviorRelay<Void> = BehaviorRelay(value: ())
    let updateTaskInfo = PublishSubject<Void>()
    let didGetTask = PublishSubject<TaskModel>()
    
    let updateDatePicker = PublishSubject<Date>()
    let updateDateNotificationPicker = PublishSubject<Date>()
    let priorityAction = PublishSubject<TaskModel.Priority>()
    let saveAction = PublishSubject<Void>()
    let deleteNotificationAction = PublishSubject<Void>()
    let deleteAction = PublishSubject<Void>()

    init(taskManager: TaskManager, notificationManager: NotificationManager, coordinator: BaseCoordinator) {
        self.taskManager = taskManager
        self.coordinator = coordinator
        self.notificationManager = notificationManager
        
        updateTaskInfo.subscribe(onNext: { [weak self] in
            guard let `self` = self, let task = self.task else { return }
            task.notification = self.notification
            self.setup(task)
            self.didGetTask.onNext(task)
        }).disposed(by: disposeBag)
        
        updateDatePicker.subscribe(onNext: { [weak self] date in
            self?.dateInterval = date.timeIntervalSince1970
        }).disposed(by: disposeBag)
        
        updateDateNotificationPicker.subscribe(onNext: { [weak self] date in
            self?.notificationDate = date.timeIntervalSince1970
        }).disposed(by: disposeBag)
        
        priorityAction.subscribe(onNext: { [weak self] priority in
            self?.priority = priority
        }).disposed(by: disposeBag)
        
        saveAction.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.title.take(1).subscribe(onNext: { description in
                guard !description.isEmpty,
                    let _ = self.dateInterval else {
                        self.coordinator?.showErrorMessage("Please, fill all fields")
                        return
                }
                _ = self.task == nil ? self.createTask(description) : self.updateTask(description)
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        deleteNotificationAction.subscribe(onNext: { [weak self] in
            self?.notificationDate = nil
        }).disposed(by: disposeBag)
        
        deleteAction.subscribe(onNext: { [weak self] in
            self?.coordinator?.showConfirmationAlert(title: nil,
                                 message: "Do you want to delete task?",
                                 firstAction: {
            guard let task = self?.task else { return }
            self?.deleteTask(id: task.id)
            })
        }).disposed(by: disposeBag)
        
    }
    
    func setup(_ task: TaskModel) {
        priority = task.priorityValue
        dateInterval = task.dueBy
        notificationDate = task.notification?.dateInterval
    }

    func createTask(_ description: String) {
        guard let dateInterval = self.dateInterval else { return }
        let task = TaskModel(id: 0, title: description, priority: self.priority.rawValue, dueBy: dateInterval)
        taskManager.addTask(task: task)
        .subscribe(onNext: { taskModel in
            if let notificationDate = self.notificationDate {
                let notification = UserNotification(id: taskModel.id, body: task.title, dateInterval: notificationDate)
                self.notificationManager.newNotification(notification)
            }
            self.didAddTask.onNext(())
            self.didTaskUpdate.accept(())
        }, onError: { error in
            guard let appError = error as? AppError else { return }
            self.coordinator?.handleError(appError)
        }).disposed(by: disposeBag)
    }
    
    func deleteTask(id: Int) {
        taskManager.deleteTask(id: id)
        .subscribe(onNext: { _ in
                self.notificationManager.deleteNotification(id)
                self.didDeleteTask.onNext(())
                self.didTaskUpdate.accept(())
            }, onError: { error in
                guard let appError = error as? AppError else { return }
                self.coordinator?.handleError(appError)
        }).disposed(by: disposeBag)
    }
    
    func updateTask(_ description: String) {
        guard let task = self.task, let dateInterval = self.dateInterval else { return }
        task.title = description
        task.dueBy = dateInterval
        task.updatePriority(self.priority)
        taskManager.updateTask(task: task)
            .subscribe(onNext: { _ in
                if let notificationDate = self.notificationDate {
                    let notification = UserNotification(id: task.id, body: task.title, dateInterval: notificationDate)
                    self.notificationManager.deleteNotification(task.id)
                    self.notificationManager.newNotification(notification)
                }
                self.didTaskUpdate.accept(())
                self.didAddTask.onNext(())
            }, onError: { error in
                guard let appError = error as? AppError else { return }
                self.coordinator?.handleError(appError)
            }).disposed(by: disposeBag)
    }
}
