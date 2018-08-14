//
//  EditUserViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/6/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation
import RxSwift

class EditUserViewModel {
  private let disposeBag = DisposeBag()
  
  let okTapped: AnyObserver<()>
  let cancelTapped: AnyObserver<()>
  let userNameToView: Observable<String>
  let userNameFromView: AnyObserver<String>
  let userLoading: Observable<Bool>
  
  init(userPath: String, delegate: ViewModelDelegate, dataService: DataService = DataService()) {
    
    let userSubject = Observable<User?>.create { (observer) -> Disposable in
      let userListenerHandle = dataService.userListener(path: userPath) { user in
        observer.onNext(user)
      }
      return Disposables.create {
        userListenerHandle.remove()
      }
    }
    userNameToView = userSubject.map { $0?.name ?? ""}
    userLoading = userSubject.map { $0 == nil }
    
    let userNameFromViewSubject = PublishSubject<String>()
    userNameFromView = userNameFromViewSubject.asObserver()
    
    let okTappedSubject = PublishSubject<()>()
    okTapped = okTappedSubject.asObserver()
    okTappedSubject.withLatestFrom(userNameFromViewSubject).throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      guard case let .next(name) = event else {
        return
      }
      guard !name.isEmpty else {
        delegate.send(.dismiss); return
      }
      dataService.updateUser(path: userPath, with: ["name": name], completion: nil)
      delegate.send(.dismiss); return
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

