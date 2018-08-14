//
//  CreateConstraintViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/6/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation
import RxSwift

class CreateConstraintViewModel {
  private let disposeBag = DisposeBag()
  
  let addTapped: AnyObserver<String?>
  let cancelTapped: AnyObserver<()>
  
  init(userPath: String, forDetailPath detailPath: String?, delegate: ViewModelDelegate, dataService: DataService = DataService()) {
    let addTappedSubject = PublishSubject<String?>()
    addTapped = addTappedSubject.asObserver()
    addTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      guard case let .next(optionalName) = event else {
        return
      }
      guard let name = optionalName, !name.isEmpty else {
        delegate.send(.dismiss); return
      }
      dataService.createConstraint(userPath: userPath, with: name) { constraint in
        guard let detailPath = detailPath, let constraint = constraint else {
          delegate.send(.dismiss); return
        }
        dataService.updateDetail(path: detailPath, with: ["constraint": constraint.name]) { _ in
          delegate.send(.dismiss)
        }
      }
      }.disposed(by: disposeBag)
    let cancelTappedSubject = PublishSubject<()>()
    cancelTapped = cancelTappedSubject.asObserver()
    cancelTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.send(.dismiss)
      }
      }.disposed(by: disposeBag)
  }
}
