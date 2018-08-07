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
  
  private let itemTappedSubject = PublishSubject<()>()
  private let constraintTappedSubject = PublishSubject<()>()
  private let cancelTappedSubject = PublishSubject<()>()
  
  let itemTapped: AnyObserver<()>
  let constraintTapped: AnyObserver<()>
  let cancelTapped: AnyObserver<()>
  
  init(delegate: ViewModelDelegate, dataService: DataService = DataService()) {
    itemTapped = itemTappedSubject.asObserver()
    itemTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.send(.show(type: "addItem", id: nil))
      }
      }.disposed(by: disposeBag)
    constraintTapped = constraintTappedSubject.asObserver()
    constraintTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.send(.show(type: "addConstraint", id: nil))
      }
      }.disposed(by: disposeBag)
    cancelTapped = cancelTappedSubject.asObserver()
    cancelTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.send(.dismiss)
      }
      }.disposed(by: disposeBag)
  }
}

