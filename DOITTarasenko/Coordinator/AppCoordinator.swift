//
//  AppCoordinator.swift
//  DOITTarasenko
//
//  Created by Valeriia Tarasenko on 02/05/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import UIKit

class AppCoordinator: BaseCoordinator {
    override func start() {
        self.navigationController.navigationBar.isHidden = true
        self.window.rootViewController = self.navigationController
        self.window.makeKeyAndVisible()

        showLogin()
    }
}
