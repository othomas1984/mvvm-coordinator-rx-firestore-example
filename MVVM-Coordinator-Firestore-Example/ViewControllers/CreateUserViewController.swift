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
    let alertController = UIAlertController(title: "Add", message: nil, preferredStyle: .alert)
    alertController.addTextField { textField in
      textField.placeholder = "Enter a name"
    }
    let okAction = UIAlertAction(title: "Ok", style: .default) { [unowned alertController, unowned self] _ in
      self.model.addTapped.onNext(alertController.textFields?.first?.text)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] _ in
      self.model.cancelTapped.onNext(())
    }
    alertController.addAction(okAction)
    alertController.addAction(cancelAction)
    alertController.preferredAction = okAction
    present(alertController, animated: true)
  }
}
