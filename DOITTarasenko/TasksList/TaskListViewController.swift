//
//  TaskListViewController.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/12/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu
import RxSwift
import RxCocoa

//protocol TaskListDelegate: class  {
//    func updateTaskList()
//}

class TaskListViewController: BasicViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var sortBarButton: UIBarButtonItem!
    @IBOutlet private weak var addTaskButton: UIButton!
    @IBOutlet private weak var notificationBarButton: UIBarButtonItem!
    @IBOutlet private weak var settingsBarButton: UIBarButtonItem!
    
    private var refreshControl = UIRefreshControl()
    private let items = SortingTask.allCases.map { $0.rawValue }
    
    private let disposeBag = DisposeBag()
    var viewModel: TaskListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurateView()
        
        setupCellConfiguration()
        setupCellTapHandling()
        setupTableViewRefreshControl()
        setupTableWillDisplay()
        setupBindings()
    }
    
    private func setupTableViewRefreshControl() {
        tableView.refreshControl = refreshControl
        
        refreshControl.rx.controlEvent(.valueChanged).bind(to: self.viewModel.updateList).disposed(by: disposeBag)
    }
    
    func setupCellConfiguration() {
        viewModel?.tasks.bind(to: tableView.rx.items(cellIdentifier: TaskListTableViewCell.Identifier, cellType: TaskListTableViewCell.self)) { row, task, cell in
            cell.setup(with: task)
        }.disposed(by: disposeBag)
    }
    
    func setupCellTapHandling() {
      tableView.rx.modelSelected(TaskModel.self)
        .subscribe(onNext: { [weak self] task in
            guard let `self` = self else { return }
            self.viewModel?.showDetailAction.onNext(task.id)
        })
        .disposed(by: disposeBag)
    }
    
    func setupTableWillDisplay() {
        tableView.rx.willDisplayCell
            .subscribe(onNext: { cell, indexPath in
                self.viewModel?.updateNewPage.onNext(indexPath.row)
            }).disposed(by: disposeBag)
    }
    
    private func setupBindings() {
        viewModel?.didFail
            .subscribe(onNext: { [weak self] error in
                self?.refreshControl.endRefreshing()
            }).disposed(by: disposeBag)
        
        addTaskButton.rx.tap.bind(to: self.viewModel.addTaskAction).disposed(by: disposeBag)
        notificationBarButton.rx.tap.bind(to: self.viewModel.showNotificationAction).disposed(by: disposeBag)
        settingsBarButton.rx.tap.bind(to: self.viewModel.showSettingsAction).disposed(by: disposeBag)
        
        viewModel?.didGetTasks
            .subscribe(onNext: { [weak self] in
                self?.refreshControl.endRefreshing()
            }).disposed(by: disposeBag)
    }
    
    private func configurateView() {
        tableView.tableFooterView = UIView()
        
        guard let view = self.navigationController?.view else { return }
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: view, title: "Sort", items: items)
        self.navigationItem.rightBarButtonItem?.customView = menuView
        menuView.didSelectItemAtIndexHandler = { [weak self] (indexPath: Int) -> () in
            self?.viewModel?.sortSelected.onNext(indexPath)
        }
    }
}
