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
  
  init(delegate: ChooseItemOrConstraintViewModelDelegate, dataService: DataService = DataService()) {
    itemTapped = itemTappedSubject.asObserver()
    itemTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.selectedItem()
      }
      }.disposed(by: disposeBag)
    constraintTapped = constraintTappedSubject.asObserver()
    constraintTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.selectedConstraint()
      }
      }.disposed(by: disposeBag)
    cancelTapped = cancelTappedSubject.asObserver()
    cancelTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.chooseItemOrConstraintDidDismiss()
      }
      }.disposed(by: disposeBag)
  }
}

