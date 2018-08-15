//
//  EditDetailViewController.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/14/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import RxSwift
import UIKit

class EditDetailViewController: UIViewController {
  var model: EditDetailViewModel!
  var disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    var detailNameToViewDisposable: Disposable?
    var detailNameFromViewDisposable: Disposable?
    let alertController = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
    alertController.addTextField { [unowned self] textField in
      textField.placeholder = "Enter a name"
      textField.autocapitalizationType = .words
      textField.autocorrectionType = UITextAutocorrectionType.yes
      detailNameToViewDisposable = self.model.detailNameToView.take(1).bind(to: textField.rx.text)
      detailNameFromViewDisposable = textField.rx.text.orEmpty.bind(to: self.model.detailNameFromView)
    }
    let okAction = UIAlertAction(title: "Ok", style: .default) { [unowned self] _ in
      self.model.okTapped.onNext(())
      detailNameToViewDisposable?.dispose()
      detailNameFromViewDisposable?.dispose()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] _ in
      self.model.cancelTapped.onNext(())
      detailNameFromViewDisposable?.dispose()
    }
    alertController.addAction(okAction)
    alertController.addAction(cancelAction)
    alertController.preferredAction = okAction
    model.detailLoading.filter { !$0 }.take(1).bind { [unowned self] detailLoading in
      self.present(alertController, animated: true)
      }.disposed(by: disposeBag)
  }
}
