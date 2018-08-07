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
  
  private var userPath: String
  private weak var delegate: UserCoordinatorDelegate?
  
  var childCoordinators = [Coordinator]()
  
  required init(_ navigationController: UINavigationController, delegate: UserCoordinatorDelegate, userPath: String) {
    self.delegate = delegate
    self.userPath = userPath
    navigationController.present(rootViewController, animated: true)
  }

  func start() {
    showUserViewController()
  }
}

extension UserCoordinator {
  private func showUserViewController() {
    let userVM = UserViewModel(userPath, delegate: self)
    guard let userVC = UIStoryboard.init(name: "User", bundle: nil).instantiateInitialViewController() as? UserViewController else { assertionFailure(); return }
    userVC.model = userVM
    userVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissCoordinator))
    navigationController.pushViewController(userVC, animated: false)
  }
  
  @objc func dismissCoordinator() {
    delegate?.userCoordinatorDidDismiss(self)
  }
  
  private func startItemCoordinator(_ itemPath: String) {
    let itemCoordinator = ItemCoordinator(navigationController, itemPath: itemPath, userPath: userPath)
    addChildCoordinator(itemCoordinator)
    itemCoordinator.start()
  }
  
  private func showChooseItemOrConstraintController() {
    let controller = ChooseItemOrConstraintViewController()
    controller.model = ChooseItemOrConstraintViewModel(delegate: self)
    controller.modalPresentationStyle = .overCurrentContext
    navigationController.present(controller, animated: false)
  }
  
  private func showAddItemController() {
    let controller = CreateItemViewController()
    controller.model = CreateItemViewModel(userPath: userPath, delegate: self)
    controller.modalPresentationStyle = .overCurrentContext
    navigationController.present(controller, animated: false)
  }
  
  private func showAddConstraintController() {
    let controller = CreateConstraintViewController()
    controller.model = CreateConstraintViewModel(userPath: userPath, forDetailPath: nil, delegate: self)
    controller.modalPresentationStyle = .overCurrentContext
    navigationController.present(controller, animated: false)
  }
  
  private func showEditUserController() {
    let controller = EditUserViewController()
    controller.model = EditUserViewModel(userPath: userPath, delegate: self)
    controller.modalPresentationStyle = .overCurrentContext
    navigationController.present(controller, animated: false)
  }
}

extension UserCoordinator: ViewModelDelegate {
  func send(_ action: ViewModelAction) {
    switch action {
    case .edit:
      showEditUserController()
    case let .show(type, id):
      switch type {
      case "addObject":
        showChooseItemOrConstraintController()
      case "item":
        if let id = id {
          startItemCoordinator(id)
        }
      case "addItem":
        navigationController.dismiss(animated: false) {
          self.showAddItemController()
        }
      case "addConstraint":
        navigationController.dismiss(animated: false) {
          self.showAddConstraintController()
        }
      default:
        break
      }
    case .dismiss:
      navigationController.dismiss(animated: true, completion: nil)
    }
  }
}
