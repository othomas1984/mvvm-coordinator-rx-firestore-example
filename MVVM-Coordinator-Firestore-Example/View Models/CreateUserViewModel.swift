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
  
  private let addTappedSubject = PublishSubject<String?>()
  private let cancelTappedSubject = PublishSubject<()>()

  let addTapped: AnyObserver<String?>
  let cancelTapped: AnyObserver<()>

  init(delegate: ViewModelDelegate, dataService: DataService = DataService()) {
    addTapped = addTappedSubject.asObserver()
    addTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case let .next(name) = event {
        if let name = name, !name.isEmpty {
          dataService.createUser(with: name)
        }
        delegate.send(.dismiss)
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

