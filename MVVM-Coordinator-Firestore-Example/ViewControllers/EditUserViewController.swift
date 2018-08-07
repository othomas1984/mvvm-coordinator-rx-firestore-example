//
//  EditUserViewController.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/6/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import RxSwift
import UIKit

class EditUserViewController: UIViewController {
  var model: EditUserViewModel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    var disposable: Disposable?
    let alertController = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
    alertController.addTextField { [unowned self] textField in
      textField.placeholder = "Enter a name"
      disposable = self.model.userName.bind(to: textField.rx.text)
    }
    let okAction = UIAlertAction(title: "Ok", style: .default) { [unowned alertController, unowned self] _ in
      self.model.okTapped.onNext(alertController.textFields?.first?.text)
      disposable?.dispose()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] _ in
      self.model.cancelTapped.onNext(())
      disposable?.dispose()
    }
    alertController.addAction(okAction)
    alertController.addAction(cancelAction)
    alertController.preferredAction = okAction
    self.present(alertController, animated: true)
  }
}
