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
  
  private func startUserCoordinator(_ user: User) {
    let userCoordinator = UserCoordinator(navigationController, user: user)
    addChildCoordinator(userCoordinator)
    userCoordinator.start()
  }
}

extension StartCoordinator: StartViewModelDelegate {
  func didSelect(_ user: User) {
    startUserCoordinator(user)
  }
}
