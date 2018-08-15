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
  
  let nameText: AnyObserver<String>
  let addTapped: AnyObserver<()>
  let cancelTapped: AnyObserver<()>
  
  init(itemPath: String, delegate: ViewModelDelegate, dataService: DataService = DataService()) {
    let nameTextSubject = PublishSubject<String>()
    nameText = nameTextSubject.asObserver()
    let addTappedSubject = PublishSubject<()>()
    addTapped = addTappedSubject.asObserver()
    addTappedSubject
      .throttle(1, latest: false, scheduler: MainScheduler())
      .withLatestFrom(nameTextSubject)
      .subscribe { event in
        guard case let .next(name) = event else { delegate.send(.dismiss); return }
        if !name.isEmpty {
          dataService.createDetail(itemPath: itemPath, with: name)
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
