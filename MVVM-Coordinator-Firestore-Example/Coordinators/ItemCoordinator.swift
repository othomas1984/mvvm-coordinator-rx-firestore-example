//
//  ItemCoordinator.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import UIKit


class ItemCoordinator: Coordinator {
  var navigationController: UINavigationController
  var item: Item
  
  var childCoordinators = [Coordinator]()
  
  required init(_ navigationController: UINavigationController, item: Item) {
    self.item = item
    self.navigationController = navigationController
  }
  
  func start() {
    showItemViewController()
  }
}

extension ItemCoordinator {
  private func showItemViewController() {
    let itemVM = ItemViewModel(item, delegate: self)
    guard let itemVC = UIStoryboard.init(name: "Item", bundle: nil).instantiateInitialViewController() as? ItemViewController else { assertionFailure(); return }
    itemVC.model = itemVM
    navigationController.pushViewController(itemVC, animated: true)
  }
  
  private func startDetailCoordinator(_ detail: Detail) {
    let detailCoordinator = DetailCoordinator(navigationController, detail: detail)
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
    let okAction = UIAlertAction(title: "Ok", style: .default) { action in
      if let name = ac.textFields?.first?.text, !name.isEmpty,
        ac.textFields?.count ?? 0 > 1, let constraint = ac.textFields?[1].text, !constraint.isEmpty {
        FirestoreService.createDetail(for: self.item, with: name, constraint: constraint)
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
    let okAction = UIAlertAction(title: "Ok", style: .default) { action in
      if let name = ac.textFields?.first?.text, !name.isEmpty {
        FirestoreService.update(item, with: ["name": name]) { error in
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
  
  private func deleteDetail(_ detail: Detail) {
    FirestoreService.delete(detail) { error in
      if let error = error {
        print(error)
      }
    }
  }
}

extension ItemCoordinator: ItemViewModelDelegate {
  func edit(_ item: Item) {
    showEditItemController(item)
  }

  func delete(_ detail: Detail) {
    deleteDetail(detail)
  }
  
  func select(_ detail: Detail) {
    startDetailCoordinator(detail)
  }
  
  func add() {
    showAddDetailController()
  }
}
