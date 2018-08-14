//
//  CreateItemViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/6/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation
import RxSwift

class CreateItemViewModel {
  private let disposeBag = DisposeBag()
  
  let addTapped: AnyObserver<String?>
  let cancelTapped: AnyObserver<()>
  
  init(userPath: String, delegate: ViewModelDelegate, dataService: DataService = DataService()) {
    let addTappedSubject = PublishSubject<String?>()
    addTapped = addTappedSubject.asObserver()
    addTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case let .next(name) = event {
        if let name = name, !name.isEmpty {
          dataService.createItem(userPath: userPath, with: name)
        }
        delegate.send(.dismiss)
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
