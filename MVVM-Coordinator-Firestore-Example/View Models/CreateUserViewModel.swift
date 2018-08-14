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
  
  private let addTappedSubject = PublishSubject<()>()
  private let cancelTappedSubject = PublishSubject<()>()
  private let nameTextSubject = PublishSubject<String?>()

  let addTapped: AnyObserver<()>
  let cancelTapped: AnyObserver<()>
  let nameText: AnyObserver<String?>

  init(delegate: ViewModelDelegate, dataService: DataService = DataService()) {
    nameText = nameTextSubject.asObserver()
    addTapped = addTappedSubject.asObserver()
    addTappedSubject
      .withLatestFrom(nameTextSubject)
      .throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
        guard case let .next(name) = event else { delegate.send(.dismiss); return }
        if let name = name, !name.isEmpty {
          dataService.createUser(with: name)
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

