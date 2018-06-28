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
}

extension ItemCoordinator: ItemViewModelDelegate {
  func didSelect(_ detail: Detail) {
    startDetailCoordinator(detail)
  }
}

extension ItemCoordinator: DetailCoordinatorDelegate {
}
