//
//  TaskListViewModel.swift
//  DOITTarasenko
//
//  Created by Valeriia Tarasenko on 25/04/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TaskListViewModel {
    var tasks: BehaviorRelay<[TaskModel]> = BehaviorRelay(value: [])
    private var notifications = [UserNotification]()
    private var taskMeta: TaskMeta?
    private let disposeBag = DisposeBag()
    private var sort = SortingTask.nameUp
    
    // events
    let didGetTasks = PublishSubject<Void>()
    let didFail = PublishSubject<Void>()
    let didTaskUpdate: BehaviorRelay<Void> = BehaviorRelay(value: ())
    let didNotificationUpdate: BehaviorRelay<Void> = BehaviorRelay(value: ())
    let showDetailAction = PublishSubject<Int>()
    let showNotificationAction = PublishSubject<Void>()
    let showSettingsAction = PublishSubject<Void>()
    let addTaskAction = PublishSubject<Void>()
    let sortSelected = PublishSubject<Int>()
    let updateList = PublishSubject<Void>()
    let updateNewPage = PublishSubject<Int>()
    
    private var taskManager: TaskManager
    private var notificationManager: NotificationManager
    private weak var coordinator: BaseCoordinator?
    
    init(taskManager: TaskManager, notificationManager: NotificationManager, coordinator: BaseCoordinator) {
        self.taskManager = taskManager
        self.coordinator = coordinator
        self.notificationManager = notificationManager
        
        self.sort = getSettings()
        
        showDetailAction.subscribe(onNext: { [weak self] id in
            self?.showDetailTask(id)
        }).disposed(by: disposeBag)
        
        addTaskAction.subscribe(onNext: { [weak self] _ in
            self?.addNewTask()
        }).disposed(by: disposeBag)
        
        sortSelected.subscribe(onNext: { [weak self] index in
            if SortingTask.allCases.indices.contains(index) {
                self?.sort = SortingTask.allCases[index]
            }
            self?.getTasks(page: 1)
        }).disposed(by: disposeBag)
        
        updateList.subscribe(onNext: { [weak self] _ in
            self?.getTasks(page: 1)
        }).disposed(by: disposeBag)
        
        updateNewPage.subscribe(onNext: { [weak self] index in
            self?.updateNewPage(index)
            }).disposed(by: disposeBag)
        
        showNotificationAction.subscribe(onNext: { [weak self] _ in
            self?.showNotifications()
            }).disposed(by: disposeBag)
        
        showSettingsAction.subscribe(onNext: { [weak self] _ in
            self?.showSettings()
            }).disposed(by: disposeBag)
        
        didTaskUpdate.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.getTasks(page: 1)
            }).disposed(by: disposeBag)
        
        didNotificationUpdate.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.getNotifications()
            }).disposed(by: disposeBag)

    }
    
    private func getTasks(page: Int) {
        taskManager.getTasks(page: page, sort: sort.rawValue)
        .subscribe(onNext: { [weak self] taskContainer in
            guard let `self` = self else { return }
            self.taskMeta = taskContainer.meta
            if page == 1 {
                self.tasks.accept([])
                self.getNotifications()
            }
            let newValue = self.tasks.value + taskContainer.tasks
            self.tasks.accept(newValue)
            self.didGetTasks.onNext(())
        }, onError: { error in
            self.didFail.onNext(())
            guard let appError = error as? AppError else { return }
            self.coordinator?.handleError(appError)
        }).disposed(by: disposeBag)
    }
    
    private func updateNewPage(_ index: Int) {
        if index == tasks.value.count - 1,
            let currentPage = taskMeta?.current,
            let meta = taskMeta,
            (meta.count/meta.limit + 1) > currentPage {
            getTasks(page: currentPage + 1)
        }
    }
    
    private func getNotifications(){
        notificationManager.getAllNotifications() { [weak self] notifications in
            guard let `self` = self else { return }
            self.notifications = notifications
        }
    }
    
    private func getSettings() -> SortingTask {
        return taskManager.receiveSettings()
    }
    
    private func showDetailTask(_ id: Int) {
        (coordinator as? TasksListCoordinator)?.showDetailTaskViewController(id, notification: notificationForTask(id), didTaskUpdate: didTaskUpdate)
    }
    
    private func addNewTask() {
        (coordinator as? TasksListCoordinator)?.showNewTaskViewController(didTaskUpdate: didTaskUpdate)
    }
    
    private func showNotifications() {
        (coordinator as? TasksListCoordinator)?.showNotificationViewController(didNotificationUpdate: didNotificationUpdate)
    }
    
    private func showSettings() {
       (coordinator as? TasksListCoordinator)?.showSettingsViewController()
    }
    
    private func notificationForTask(_ id: Int) -> UserNotification? {
        return notifications.first(where: {$0.id == id})
    }
}
