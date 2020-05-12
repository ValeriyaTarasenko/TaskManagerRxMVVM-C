//
//  LoginViewModel.swift
//  DOITTarasenko
//
//  Created by Valeriia Tarasenko on 01/05/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {
    
    private var userManager: UserManager
    private let disposeBag = DisposeBag()
    private weak var coordinator: BaseCoordinator?
    
    var user: User? {
        return userManager.user
    }
    let mail = BehaviorSubject(value: "")
    let password = BehaviorSubject(value: "")
    let confirmPassword = BehaviorSubject(value: "")
    let loginSwitch = BehaviorSubject(value: false)
    // events
    let didFail = PublishSubject<Error>()
    let viewDidAppear = PublishSubject<Void>()
    let loginAction = PublishSubject<Void>()

    init(userManager: UserManager, coordinator: BaseCoordinator) {
        self.userManager = userManager
        self.coordinator = coordinator
        
        viewDidAppear.subscribe(onNext: { [weak self] _ in
            if self?.user != nil {
                self?.showTasks()
            }
        }).disposed(by: disposeBag)
        
        loginAction.subscribe(onNext: { [weak self] _ in
            self?.autotization()
        }).disposed(by: disposeBag)
    }
    
    func autotization() {
        Observable
            .combineLatest(self.mail, self.password, self.confirmPassword, self.loginSwitch)
        .take(1)
        .subscribe(onNext: { mail, password, confirmPassword, loginSwitch in
        guard self.isValidEmail(mail), !mail.isEmpty  else {
            self.coordinator?.showErrorMessage("Enter valid email")
            return
        }
        guard !password.isEmpty else {
            self.coordinator?.showErrorMessage("Enter password")
            return
        }
        let _ = loginSwitch ? self.signUpAuth(mail: mail, password: password) : self.loginAuth(mail: mail, password: password)
            }).disposed(by: disposeBag)
    }
    
    func loginAuth(mail: String, password: String) {
        userManager.login(mail: mail, password: password)
        .subscribe(onNext: { task in
                self.showTasks()
            }, onError: { error in
//                self.didFail.onNext(error)
                self.coordinator?.showErrorMessage(error.localizedDescription)
        }).disposed(by: disposeBag)
    }
    
    func signUpAuth(mail: String, password: String) {
        userManager.signUp(mail: mail, password: password)
        .subscribe(onNext: { task in
                self.showTasks()
            }, onError: { error in
//                self.didFail.onNext(error)
                self.coordinator?.showErrorMessage(error.localizedDescription)
        }).disposed(by: disposeBag)
    }
    
    func showTasks() {
        (coordinator as? SignInCoordinator)?.showTasksViewController()
    }
    
    private func isValidEmail(_ mail: String) -> Bool {
        guard !mail.isEmpty else { return true }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: mail)
    }
}
