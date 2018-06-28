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
  @IBOutlet weak var ConstraintLabel: UILabel!
  override func viewDidLoad() {
    super.viewDidLoad()
    model.detailName.bind(to: rx.title).disposed(by: disposeBag)
    model.detailName.bind(to: nameLabel.rx.text).disposed(by: disposeBag)
    model.detailConstraint.bind(to: ConstraintLabel.rx.text).disposed(by: disposeBag)
  }
}
