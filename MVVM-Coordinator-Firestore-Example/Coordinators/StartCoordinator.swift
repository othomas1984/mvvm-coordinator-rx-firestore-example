//
//  StartCoordinator.swift
//  Running Tab iOS
//
//  Created by Owen Thomas on 3/13/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import UIKit

class StartCoordinator: NSObject, RootViewCoordinator {
  var rootViewController: UIViewController {
    return navigationController
  }
  
  lazy var navigationController: UINavigationController = {
    let nav = UINavigationController()
    return nav
  }()
  
  var childCoordinators = [Coordinator]()
  var window: UIWindow

  required init(_ window: UIWindow) {
    self.window = window
    super.init()
    window.rootViewController = rootViewController
    window.makeKeyAndVisible()
  }
  
  func start() {
    showUsersViewController()
  }
}

extension StartCoordinator {
  private func showUsersViewController() {
    let startVM = StartViewModel(delegate: self)
    guard let usersVC = UIStoryboard.init(name: "Users", bundle: nil).instantiateInitialViewController() as? UsersTableViewController else { assertionFailure(); return }
    usersVC.model = startVM
    navigationController.pushViewController(usersVC, animated: false)
  }
  
  private func startUserCoordinator(_ userPath: String) {
    let userCoordinator = UserCoordinator(navigationController, delegate: self, userPath: userPath)
    addChildCoordinator(userCoordinator)
    userCoordinator.start()
  }
  
  private func showAddUserController() {
    // This would be it's own view controller managed by this coordinator eventually
    let ac = UIAlertController(title: "Add", message: nil, preferredStyle: .alert)
    ac.addTextField { (textField) in
      textField.placeholder = "Enter a name"
    }
    let okAction = UIAlertAction(title: "Ok", style: .default) { [weak ac] action in
      if let name = ac?.textFields?.first?.text, !name.isEmpty {
        FirestoreService.createUser(with: name)
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    ac.addAction(okAction)
    ac.addAction(cancelAction)
    ac.preferredAction = okAction
    rootViewController.present(ac, animated: true)
  }  
}

extension StartCoordinator: UserCoordinatorDelegate {
  func userCoordinatorDidDismiss(_ coordinator: UserCoordinator) {
    coordinator.rootViewController.dismiss(animated: true) {
      self.removeChildCoordinator(coordinator)
    }
  }
}

extension StartCoordinator: StartViewModelDelegate {
  func add() {
    showAddUserController()
  }
  
  func select(_ userPath: String) {
    startUserCoordinator(userPath)
  }
}
