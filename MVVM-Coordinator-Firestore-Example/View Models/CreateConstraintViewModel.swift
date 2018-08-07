//
//  CreateConstraintViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/6/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation
import RxSwift

protocol CreateConstraintViewModelDelegate: class {
  func createConstraintViewModelDismiss()
}

class CreateConstraintViewModel {
  private let disposeBag = DisposeBag()
  
  private let addTappedSubject = PublishSubject<String?>()
  private let cancelTappedSubject = PublishSubject<()>()
  
  let addTapped: AnyObserver<String?>
  let cancelTapped: AnyObserver<()>
  
  init(userPath: String, forDetailPath detailPath: String?, delegate: CreateConstraintViewModelDelegate, dataService: DataService = DataService()) {
    addTapped = addTappedSubject.asObserver()
    addTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      guard case let .next(optionalName) = event, let name = optionalName, !name.isEmpty else {
        delegate.createConstraintViewModelDismiss(); return
      }
      dataService.createConstraint(userPath: userPath, with: name) { constraint in
        guard let detailPath = detailPath, let constraint = constraint else {
          delegate.createConstraintViewModelDismiss(); return
        }
        dataService.updateDetail(path: detailPath, with: ["constraint": constraint.name]) { _ in
          delegate.createConstraintViewModelDismiss()
        }
      }
      }.disposed(by: disposeBag)
    cancelTapped = cancelTappedSubject.asObserver()
    cancelTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.createConstraintViewModelDismiss()
      }
      }.disposed(by: disposeBag)
  }
}
