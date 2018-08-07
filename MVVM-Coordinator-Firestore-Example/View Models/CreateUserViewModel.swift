//
//  CreateUserViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/6/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation

import Foundation
import RxSwift

// TODO: Do we still need to be class-only since we don't store the delegate anymore?
protocol CreateUserViewModelDelegate: class {
  func dismiss()
}

class CreateUserViewModel {
  private let disposeBag = DisposeBag()
  
  private let addTappedSubject = PublishSubject<String?>()
  private let cancelTappedSubject = PublishSubject<()>()

  let addTapped: AnyObserver<String?>
  let cancelTapped: AnyObserver<()>

  init(delegate: CreateUserViewModelDelegate, dataService: DataService = DataService()) {
    addTapped = addTappedSubject.asObserver()
    addTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case let .next(name) = event {
        if let name = name, !name.isEmpty {
          dataService.createUser(with: name)
        }
        delegate.dismiss()
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

