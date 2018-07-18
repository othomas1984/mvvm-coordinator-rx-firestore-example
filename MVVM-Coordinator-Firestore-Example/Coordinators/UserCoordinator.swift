//
//  UserCoordinator.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import UIKit

protocol UserCoordinatorDelegate: class {
  func userCoordinatorDidDismiss(_ coordinator: UserCoordinator)
}

class UserCoordinator: RootViewCoordinator {
  lazy var rootViewController: UIViewController = {
    return navigationController
  }()
  
  var navigationController: UINavigationController = {
    return UINavigationController()
  }()
  
  var user: User
  private weak var delegate: UserCoordinatorDelegate?
  
  var childCoordinators = [Coordinator]()
  
  required init(_ navigationController: UINavigationController, delegate: UserCoordinatorDelegate, user: User) {
    self.delegate = delegate
    self.user = user
    navigationController.present(rootViewController, animated: true)
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
    userVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss))
    navigationController.pushViewController(userVC, animated: false)
  }
  
  @objc func dismiss() {
    delegate?.userCoordinatorDidDismiss(self)
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
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
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
    let okAction = UIAlertAction(title: "Ok", style: .default) { [weak ac] action in
      if let name = ac?.textFields?.first?.text, !name.isEmpty {
        FirestoreService.createItem(userPath: self.user.path, with: name)
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
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
    let okAction = UIAlertAction(title: "Ok", style: .default) { [weak ac] action in
      if let name = ac?.textFields?.first?.text, !name.isEmpty {
        FirestoreService.createConstraint(userPath: self.user.path, with: name)
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    ac.addAction(okAction)
    ac.addAction(cancelAction)
    ac.preferredAction = okAction
    navigationController.present(ac, animated: true)
  }
  
  private func showEditUserController(_ user: User) {
    // This would be it's own view controller managed by this coordinator eventually
    let ac = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
    ac.addTextField { (textField) in
      textField.text = user.name
    }
    let okAction = UIAlertAction(title: "Ok", style: .default) { [weak ac] action in
      if let name = ac?.textFields?.first?.text, !name.isEmpty {
        FirestoreService.updateUser(path: user.path, with: ["name": name]) { error in
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

extension UserCoordinator: UserViewModelDelegate {
  func edit(_ user: User) {
    showEditUserController(user)
  }
  
  func add() {
    showChooseItemOrConstraintController()
  }
  
  func select(_ item: Item) {
    startItemCoordinator(item)
  }
  
  func viewModelDidDismiss() {
    // TODO: Dismiss coordinator as well
    navigationController.dismiss(animated: true)
  }
}
