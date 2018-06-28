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
  override func viewDidLoad() {
    super.viewDidLoad()
    nameLabel.text = "Name: "
    constraintLabel.text = "Constraint: "
    model.detailName.bind(to: rx.title).disposed(by: disposeBag)
    model.detailName.bind(to: nameValueLabel.rx.text).disposed(by: disposeBag)
    model.detailConstraint.bind(to: constraintValueLabel.rx.text).disposed(by: disposeBag)
  }
}
