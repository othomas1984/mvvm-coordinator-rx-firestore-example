//
//  StartViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RxSwift

protocol StartViewModelDelegate: class {
  func select(_ userPath: String)
  func add()
}

class StartViewModel {
  private let disposeBag = DisposeBag()
  private let usersListenerHandle: ListenerRegistration

  private let userDeletedSubject = PublishSubject<IndexPath>()
  private let userSelectedSubject = PublishSubject<IndexPath>()
  private let addTappedSubject = PublishSubject<()>()

  let userDeleted: AnyObserver<IndexPath>
  let userSelected: AnyObserver<IndexPath>
  let addTapped: AnyObserver<()>
  let users: Observable<[User]>
  
  init(delegate: StartViewModelDelegate, firestoreService: FirestoreService.Type = FirestoreService.self) {
    let userSubject = BehaviorSubject<[User]>(value: [])
    usersListenerHandle = firestoreService.usersListener {
      userSubject.onNext($0)
    }
    users = userSubject
      .map { $0.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending } }
    
    userSelected = userSelectedSubject.asObserver()
    userSelectedSubject.throttle(1, latest: false, scheduler: MainScheduler())
      .withLatestFrom(users) { (index, users) in
        return (index, users)
      }.subscribe { result in
        guard let users = result.element?.1, let index = result.element?.0.row, users.count > index else { return }
        delegate.select(users[index].path)
      }.disposed(by: disposeBag)

    userDeleted = userDeletedSubject.asObserver()
    userDeletedSubject.throttle(1, latest: false, scheduler: MainScheduler())
      .withLatestFrom(users) { (index, users) in
        return (index, users)
      }.subscribe { result in
        guard let users = result.element?.1, let index = result.element?.0.row, users.count > index else { return }
        firestoreService.deleteUser(path: users[index].path) { error in
          if let error = error {
            print(error)
          }
        }
      }.disposed(by: disposeBag)

    addTapped = addTappedSubject.asObserver()
    addTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.add()
      }
    }.disposed(by: disposeBag)
  }
  
  deinit {
    usersListenerHandle.remove()
  }
}

