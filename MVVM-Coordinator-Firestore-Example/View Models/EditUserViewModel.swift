//
//  EditUserViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/6/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation
import RxSwift

protocol EditUserViewModelDelegate: class {
  func editUserViewModelDismiss()
}

class EditUserViewModel {
  private let disposeBag = DisposeBag()
  
  private let okTappedSubject = PublishSubject<String?>()
  private let cancelTappedSubject = PublishSubject<()>()
  private let userListenerHandle: DataListenerHandle

  let okTapped: AnyObserver<String?>
  let cancelTapped: AnyObserver<()>
  let userName: Observable<String>
  
  init(userPath: String, delegate: CoordinatorDelegate, dataService: DataService = DataService()) {
    let userSubject = BehaviorSubject<User?>(value: nil)
    userListenerHandle = dataService.userListener(path: userPath) { user in
      userSubject.onNext(user)
    }
    userName = userSubject.map { $0?.name ?? ""}

    okTapped = okTappedSubject.asObserver()
    okTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      guard case let .next(optionalName) = event else {
        return
      }
      guard let name = optionalName, !name.isEmpty else {
        delegate.dismiss(); return
      }
      dataService.updateUser(path: userPath, with: ["name": name], completion: nil)
      delegate.dismiss(); return
      }.disposed(by: disposeBag)
    cancelTapped = cancelTappedSubject.asObserver()
    cancelTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.dismiss()
      }
      }.disposed(by: disposeBag)
  }
  
  deinit {
    userListenerHandle.remove()
  }
}

