//
//  SettingsViewController.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/15/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsViewController: BasicViewController {
    @IBOutlet private weak var tableView: UITableView!
    var sortType = BehaviorRelay(value: SortingTask.nameUp) //= SortingTask.nameUp
    
    var viewModel: SettingsViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        guard let sort = viewModel?.getSettings() else { return }
//        sortType.accept(sort)
        
        setupBindings()
        self.viewModel.getSettingsAction.onNext(())
        setBarButtons()
        setupCellConfiguration()
        setupCellTapHandling()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.didFinishSettings()
    }
    
    private func setupBindings() {
        self.viewModel.didGetSettings
        .subscribe(onNext: { [weak self] sort in
            self?.sortType.accept(sort)
        })
        .disposed(by: self.disposeBag)
    }
    
    private func setupCellConfiguration() {
        viewModel?.settings.bind(to: tableView.rx.items(cellIdentifier: SettingsTableViewCell.Identifier, cellType: SettingsTableViewCell.self)) { row, settings, cell in
            cell.setup(with: settings)
            cell.accessoryType = self.sortType.value == settings ? .checkmark : .none
        }.disposed(by: disposeBag)
    }
    
    private func setupCellTapHandling() {
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let `self` = self else { return }
                let sort = self.viewModel.settings.value[indexPath.row]
                self.sortType.accept(sort)
                self.viewModel.saveSettingsAction.onNext(sort)
                self.tableView.reloadData()
            })
        .disposed(by: disposeBag)
    }
    
    
    private func setBarButtons() {
        let logoutBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: nil)
        self.navigationItem.setRightBarButtonItems([logoutBarButtonItem], animated: true)
        logoutBarButtonItem.rx.tap.bind(to: self.viewModel.logoutAction).disposed(by: disposeBag)
//        logoutBarButtonItem.rx.tap
//                .bind{ [weak self] in
//                    guard let `self` = self else { return }
//                    self.showConfirmationAlert(title: nil,
//                        message: "Do you want to logout?",
//                        firstAction: {
//                            self.viewModel?.showSignIn()
//                    })
//                }.disposed(by: disposeBag)
    }
}
