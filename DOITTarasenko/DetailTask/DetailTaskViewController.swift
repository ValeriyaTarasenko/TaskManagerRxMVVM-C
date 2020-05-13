//
//  DetailTaskViewController.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/13/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DetailTaskViewController: BasicViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var priorityLabel: UILabel!
    @IBOutlet private weak var deleteButton: UIButton!
    
    var viewModel: DetailTaskViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBarButtons()
        setupBindings()
        self.viewModel.getTaskInfo.onNext(())
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.didFinishDetail()
    }
    
    private func setBarButtons() {
        let editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: nil)
        self.navigationItem.setRightBarButtonItems([editBarButtonItem], animated: true)
        editBarButtonItem.rx.tap.bind(to: self.viewModel.updateTaskInfo).disposed(by: disposeBag)
    }
    
    private func setupBindings() {
        deleteButton.rx.tap.bind(to: self.viewModel.deleteTaskInfo).disposed(by: disposeBag)
        
        self.viewModel.didGetTask
            .subscribe(onNext: { [weak self] task in
                self?.setup(task)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.didDeleteTask
        .subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
    }
    
    private func setup(_ task: TaskModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM, yyyy"
        let dueDate = Date(timeIntervalSince1970: task.dueBy)
        dateLabel.text = dateFormatter.string(from: dueDate)
        titleLabel.text = task.title
        priorityLabel.text = task.priorityValue.description
    }
}
