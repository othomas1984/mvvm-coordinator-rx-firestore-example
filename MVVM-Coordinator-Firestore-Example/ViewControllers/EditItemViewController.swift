//
//  EditItemViewController.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/14/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import RxSwift
import UIKit

class EditItemViewController: UIViewController {
  var model: EditItemViewModel!
  var disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    var itemNameToViewDisposable: Disposable?
    var itemNameFromViewDisposable: Disposable?
    let alertController = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
    alertController.addTextField { [unowned self] textField in
      textField.placeholder = "Enter a name"
      textField.autocapitalizationType = .words
      textField.autocorrectionType = UITextAutocorrectionType.yes
      itemNameToViewDisposable = self.model.itemNameToView.take(1).bind(to: textField.rx.text)
      itemNameFromViewDisposable = textField.rx.text.orEmpty.bind(to: self.model.itemNameFromView)
    }
    let okAction = UIAlertAction(title: "Ok", style: .default) { [unowned self] _ in
      self.model.okTapped.onNext(())
      itemNameToViewDisposable?.dispose()
      itemNameFromViewDisposable?.dispose()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] _ in
      self.model.cancelTapped.onNext(())
      itemNameFromViewDisposable?.dispose()
    }
    alertController.addAction(okAction)
    alertController.addAction(cancelAction)
    alertController.preferredAction = okAction
    model.itemLoading.filter { !$0 }.take(1).bind { [unowned self] userLoading in
      self.present(alertController, animated: true)
      }.disposed(by: disposeBag)
  }
}
