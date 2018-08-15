//
//  DetailCoordinator.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import UIKit

class DetailCoordinator: Coordinator {
  private var navigationController: UINavigationController
  private var detailPath: String
  private var userPath: String

  var childCoordinators = [Coordinator]()
  
  required init(_ navigationController: UINavigationController, detailPath: String, userPath: String) {
    self.detailPath = detailPath
    self.userPath = userPath
    self.navigationController = navigationController
  }
  
  func start() {
    showUserViewController()
  }
}

extension DetailCoordinator {
  private func showUserViewController() {
    let detailVM = DetailViewModel(detailPath, userPath: userPath, delegate: self)
    guard let detailVC = UIStoryboard.init(name: "Detail", bundle: nil).instantiateInitialViewController() as? DetailViewController else { assertionFailure(); return }
    detailVC.model = detailVM
    navigationController.pushViewController(detailVC, animated: true)
  }
  
  private func showEditDetailController() {
    let controller = EditDetailViewController()
    controller.model = EditDetailViewModel(detailPath: detailPath, delegate: self)
    controller.modalPresentationStyle = .overCurrentContext
    navigationController.present(controller, animated: false)
  }

  private func showAddConstraintController() {
    let controller = CreateConstraintViewController()
    controller.model = CreateConstraintViewModel(userPath: userPath, forDetailPath: detailPath, delegate: self)
    controller.modalPresentationStyle = .overCurrentContext
    navigationController.present(controller, animated: false)
  }
}

extension DetailCoordinator: ViewModelDelegate {
  func send(_ action: ViewModelAction) {
    switch action {
    case .edit:
      showEditDetailController()
    case let .show(type, _):
      switch type {
      case "addConstraint":
        showAddConstraintController()
      default:
        break
      }
      break
    case .dismiss:
      navigationController.dismiss(animated: true)
    }
  }
}
