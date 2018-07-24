//
//  ItemCoordinator.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import UIKit


class ItemCoordinator: Coordinator {
  private var navigationController: UINavigationController
  private var itemPath: String
  private var userPath: String

  var childCoordinators = [Coordinator]()
  
  required init(_ navigationController: UINavigationController, itemPath: String, userPath: String) {
    self.itemPath = itemPath
    self.userPath = userPath
    self.navigationController = navigationController
  }
  
  func start() {
    showItemViewController()
  }
}

extension ItemCoordinator {
  private func showItemViewController() {
    let itemVM = ItemViewModel(itemPath, userPath: userPath, delegate: self)
    guard let itemVC = UIStoryboard.init(name: "Item", bundle: nil).instantiateInitialViewController() as? ItemViewController else { assertionFailure(); return }
    itemVC.model = itemVM
    navigationController.pushViewController(itemVC, animated: true)
  }
  
  private func startDetailCoordinator(_ detailPath: String) {
    let detailCoordinator = DetailCoordinator(navigationController, detailPath: detailPath, userPath: userPath)
      addChildCoordinator(detailCoordinator)
      detailCoordinator.start()
  }
  
  private func showAddDetailController() {
    // This would be it's own view controller managed by this coordinator eventually
    let ac = UIAlertController(title: "Add", message: nil, preferredStyle: .alert)
    ac.addTextField { (textField) in
      textField.placeholder = "Enter a name"
    }
    // TODO: Figure out how to access this user's constraints and only allow those (obviously
    // not through use of a textfield)
    ac.addTextField { (textField) in
      textField.placeholder = "Existing Constraint?"
    }
    let okAction = UIAlertAction(title: "Ok", style: .default) { [weak ac] action in
      if let name = ac?.textFields?.first?.text, !name.isEmpty,
        ac?.textFields?.count ?? 0 > 1, let constraint = ac?.textFields?[1].text, !constraint.isEmpty {
        FirestoreService.createDetail(itemPath: self.itemPath, with: name, constraint: constraint)
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    ac.addAction(okAction)
    ac.addAction(cancelAction)
    ac.preferredAction = okAction
    navigationController.present(ac, animated: true)
  }
  
  private func showEditItemController(_ item: Item) {
    // This would be it's own view controller managed by this coordinator eventually
    let ac = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
    ac.addTextField { (textField) in
      textField.text = item.name
    }
    let okAction = UIAlertAction(title: "Ok", style: .default) { [weak ac] action in
      if let name = ac?.textFields?.first?.text, !name.isEmpty {
        FirestoreService.updateItem(path: item.path, with: ["name": name]) { error in
          if let error = error {
            print(error)
          }
        }
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    ac.addAction(okAction)
    ac.addAction(cancelAction)
    ac.preferredAction = okAction
    navigationController.present(ac, animated: true)
  }
}

extension ItemCoordinator: ItemViewModelDelegate {
  func edit(_ item: Item) {
    showEditItemController(item)
  }

  func select(_ detailPath: String) {
    startDetailCoordinator(detailPath)
  }
  
  func add() {
    showAddDetailController()
  }
  
  func viewModelDidDismiss() {
    // TODO: Dismiss coordinator as well
    navigationController.popViewController(animated: true)
  }
}
