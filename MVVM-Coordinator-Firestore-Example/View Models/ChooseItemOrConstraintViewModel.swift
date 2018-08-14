//
//  ChooseItemOrConstraintViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/6/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation
import RxSwift

class ChooseItemOrConstraintViewModel {
  private let disposeBag = DisposeBag()
  
  let itemTapped: AnyObserver<()>
  let constraintTapped: AnyObserver<()>
  let cancelTapped: AnyObserver<()>
  
  init(delegate: ViewModelDelegate, dataService: DataService = DataService()) {
    let itemTappedSubject = PublishSubject<()>()
    itemTapped = itemTappedSubject.asObserver()
    itemTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.send(.show(type: "addItem", id: nil))
      }
      }.disposed(by: disposeBag)
    let constraintTappedSubject = PublishSubject<()>()
    constraintTapped = constraintTappedSubject.asObserver()
    constraintTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.send(.show(type: "addConstraint", id: nil))
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

