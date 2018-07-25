//
//  DetailViewController.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class DetailViewController: UIViewController {
  var disposeBag = DisposeBag()
  var model: DetailViewModel!
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var constraintLabel: UILabel!
  @IBOutlet weak var nameValueLabel: UILabel!
  @IBOutlet weak var constraintValueLabel: UILabel!
  @IBOutlet weak var constraintPickerView: UIPickerView!
  private var titleButton = UIButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupBindings()
  }
  
  private func setupUI() {
    nameLabel.text = "Name: "
    constraintLabel.text = "Constraint: "
    titleButton.translatesAutoresizingMaskIntoConstraints = false
    titleButton.setTitleColor(.black, for: .normal)
    titleButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
    navigationItem.titleView = titleButton
  }

  private func setupBindings() {
    // Bindings
    var firstLoad = true
    model.detailName.bind(to: titleButton.rx.title()).disposed(by: disposeBag)
    model.detailName.bind(to: rx.title).disposed(by: disposeBag)
    model.detailName.bind(to: nameValueLabel.rx.text).disposed(by: disposeBag)
    model.detailConstraint.bind(to: constraintValueLabel.rx.text).disposed(by: disposeBag)
    titleButton.rx.tap.bind(to: model.titleButton).disposed(by: disposeBag)
    model.constraints.bind(to: constraintPickerView.rx.items) { index, item, test2 in
      if item.selected {
        self.constraintPickerView.selectRow(index, inComponent: 0, animated: !firstLoad)
        firstLoad = false
      }
      let label = UILabel()
      label.textAlignment = .center
      label.text = item.name
      return label
      }.disposed(by: disposeBag)
    constraintPickerView.rx.itemSelected.bind(to: model.constraintSelected).disposed(by: disposeBag)
  }
}
