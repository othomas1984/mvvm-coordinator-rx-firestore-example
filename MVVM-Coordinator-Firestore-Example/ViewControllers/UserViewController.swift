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
  private var titleButton = UIButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupBindings()
  }
  
  private func setupUI() {
    itemsLabel.text = "Items"
    constraintsLabel.text = "Constraints"
    titleButton.translatesAutoresizingMaskIntoConstraints = false
    navigationItem.titleView = titleButton
    titleButton.setTitleColor(.black, for: .normal)
    titleButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
  }
  
  private func setupBindings() {
    // Bindings
    model.userName.bind(to: rx.title).disposed(by: disposeBag)
    model.userName.bind(to: titleButton.rx.title()).disposed(by: disposeBag)
    
    // Observables
    model.titleButton = titleButton.rx.tap.asObservable()
    model.addButton = navigationItem.rightBarButtonItem?.rx.tap.asObservable()
    
    // Tables - Items
    model.items.bind(to: itemsTableView.rx.items(cellIdentifier: "itemCell", cellType: UITableViewCell.self)) { _, item, cell in
      cell.textLabel?.text = item.name
      }.disposed(by: disposeBag)
    model.itemSelected = itemsTableView.rx.itemSelected.map { [unowned self] in
      self.itemsTableView.cellForRow(at: $0)?.isSelected = false
      return $0
      }.asObservable()
    model.itemDeleted = itemsTableView.rx.itemDeleted.asObservable()

    // Tables - Constraints
    model.constraints.bind(to: constraintsTableView.rx.items(cellIdentifier: "constraintCell", cellType: UITableViewCell.self)) { _, item, cell in
      cell.textLabel?.text = item.name
      cell.selectionStyle = .none
      }.disposed(by: disposeBag)
    model.constraintDeleted = constraintsTableView.rx.itemDeleted.asObservable()
  }
}
