//
//  NewTaskViewController.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/12/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NewTaskViewController: BasicViewController {
    @IBOutlet private weak var titleTextView: UITextView!
    @IBOutlet private weak var highPriorityButton: UIButton!
    @IBOutlet private weak var mediumPriorityButton: UIButton!
    @IBOutlet private weak var lowPriorityButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var dateTextField: UITextField!
    @IBOutlet private weak var notificationTextField: UITextField!
    @IBOutlet private weak var deleteNotificationButton: UIButton!
    
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy HH:mm"
        return dateFormatter
    }
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.minimumDate = Date()
        return picker
    }()
    
    private let notificationDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.minimumDate = Date()
        return picker
    }()
    
    private let disposeBag = DisposeBag()
    var viewModel: NewTaskViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        titleTextView.layer.borderColor = UIColor.lightGray.cgColor
        titleTextView.layer.borderWidth = 1
        highPriorityButton.layer.borderColor = UIColor.lightGray.cgColor
        highPriorityButton.layer.borderWidth = 1
        mediumPriorityButton.layer.borderColor = UIColor.lightGray.cgColor
        mediumPriorityButton.layer.borderWidth = 1
        lowPriorityButton.layer.borderColor = UIColor.lightGray.cgColor
        lowPriorityButton.layer.borderWidth = 1
        
        addDatePicker()
        setPriority(.low)
        deleteButton.isHidden = viewModel.task == nil
        
        setUpBindings()
        viewModel.updateTaskInfo.onNext(())
    }
    
    private func setup(task: TaskModel) {
        titleTextView.text = task.title
        datePicker.date = Date(timeIntervalSince1970: task.dueBy)
        handleDatePicker()
        setPriority(task.priorityValue)
        guard let notification = task.notification else { return }
        notificationDatePicker.date = Date(timeIntervalSince1970: notification.dateInterval)
        handleNotificationDatePicker()
    }
    
    private func addDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: nil)
        doneButton.rx.tap
            .bind{ [weak self] in
                self?.handleDatePicker()
            }.disposed(by: disposeBag)
        toolbar.setItems([doneButton], animated: false)
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datePicker
        
        let toolbarNotification = UIToolbar()
        toolbarNotification.sizeToFit()
        let doneNotificationButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: nil)
        doneNotificationButton.rx.tap
            .bind{ [weak self] in
                self?.handleNotificationDatePicker()
        }.disposed(by: disposeBag)
        toolbarNotification.setItems([doneNotificationButton], animated: false)
        notificationTextField.inputAccessoryView = toolbarNotification
        notificationTextField.inputView = notificationDatePicker
        
    }
    
    private func setPriority(_ priority: TaskModel.Priority) {
        let priorityButtons: [UIButton] = [highPriorityButton, mediumPriorityButton, lowPriorityButton]
        guard let index = TaskModel.Priority.allCases.firstIndex(where: {$0 == priority}) else { return }
        priorityButtons.forEach({button in
            if button.tag == index {
                button.backgroundColor = .orange
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = .white
                button.setTitleColor(.black, for: .normal)
            }
        })
    }
    
    private func setUpBindings() {
        self.viewModel.didGetTask
        .subscribe(onNext: { [weak self] task in
            self?.setup(task: task)
        })
        .disposed(by: self.disposeBag)
        
        titleTextView.rx.text.orEmpty
            .bind(to: self.viewModel.title)
            .disposed(by: self.disposeBag)
        
        saveButton.rx.tap.bind(to: self.viewModel.saveAction).disposed(by: disposeBag)
        
        deleteNotificationButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.deleteNotificationAction.onNext(())
                self?.notificationTextField.text = ""
            }.disposed(by: self.disposeBag)
        
        deleteButton.rx.tap.bind(to: self.viewModel.deleteAction).disposed(by: disposeBag)
        
        viewModel.didAddTask
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.disposeBag)
        
        viewModel.didDeleteTask
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            })
            .disposed(by: self.disposeBag)
        
        highPriorityButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.priorityAction.onNext(.high)
                self?.setPriority(.high)
            }.disposed(by: disposeBag)
        
        mediumPriorityButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.priorityAction.onNext(.medium)
                self?.setPriority(.medium)
            }.disposed(by: disposeBag)
        
        lowPriorityButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.priorityAction.onNext(.low)
                self?.setPriority(.low)
            }.disposed(by: disposeBag)
    }
    
    private func handleDatePicker() {
        dateTextField.text = dateFormatter.string(from: datePicker.date)
        dateTextField.resignFirstResponder()
        notificationDatePicker.maximumDate = datePicker.date
        notificationDatePicker.date = datePicker.date
        
        viewModel.updateDatePicker.onNext(datePicker.date)
    }
    
    private func handleNotificationDatePicker() {
        notificationTextField.text = dateFormatter.string(from: notificationDatePicker.date)
        notificationTextField.resignFirstResponder()
        
        viewModel.updateDateNotificationPicker.onNext(datePicker.date)
    }
}
