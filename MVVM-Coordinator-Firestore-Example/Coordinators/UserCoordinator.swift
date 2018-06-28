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
}

extension UserCoordinator: UserViewModelDelegate {
  func didSelect(_ item: Item) {
    startItemCoordinator(item)
  }
}
