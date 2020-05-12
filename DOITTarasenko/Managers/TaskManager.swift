//
//  TaskManager.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/12/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import Swinject
import SwiftKeychainWrapper
import RxSwift
import RxCocoa

protocol TaskManager {
    func getTasks(page: Int, sort: String) -> Observable<TaskContainer>
    func addTask(task: TaskModel) -> Observable<TaskModel>
    func detailTask(id: Int) -> Observable<TaskModel>
    func deleteTask(id: Int) -> Observable<Void>
    func updateTask(task: TaskModel) -> Observable<Void>
    func logout()
    func saveSettings(_ sort: SortingTask)
    func receiveSettings() -> SortingTask
}

class TaskManagerImplementation: TaskManager {
    private var userManager: UserManager
    private let disposeBag = DisposeBag()
//    private struct TaskDecode: Codable {
//        let task: TaskModel
//    }
    
    private struct Constans {
        static var sorting = "sorting"
    }
    
    init(userManager: UserManager) {
        self.userManager = userManager
    }
    
    convenience init(resolver: Resolver) {
        let userManager = resolver.resolve(UserManager.self)!
        self.init(userManager: userManager)
    }
    
    func getTasks(page: Int, sort: String) -> Observable<TaskContainer> {
        guard let user = userManager.user else { return Observable.error(AppError.noToken) }
        return RequestsProvider.rx
            .request(.tasks(user.token, page, sort))
            .map { result -> TaskContainer in
                if let error = self.userManager.handleApiError(data: result.data) {
                    throw error
                }
                let taskContainer = try TaskContainer.decode(data: result.data)
                return taskContainer
            }.asObservable()
    }
    
    func addTask(task: TaskModel) -> Observable<TaskModel> {
        guard let user = userManager.user else { return Observable.error(AppError.noToken)}
        return RequestsProvider.rx
            .request(.newTasks(user.token, task))
            .map { result -> TaskModel in
                if let error = self.userManager.handleApiError(data: result.data) {
                    throw error
                }
                let taskDecode = try TaskDecode.decode(data: result.data)
                return taskDecode.task
        }.asObservable()
            
    }
    
    func detailTask(id: Int) -> Observable<TaskModel> {
        guard let user = userManager.user else { return Observable.error(AppError.noToken)}
        return RequestsProvider.rx
            .request(.detailTask(user.token, id))
            .map { result -> TaskModel in
                if let error = self.userManager.handleApiError(data: result.data) {
                    throw error
                }
                let taskDecode = try TaskDecode.decode(data: result.data)
                return taskDecode.task}
            .asObservable()
    }
    
    func deleteTask(id: Int) -> Observable<Void> {
        guard let user = userManager.user else { return Observable.error(AppError.noToken)}
        return RequestsProvider.rx
            .request(.deleteTask(user.token, id))
            .map({result -> Void in
                if let error = self.userManager.handleApiError(data: result.data) {
                    throw error
                }
                return Void()}).asObservable()
    }
    
    func updateTask(task: TaskModel) -> Observable<Void> {
        guard let user = userManager.user else { return Observable.error(AppError.noToken)}
        return RequestsProvider.rx
            .request(.updateTask(user.token, task))
            .map({result -> Void in
                if let error = self.userManager.handleApiError(data: result.data) {
                    throw error
                }
                return Void()}).asObservable()
    }
    
    func logout() {
        userManager.removeToken()
    }
    
    func saveSettings(_ sort: SortingTask) {
        KeychainWrapper.standard.set(sort.rawValue, forKey: Constans.sorting)
    }
    
    func receiveSettings() -> SortingTask {
        guard let sortRawValue = KeychainWrapper.standard.string(forKey: Constans.sorting),
            let sort = SortingTask(rawValue: sortRawValue) else { return .nameUp }
        return sort
    }
}
