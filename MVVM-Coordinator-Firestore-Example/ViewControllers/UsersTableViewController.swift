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
    // Observables
    model.addButton = navigationItem.rightBarButtonItem?.rx.tap.asObservable()

    // Tables
    model.users.bind(to: tableView.rx.items(cellIdentifier: "userCell", cellType: UITableViewCell.self)) { _, user, cell in
      cell.textLabel?.text = user.name
      }.disposed(by: disposeBag)
    model.userSelected = tableView.rx.itemSelected.map { [unowned self] in
      self.tableView.cellForRow(at: $0)?.isSelected = false
      return $0
      }.asObservable()
    model.userDeleted = tableView.rx.itemDeleted.asObservable()
  }
}
