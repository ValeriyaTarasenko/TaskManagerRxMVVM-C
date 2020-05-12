//
//  SettingsCoordinator.swift
//  DOITTarasenko
//
//  Created by Valeriia Tarasenko on 06/05/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation

class SettingsCoordinator: BaseCoordinator {

    override func start() {
        let settingsViewController = SettingsViewController.instantiate(with: "Settings")
        let settingsViewModel = SettingsViewModel(taskManager: taskManager,
                                                  coordinator: self)
        settingsViewController.viewModel = settingsViewModel

        self.navigationController.pushViewController(settingsViewController, animated: true)
    }
    
    func didFinishSettings() {
        parentCoordinator?.didFinish(coordinator: self)
    }
}
