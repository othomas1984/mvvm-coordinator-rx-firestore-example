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
    let controller = CreateUserViewController()
    controller.model = CreateUserViewModel(delegate: self)
    controller.modalPresentationStyle = .overCurrentContext
    rootViewController.present(controller, animated: false, completion: nil)
  }
}

extension StartCoordinator: UserCoordinatorDelegate {
  func userCoordinatorDidDismiss(_ coordinator: UserCoordinator) {
    coordinator.rootViewController.dismiss(animated: true) {
      self.removeChildCoordinator(coordinator)
    }
  }
}

extension StartCoordinator: ViewModelDelegate {
  func send(_ action: ViewModelAction) {
    switch action {
    case .dismiss:
      rootViewController.dismiss(animated: false)
    case .edit:
      break
    case let .show(type, id):
      switch type {
      case "user":
        guard let id = id else { return }
        startUserCoordinator(id)
      case "addUser":
        showAddUserController()
      default:
        break
      }
    }
  }
}
