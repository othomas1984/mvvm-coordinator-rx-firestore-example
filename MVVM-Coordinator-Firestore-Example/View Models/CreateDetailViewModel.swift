//
//  CreateDetailViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/7/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation
import RxSwift

class CreateDetailViewModel {
  private let disposeBag = DisposeBag()
  
  private let addTappedSubject = PublishSubject<()>()
  private let cancelTappedSubject = PublishSubject<()>()
  private let nameTextSubject = PublishSubject<String?>()
  private let constraintTextSubject = PublishSubject<String?>()

  let nameText: AnyObserver<String?>
  let constraintText: AnyObserver<String?>
  let addTapped: AnyObserver<()>
  let cancelTapped: AnyObserver<()>
  
  init(itemPath: String, delegate: ViewModelDelegate, dataService: DataService = DataService()) {
    nameText = nameTextSubject.asObserver()
    constraintText = constraintTextSubject.asObserver()
    addTapped = addTappedSubject.asObserver()
    addTappedSubject
      .throttle(1, latest: false, scheduler: MainScheduler())
      .withLatestFrom(nameTextSubject)
      .withLatestFrom(constraintTextSubject) { ($0, $1) }.subscribe { event in
        guard case let .next(name, constraint) = event else { delegate.send(.dismiss); return }
        if let name = name, let constraint = constraint, !name.isEmpty, !constraint.isEmpty {
          dataService.createDetail(itemPath: itemPath, with: name, constraint: constraint)
        }
        delegate.send(.dismiss)
      }.disposed(by: disposeBag)
    cancelTapped = cancelTappedSubject.asObserver()
    cancelTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.send(.dismiss)
      }
      }.disposed(by: disposeBag)
  }
}
