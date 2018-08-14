//
//  CreateUserViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/6/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation
import RxSwift

class CreateUserViewModel {
  private let disposeBag = DisposeBag()
  
  let addTapped: AnyObserver<()>
  let cancelTapped: AnyObserver<()>
  let nameText: AnyObserver<String>

  init(delegate: ViewModelDelegate, dataService: DataService = DataService()) {
    let nameTextSubject = PublishSubject<String>()
    nameText = nameTextSubject.asObserver()
    let addTappedSubject = PublishSubject<()>()
    addTapped = addTappedSubject.asObserver()
    addTappedSubject
      .withLatestFrom(nameTextSubject)
      .throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
        guard case let .next(name) = event else { delegate.send(.dismiss); return }
        if !name.isEmpty {
          dataService.createUser(with: name)
        }
        delegate.send(.dismiss)
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

