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
  override func viewDidLoad() {
    super.viewDidLoad()
    
    detailsLabel.text = "Details"

    model.itemName.bind(to: rx.title).disposed(by: disposeBag)
    model.details.bind(to: tableView.rx.items(cellIdentifier: "detailCell", cellType: UITableViewCell.self)) { _, item, cell in
      cell.textLabel?.text = item.name
      cell.detailTextLabel?.text = item.constraint
      }.disposed(by: disposeBag)
    model.addButton = navigationItem.rightBarButtonItem?.rx.tap.asObservable()
    model.detailSelected = tableView.rx.itemSelected.map { [unowned self] in
      self.tableView.cellForRow(at: $0)?.isSelected = false
      return $0
      }.asObservable()
    model.detailDeleted = tableView.rx.itemDeleted.asObservable()
  }
}
