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
  private var detail: Detail
  
  var childCoordinators = [Coordinator]()
  
  required init(_ navigationController: UINavigationController, detail: Detail) {
    self.detail = detail
    self.navigationController = navigationController
  }
  
  func start() {
    showUserViewController()
  }
}

extension DetailCoordinator {
  private func showUserViewController() {
    let detailVM = DetailViewModel(detail, delegate: self)
    guard let detailVC = UIStoryboard.init(name: "Detail", bundle: nil).instantiateInitialViewController() as? DetailViewController else { assertionFailure(); return }
    detailVC.model = detailVM
    navigationController.pushViewController(detailVC, animated: true)
  }
}

extension DetailCoordinator: DetailViewModelDelegate {
}
