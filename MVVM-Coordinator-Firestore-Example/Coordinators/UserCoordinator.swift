//
//  UserCoordinator.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import UIKit

class UserCoordinator: Coordinator {
  var navigationController: UINavigationController
  var user: User
  
  var childCoordinators = [Coordinator]()
  
  required init(_ navigationController: UINavigationController, user: User) {
    self.user = user
    self.navigationController = navigationController
  }

  func start() {
    showUserViewController()
  }
}

extension UserCoordinator {
  private func showUserViewController() {
    let userVM = UserViewModel(user, delegate: self)
    guard let userVC = UIStoryboard.init(name: "User", bundle: nil).instantiateInitialViewController() as? UserViewController else { assertionFailure(); return }
    userVC.model = userVM
    navigationController.pushViewController(userVC, animated: true)
  }
  
  private func startItemCoordinator(_ item: Item) {
    let itemCoordinator = ItemCoordinator(navigationController, item: item)
    addChildCoordinator(itemCoordinator)
    itemCoordinator.start()
  }
  
  private func showChooseItemOrConstraintController() {
    // This would be it's own view controller managed by this coordinator eventually
    let ac = UIAlertController(title: "Add", message: nil, preferredStyle: .actionSheet)
    let itemAction = UIAlertAction(title: "Item", style: .default) { action in
      self.showAddItemController()
    }
    let constraintAction = UIAlertAction(title: "Constraint", style: .default) { action in
      self.showAddConstraintController()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
    ac.addAction(itemAction)
    ac.addAction(constraintAction)
    ac.addAction(cancelAction)
    ac.preferredAction = itemAction
    navigationController.present(ac, animated: true)
  }
  
  private func showAddItemController() {
    // This would be it's own view controller managed by this coordinator eventually
    let ac = UIAlertController(title: "Add", message: nil, preferredStyle: .alert)
    ac.addTextField { (textField) in
      textField.placeholder = "Enter a name"
    }
    let okAction = UIAlertAction(title: "Ok", style: .default) { action in
      if let name = ac.textFields?.first?.text, !name.isEmpty {
        FirestoreService.createItem(for: self.user, with: name)
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
    ac.addAction(okAction)
    ac.addAction(cancelAction)
    ac.preferredAction = okAction
    navigationController.present(ac, animated: true)
  }
  
  private func showAddConstraintController() {
    // This would be it's own view controller managed by this coordinator eventually
    let ac = UIAlertController(title: "Add", message: nil, preferredStyle: .alert)
    ac.addTextField { (textField) in
      textField.placeholder = "Enter a name"
    }
    let okAction = UIAlertAction(title: "Ok", style: .default) { action in
      if let name = ac.textFields?.first?.text, !name.isEmpty {
        FirestoreService.createConstraint(for: self.user, with: name)
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
    ac.addAction(okAction)
    ac.addAction(cancelAction)
    ac.preferredAction = okAction
    navigationController.present(ac, animated: true)
  }
}

extension UserCoordinator: UserViewModelDelegate {
  func didTapAdd() {
    showChooseItemOrConstraintController()
  }
  
  func didSelect(_ item: Item) {
    startItemCoordinator(item)
  }
}
