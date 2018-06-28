//
//  UserViewController.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class UserViewController: UIViewController {
  var disposeBag = DisposeBag()
  var model: UserViewModel!
  
  @IBOutlet weak var constraintsTableView: UITableView!
  @IBOutlet weak var itemsTableView: UITableView!
  @IBOutlet weak var itemsLabel: UILabel!
  @IBOutlet weak var constraintsLabel: UILabel!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    itemsTableView.delegate = self
    constraintsTableView.delegate = self
    itemsLabel.text = "Items"
    constraintsLabel.text = "Constraints"

    model.userName.bind(to: rx.title).disposed(by: disposeBag)
    model.constraints.bind(to: constraintsTableView.rx.items(cellIdentifier: "constraintCell", cellType: UITableViewCell.self)) { _, item, cell in
      cell.textLabel?.text = item.name
    }.disposed(by: disposeBag)
    model.items.bind(to: itemsTableView.rx.items(cellIdentifier: "itemCell", cellType: UITableViewCell.self)) { _, item, cell in
      cell.textLabel?.text = item.name
      }.disposed(by: disposeBag)
    model.addButton = navigationItem.rightBarButtonItem?.rx.tap.asObservable()
  }
}

extension UserViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.cellForRow(at: indexPath)?.isSelected = false
    guard tableView == itemsTableView else { return }
    model.didSelect(indexPath.row)
  }
}
