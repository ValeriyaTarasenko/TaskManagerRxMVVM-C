//
//  SettingsViewModel.swift
//  DOITTarasenko
//
//  Created by Valeriia Tarasenko on 06/05/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SettingsViewModel {
    
    var settings = BehaviorRelay(value: SortingTask.allCases)
    private let disposeBag = DisposeBag()
    
    private var taskManager: TaskManager
    private weak var coordinator: BaseCoordinator?
    
    let saveSettingsAction = PublishSubject<SortingTask>()
    let logoutAction = PublishSubject<Void>()
    let getSettingsAction = PublishSubject<Void>()
    let didGetSettings = PublishSubject<SortingTask>()
    
    init(taskManager: TaskManager, coordinator: BaseCoordinator) {
        self.taskManager = taskManager
        self.coordinator = coordinator
        
        saveSettingsAction.subscribe(onNext: { [weak self] sort in
            self?.saveSettings(sort)
            }).disposed(by: disposeBag)
        
        logoutAction.subscribe(onNext: { [weak self] in
            self?.showSignIn()
            }).disposed(by: disposeBag)
        
        getSettingsAction.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.didGetSettings.onNext(self.getSettings())
            }).disposed(by: disposeBag)
    }
    
    func getSettings() -> SortingTask {
        return taskManager.receiveSettings()
    }
    
    func saveSettings(_ sort: SortingTask) {
        taskManager.saveSettings(sort)
    }
    
    func showSignIn() {
        coordinator?.showConfirmationAlert(title: nil,
            message: "Do you want to logout?",
            firstAction: {
                self.taskManager.logout()
                self.coordinator?.showLogin()
        })
    }
    
    func didFinishSettings() {
        (coordinator as? SettingsCoordinator)?.didFinishSettings()
    }
}
