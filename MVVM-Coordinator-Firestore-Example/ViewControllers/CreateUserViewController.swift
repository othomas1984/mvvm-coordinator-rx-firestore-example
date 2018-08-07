//
//  CreateUserViewController.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/6/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import RxSwift
import UIKit

class CreateUserViewController: UIViewController {
  var model: CreateUserViewModel!

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let ac = UIAlertController(title: "Add", message: nil, preferredStyle: .alert)
    ac.addTextField { (textField) in
      textField.placeholder = "Enter a name"
    }
    let okAction = UIAlertAction(title: "Ok", style: .default) { [unowned ac, unowned self] action in
        self.model.addTapped.onNext(ac.textFields?.first?.text)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] action in
      self.model.cancelTapped.onNext(())
    }
    ac.addAction(okAction)
    ac.addAction(cancelAction)
    ac.preferredAction = okAction
    present(ac, animated: true)
  }
}
