//
//  DetailTaskViewModel.swift
//  DOITTarasenko
//
//  Created by Valeriia Tarasenko on 30/04/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class DetailTaskViewModel {
    
    private var taskManager: TaskManager
    private let disposeBag = DisposeBag()
    private weak var coordinator: BaseCoordinator?
    
    var task: TaskModel?
    var id: Int?
    var notification: UserNotification?
    // events
    let didGetTask = PublishSubject<TaskModel>()
    let didDeleteTask = PublishSubject<Void>()
    let didTaskUpdate: BehaviorRelay<Void>
    
    let getTaskInfo = PublishSubject<Void>()
    let updateTaskInfo = PublishSubject<Void>()
    let deleteTaskInfo = PublishSubject<Void>()

    init(taskManager: TaskManager, coordinator: BaseCoordinator, didTaskUpdate: BehaviorRelay<Void>) {
        self.taskManager = taskManager
        self.coordinator = coordinator
        self.didTaskUpdate = didTaskUpdate
        
        getTaskInfo.subscribe(onNext: { [weak self] in
            self?.getTaskDetail()
            }).disposed(by: disposeBag)
        
        updateTaskInfo.subscribe(onNext: { [weak self] in
            self?.editTask()
            }).disposed(by: disposeBag)
        
        deleteTaskInfo.subscribe(onNext: { [weak self] in
            self?.deleteTask()
            }).disposed(by: disposeBag)
        
        didTaskUpdate.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.getTaskDetail()
            }).disposed(by: disposeBag)
    }
    
    func getTaskDetail() {
        guard let id = id else { return }
        taskManager.detailTask(id: id)
        .subscribe(onNext: { task in
                self.task = task
                self.didGetTask.onNext(task)
            }, onError: { error in
                guard let appError = error as? AppError,
                !appError.localizedDescription.contains("No query results for model") else { return }
                self.coordinator?.handleError(appError)
        }).disposed(by: disposeBag)
    }
    
    func deleteTask() {
        coordinator?.showConfirmationAlert(title: nil,
            message: "Do you want to delete task?",
            firstAction: {
                guard let id = self.id else { return }
                self.taskManager.deleteTask(id: id)
                .subscribe(onNext: { _ in
                    self.coordinator?.notificationManager.deleteNotification(id)
                    self.didTaskUpdate.accept(())
                    self.didDeleteTask.onNext(())
                }, onError: { error in
                    guard let appError = error as? AppError else { return }
                    self.coordinator?.handleError(appError)
                }).disposed(by: self.disposeBag)
            })
    }
    
    func editTask() {
        (coordinator as? DetailTaskCoordinator)?.showNewTaskViewController(task: task, notificaion: notification, didTaskUpdate: didTaskUpdate)
    }
    
    func didFinishDetail() {
        (coordinator as? DetailTaskCoordinator)?.didFinishDetail()
    }
}
