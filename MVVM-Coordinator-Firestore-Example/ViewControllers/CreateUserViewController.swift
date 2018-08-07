//
//  CreateUserViewController.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/6/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import UIKit

class CreateUserViewController: UIViewController {
  // TODO: Build CreateUserViewModel and handle events and data manipulation there
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // TODO: Replace Alert Controller with a custom view eventually
    let ac = UIAlertController(title: "Add", message: nil, preferredStyle: .alert)
    ac.addTextField { (textField) in
      textField.placeholder = "Enter a name"
    }
    let okAction = UIAlertAction(title: "Ok", style: .default) { [weak ac] action in
      if let name = ac?.textFields?.first?.text, !name.isEmpty {
        DataService().createUser(with: name)
      }
      self.dismiss(animated: true, completion: nil)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
      self.dismiss(animated: true, completion: nil)
    }
    ac.addAction(okAction)
    ac.addAction(cancelAction)
    ac.preferredAction = okAction
    present(ac, animated: true)
  }
}
