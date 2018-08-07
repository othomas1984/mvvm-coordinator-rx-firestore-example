//
//  ChooseItemOrConstraintViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/6/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation
import RxSwift

protocol ChooseItemOrConstraintViewModelDelegate: class {
  func selectedItem()
  func selectedConstraint()
  func chooseItemOrConstraintDidDismiss()
}

class ChooseItemOrConstraintViewModel {
  private let disposeBag = DisposeBag()
  
  private let itemTappedSubject = PublishSubject<()>()
  private let constraintTappedSubject = PublishSubject<()>()
  private let cancelTappedSubject = PublishSubject<()>()
  
  let itemTapped: AnyObserver<()>
  let constraintTapped: AnyObserver<()>
  let cancelTapped: AnyObserver<()>
  
  init(delegate: CoordinatorDelegate, dataService: DataService = DataService()) {
    itemTapped = itemTappedSubject.asObserver()
    itemTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.select(type: "item", item: nil)
      }
      }.disposed(by: disposeBag)
    constraintTapped = constraintTappedSubject.asObserver()
    constraintTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.select(type: "constraint", item: nil)
      }
      }.disposed(by: disposeBag)
    cancelTapped = cancelTappedSubject.asObserver()
    cancelTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.dismiss()
      }
      }.disposed(by: disposeBag)
  }
}

