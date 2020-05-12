//
//  BasicViewController.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/11/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BasicViewController: UIViewController, Storyboarded {

//    let didTokenExpired = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
//    func showErrorMessage(_ message: String) {
//        let alertController = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//        present(alertController, animated: true, completion: nil)
//    }
//    
//    func showConfirmationAlert(title: String?,
//                               message: String? = nil,
//                               buttonFirstTitle: String? = "OK",
//                               buttonFirstStyle: UIAlertAction.Style = .default,
//                               buttonSecondTitle: String? = "Cancel",
//                               buttonSecondStyle: UIAlertAction.Style = .default,
//                               firstAction: (() -> Void)? = nil,
//                               secondAction: (() -> Void)? = nil) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: buttonFirstTitle, style: buttonFirstStyle) { _ in
//            if let action = firstAction { action() }
//        })
//        alert.addAction(UIAlertAction(title: buttonSecondTitle, style: buttonSecondStyle) { _ in
//            if let action = secondAction { action() }
//        })
//        self.present(alert, animated: true, completion: nil)
//    }
    
//    func handleError(_ error: AppError) {
//        if case AppError.expiredToken = error {
//            didTokenExpired.onNext(())
//            return
//        }
//        self.showErrorMessage(error.localizedDescription)
//    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

