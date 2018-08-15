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
    let controller = CreateDetailViewController()
    controller.model = CreateDetailViewModel(itemPath: itemPath, delegate: self)
    controller.modalPresentationStyle = .overCurrentContext
    navigationController.present(controller, animated: false)
  }
  
  private func showEditItemController() {
    let controller = EditItemViewController()
    controller.model = EditItemViewModel(itemPath: itemPath, delegate: self)
    controller.modalPresentationStyle = .overCurrentContext
    navigationController.present(controller, animated: false)
  }
}

extension ItemCoordinator: ViewModelDelegate {
  func send(_ action: ViewModelAction) {
    switch action {
    case .dismiss:
      navigationController.dismiss(animated: false)
    case .edit:
      showEditItemController()
    case let .show(type, id):
      switch type {
      case "detail":
        guard let id = id else { return }
        startDetailCoordinator(id)
      case "addDetail":
        showAddDetailController()
      default:
        break
      }
    }
  }
}
