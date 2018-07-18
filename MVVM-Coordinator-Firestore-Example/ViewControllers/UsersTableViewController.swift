//
//  UsersTableViewController.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class UsersTableViewController: UITableViewController {
  var model: StartViewModel!
  var disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = nil
    tableView.delegate = nil
    setupUI()
    setupBindings()
  }
  
  private func setupUI() {
    title = "Users"
  }
  
  private func setupBindings() {
    navigationItem.rightBarButtonItem?.rx.tap.bind(to: model.addTapped).disposed(by: disposeBag)

    // Tables
    model.users.bind(to: tableView.rx.items(cellIdentifier: "userCell", cellType: UITableViewCell.self)) { _, user, cell in
      cell.textLabel?.text = user.name
      }.disposed(by: disposeBag)
    tableView.rx.itemSelected.bind { [unowned self] in
      self.tableView.cellForRow(at: $0)?.isSelected = false
      self.model.userSelected.onNext($0)
    }.disposed(by: disposeBag)
    tableView.rx.itemDeleted.bind(to: model.userDeleted).disposed(by: disposeBag)
  }
}
