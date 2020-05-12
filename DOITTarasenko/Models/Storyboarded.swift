//
//  Storyboarded.swift
//  DOITTarasenko
//
//  Created by Valeriia Tarasenko on 02/05/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import UIKit

protocol Storyboarded {
    static func instantiate(with: String)  -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate(with storyboard: String) -> Self {
        // this pulls out "MyApp.MyViewController"
        let fullName = NSStringFromClass(self)

        // this splits by the dot and uses everything after, giving "MyViewController"
        let className = fullName.components(separatedBy: ".")[1]

        // load our storyboard
        let storyboard = UIStoryboard(name: storyboard, bundle: Bundle.main)

        // instantiate a view controller with that identifier, and force cast as the type that was requested
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}
