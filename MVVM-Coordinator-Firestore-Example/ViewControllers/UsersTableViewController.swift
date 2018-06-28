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
    title = "Users"
    tableView.dataSource = nil
    tableView.delegate = self
    model.users.bind(to: tableView.rx.items(cellIdentifier: "userCell", cellType: UITableViewCell.self)) { _, user, cell in
      cell.textLabel?.text = user.name
    }.disposed(by: disposeBag)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.cellForRow(at: indexPath)?.isSelected = false
    model.didSelect(indexPath.row)
  }
}
