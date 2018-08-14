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
    var nameDisposable: Disposable?
    let alertController = UIAlertController(title: "Add", message: nil, preferredStyle: .alert)
    alertController.addTextField { [unowned self] textField in
      textField.placeholder = "Enter a name"
      textField.autocapitalizationType = .words
      textField.textContentType = UITextContentType.name
      textField.autocorrectionType = UITextAutocorrectionType.yes
      nameDisposable = textField.rx.text.orEmpty.bind(to: self.model.nameText)
    }
    let okAction = UIAlertAction(title: "Ok", style: .default) { [unowned self] _ in
      self.model.addTapped.onNext(())
      nameDisposable?.dispose()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] _ in
      self.model.cancelTapped.onNext(())
      nameDisposable?.dispose()
    }
    alertController.addAction(okAction)
    alertController.addAction(cancelAction)
    alertController.preferredAction = okAction
    present(alertController, animated: true)
  }
}
