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
  @IBOutlet weak var nameLabel: UILabel!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    
    model.itemName.bind(to: rx.title).disposed(by: disposeBag)
    model.itemName.bind(to: nameLabel.rx.text).disposed(by: disposeBag)
    model.details.bind(to: tableView.rx.items(cellIdentifier: "detailCell", cellType: UITableViewCell.self)) { _, item, cell in
      cell.textLabel?.text = item.name
      cell.detailTextLabel?.text = item.constraint
      }.disposed(by: disposeBag)
    model.addButton = navigationItem.rightBarButtonItem?.rx.tap.asObservable()
  }
}

extension ItemViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.cellForRow(at: indexPath)?.isSelected = false
    model.didSelect(indexPath.row)
  }
}
