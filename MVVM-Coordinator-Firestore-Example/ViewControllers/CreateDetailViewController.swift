//
//  CreateDetailViewController.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/7/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import RxSwift
import UIKit

class CreateDetailViewController: UIViewController {
  var model: CreateDetailViewModel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    var nameDisposable: Disposable?
    var constraintDisposable: Disposable?
    let alertController = UIAlertController(title: "Add", message: nil, preferredStyle: .alert)
    alertController.addTextField { [unowned self] textField in
      textField.placeholder = "Enter a name"
      textField.autocapitalizationType = .words
      textField.autocorrectionType = UITextAutocorrectionType.yes
      nameDisposable = textField.rx.text.bind(to: self.model.nameText)
    }
    // TODO: Constraint should not be a textfield, it should be a selection from a list of existing constraints
    alertController.addTextField { [unowned self] textField in
      textField.placeholder = "Enter an existing constraint"
      textField.autocapitalizationType = .words
      textField.autocorrectionType = UITextAutocorrectionType.yes
      constraintDisposable = textField.rx.text.bind(to: self.model.constraintText)
    }
    let okAction = UIAlertAction(title: "Ok", style: .default) { [unowned self] _ in
      self.model.addTapped.onNext(())
      nameDisposable?.dispose()
      constraintDisposable?.dispose()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] _ in
      self.model.cancelTapped.onNext(())
      nameDisposable?.dispose()
      constraintDisposable?.dispose()
    }
    alertController.addAction(okAction)
    alertController.addAction(cancelAction)
    alertController.preferredAction = okAction
    present(alertController, animated: true)
  }
}
