//
//  ItemViewController.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class ItemViewController: UIViewController {
  var disposeBag = DisposeBag()
  var model: ItemViewModel!
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var detailsLabel: UILabel!
  private var titleButton = UIButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupBindings()
  }
  
  private func setupUI() {
    titleButton.translatesAutoresizingMaskIntoConstraints = false
    titleButton.setTitleColor(.black, for: .normal)
    titleButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
    navigationItem.titleView = titleButton
    detailsLabel.text = "Details"
  }
  
  private func setupBindings() {
    // Bindings
    model.itemName.bind(to: titleButton.rx.title()).disposed(by: disposeBag)
    model.itemName.bind(to: rx.title).disposed(by: disposeBag)

    // Observables
    model.titleButton = titleButton.rx.tap.asObservable()
    model.addButton = navigationItem.rightBarButtonItem?.rx.tap.asObservable()

    // Tables
    model.details.bind(to: tableView.rx.items(cellIdentifier: "detailCell", cellType: UITableViewCell.self)) { _, item, cell in
      cell.textLabel?.text = item.name
      cell.detailTextLabel?.text = item.constraint
      }.disposed(by: disposeBag)
    model.detailSelected = tableView.rx.itemSelected.map { [unowned self] in
      self.tableView.cellForRow(at: $0)?.isSelected = false
      return $0
      }.asObservable()
    model.detailDeleted = tableView.rx.itemDeleted.asObservable()
  }
}
