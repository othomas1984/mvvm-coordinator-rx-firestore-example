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
  
  private func showEditDetailController(_ detail: Detail) {
    // This would be it's own view controller managed by this coordinator eventually
    let ac = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
    ac.addTextField { (textField) in
      textField.text = detail.name
    }
    ac.addTextField { (textField) in
      textField.text = detail.constraint
    }
    let okAction = UIAlertAction(title: "Ok", style: .default) { action in
      if let name = ac.textFields?.first?.text, !name.isEmpty,
        ac.textFields?.count ?? 0 > 1, let constraint = ac.textFields?[1].text, !constraint.isEmpty {
        
        FirestoreService.updateDetail(path: detail.path, with: ["name": name, "constraint": constraint]) { error in
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

extension DetailCoordinator: DetailViewModelDelegate {
  func edit(_ detail: Detail) {
    showEditDetailController(detail)
  }
  
  func dismiss() {
    navigationController.dismiss(animated: true)
  }
}
