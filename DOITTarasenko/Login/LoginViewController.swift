//
//  LoginViewController.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/11/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: BasicViewController {

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var loginSwitch: UISwitch!
    @IBOutlet private weak var loginDescriptionLabel: UILabel!
    @IBOutlet private weak var loginTitleLabel: UILabel!
    @IBOutlet private weak var loginButton: UIButton!
    
    var viewModel: LoginViewModel!
    private let disposeBag = DisposeBag()
    
    weak var coordinator: BaseCoordinator?
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear.onNext(())
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        emailTextField.text = ""
        passwordTextField.text = ""
        confirmPasswordTextField.text = ""
    }
    
    private func setupBindings() {
        
        emailTextField.rx.text.orEmpty
            .bind(to: self.viewModel.mail)
            .disposed(by: self.disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: self.viewModel.password)
            .disposed(by: self.disposeBag)
        
        confirmPasswordTextField.rx.text.orEmpty
            .bind(to: self.viewModel.confirmPassword)
            .disposed(by: self.disposeBag)
        
        loginSwitch.rx.isOn
            .bind(to: self.viewModel.loginSwitch)
            .disposed(by: self.disposeBag)
        
//        loginButton.rx.tap
//            .bind { [weak self] in
//                self?.viewModel.loginAction.onNext(())
//        }.disposed(by: disposeBag)
        loginButton.rx.tap.bind(to: self.viewModel.loginAction).disposed(by: disposeBag)
        
        loginSwitch.rx.controlEvent(.valueChanged)
            .withLatestFrom(loginSwitch.rx.value)
            .subscribe(onNext : { bool in
                if bool {
                    self.loginTitleLabel.text = "Sign up"
                    self.loginButton.setTitle("REGISTER", for: .normal)
                    self.confirmPasswordTextField.isHidden = false
                    self.passwordTextField.returnKeyType = .next
                    self.passwordTextField.textContentType = .newPassword
                } else {
                    self.loginTitleLabel.text = "Sign in"
                    self.loginButton.setTitle("LOG IN", for: .normal)
                    self.confirmPasswordTextField.isHidden = true
                    self.passwordTextField.returnKeyType = .done
                    self.passwordTextField.textContentType = .password
                }
            }).disposed(by: disposeBag)
        
        emailTextField.rx.controlEvent(.editingDidEndOnExit).asObservable()
            .subscribe(onNext: { _ in
                self.passwordTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
        
        passwordTextField.rx.controlEvent(.editingDidEndOnExit).asObservable()
            .subscribe(onNext: { _ in
                if self.loginSwitch.isOn {
                    self.confirmPasswordTextField.becomeFirstResponder()
                } else {
                    self.view.endEditing(true)
                    self.viewModel.loginAction.onNext(())
                }
            }).disposed(by: disposeBag)
        
        confirmPasswordTextField.rx.controlEvent(.editingDidEndOnExit).asObservable()
            .subscribe(onNext: { _ in
                self.view.endEditing(true)
                self.viewModel.loginAction.onNext(())
            }).disposed(by: disposeBag)
    }
}
