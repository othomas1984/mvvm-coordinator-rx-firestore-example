//
//  StartViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation
import RxSwift

class StartViewModel {
  private let disposeBag = DisposeBag()

  let userDeleted: AnyObserver<IndexPath>
  let userSelected: AnyObserver<IndexPath>
  let addTapped: AnyObserver<()>
  let users: Observable<[User]>
  
  init(delegate: ViewModelDelegate, dataService: DataService = DataService()) {
    let usersSubject = Observable<[User]>.create { observer in
      let handle = dataService.usersListener {
        observer.onNext($0)
      }
      return Disposables.create {
        handle.remove()
      }
    }
    
    users = usersSubject
      .map { $0.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending } }
    
    let userSelectedSubject = PublishSubject<IndexPath>()
    userSelected = userSelectedSubject.asObserver()
    userSelectedSubject.throttle(1, latest: false, scheduler: MainScheduler())
      .withLatestFrom(users) { (index, users) in
        return (index, users)
      }.subscribe { result in
        guard let users = result.element?.1, let index = result.element?.0.row, users.count > index else { return }
        delegate.send(.show(type: "user", id: users[index].path))
      }.disposed(by: disposeBag)

    let userDeletedSubject = PublishSubject<IndexPath>()
    userDeleted = userDeletedSubject.asObserver()
    userDeletedSubject.throttle(1, latest: false, scheduler: MainScheduler())
      .withLatestFrom(users) { (index, users) in
        return (index, users)
      }.subscribe { result in
        guard let users = result.element?.1, let index = result.element?.0.row, users.count > index else { return }
        dataService.deleteUser(path: users[index].path) { error in
          if let error = error {
            print(error)
          }
        }
      }.disposed(by: disposeBag)

    let addTappedSubject = PublishSubject<()>()
    addTapped = addTappedSubject.asObserver()
    addTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.send(.show(type: "addUser", id: nil))
      }
    }.disposed(by: disposeBag)
  }
}
