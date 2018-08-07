//
//  ChooseItemOrConstraintViewController.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/6/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import UIKit

class ChooseItemOrConstraintViewController: UIViewController {
  var model: ChooseItemOrConstraintViewModel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let ac = UIAlertController(title: "Add", message: nil, preferredStyle: .actionSheet)
    let itemAction = UIAlertAction(title: "Item", style: .default) { [unowned self] _ in
      self.model.itemTapped.onNext(())
    }
    let constraintAction = UIAlertAction(title: "Constraint", style: .default) { [unowned self] _ in
      self.model.constraintTapped.onNext(())
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] _ in
      self.model.cancelTapped.onNext(())
    }
    ac.addAction(itemAction)
    ac.addAction(constraintAction)
    ac.addAction(cancelAction)
    ac.preferredAction = itemAction
    ac.popoverPresentationController?.sourceView = view
    ac.popoverPresentationController?.sourceRect = view.frame
    present(ac, animated: true)
  }
}
