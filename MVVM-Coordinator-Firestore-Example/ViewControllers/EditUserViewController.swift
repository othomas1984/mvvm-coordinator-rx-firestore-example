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
  var disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    var userNameToViewDisposable: Disposable?
    var userNameFromViewDisposable: Disposable?
    let alertController = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
    alertController.addTextField { [unowned self] textField in
      textField.placeholder = "Enter a name"
      textField.autocapitalizationType = .words
      textField.textContentType = UITextContentType.name
      textField.autocorrectionType = UITextAutocorrectionType.yes
      userNameToViewDisposable = self.model.userNameToView.take(1).bind(to: textField.rx.text)
      userNameFromViewDisposable = textField.rx.text.orEmpty.bind(to: self.model.userNameFromView)
    }
    let okAction = UIAlertAction(title: "Ok", style: .default) { [unowned self] _ in
      self.model.okTapped.onNext(())
      userNameToViewDisposable?.dispose()
      userNameFromViewDisposable?.dispose()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] _ in
      self.model.cancelTapped.onNext(())
      userNameFromViewDisposable?.dispose()
    }
    alertController.addAction(okAction)
    alertController.addAction(cancelAction)
    alertController.preferredAction = okAction
    model.userLoading.filter { !$0 }.take(1).bind { [unowned self] userLoading in
      self.present(alertController, animated: true)
    }.disposed(by: disposeBag)
  }
}
