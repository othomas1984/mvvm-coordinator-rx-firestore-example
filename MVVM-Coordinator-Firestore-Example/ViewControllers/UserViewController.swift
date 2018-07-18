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
    titleButton.rx.tap.bind(to: model.titleTapped).disposed(by: disposeBag)
    navigationItem.rightBarButtonItem?.rx.tap.bind(to: model.addTapped).disposed(by: disposeBag)
    
    // Tables - Items
    model.items.bind(to: itemsTableView.rx.items(cellIdentifier: "itemCell", cellType: UITableViewCell.self)) { _, item, cell in
      cell.textLabel?.text = item.name
      }.disposed(by: disposeBag)
    itemsTableView.rx.itemSelected.bind { [unowned self] in
      self.itemsTableView.cellForRow(at: $0)?.isSelected = false
      self.model.itemSelected.onNext($0)
    }.disposed(by: disposeBag)
    itemsTableView.rx.itemDeleted.bind(to: model.itemDeleted).disposed(by: disposeBag)

    // Tables - Constraints
    model.constraints.bind(to: constraintsTableView.rx.items(cellIdentifier: "constraintCell", cellType: UITableViewCell.self)) { _, item, cell in
      cell.textLabel?.text = item.name
      cell.selectionStyle = .none
      }.disposed(by: disposeBag)
    constraintsTableView.rx.itemDeleted.bind(to: model.constraintDeleted).disposed(by: disposeBag)
  }
}
