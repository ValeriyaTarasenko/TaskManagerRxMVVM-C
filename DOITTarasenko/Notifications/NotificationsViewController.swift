//
//  NotificationsViewController.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/14/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NotificationsViewController: BasicViewController {
    @IBOutlet private weak var tableView: UITableView!

    var viewModel: NotificationViewModel?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
//        viewModel?.getNotifications()
        self.viewModel?.getNotificationsAction.onNext(())
        
        setupCellConfiguration()
        setupItemDeleted()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.didNotificationUpdate.accept(())
        viewModel?.didFinishNotifications()
    }
    
    func setupCellConfiguration() {
        viewModel?.notifications.bind(to: tableView.rx.items(cellIdentifier: NotificationTableViewCell.Identifier, cellType: NotificationTableViewCell.self)) { row, notification, cell in
            cell.setup(with: notification)
        }.disposed(by: disposeBag)
        
    }
    
    func setupItemDeleted() {
        tableView.rx.itemDeleted
            .bind{ [weak self] indexPath in
                guard let `self` = self else { return }
                self.viewModel?.deleteNotificationAction.onNext(indexPath.row)
            }.disposed(by: disposeBag)
    }
}
