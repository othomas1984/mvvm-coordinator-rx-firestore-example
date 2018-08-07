//
//  UserViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import RxSwift

protocol UserViewModelDelegate: class {
  func select(_ itemPath: String)
  func edit()
  func add()
  func viewModelDidDismiss()
}

class UserViewModel {
  private let disposeBag = DisposeBag()
  private let userListenerHandle: DataListenerHandle
  private let itemsListenerHandle: DataListenerHandle
  private let constraintsListenerHandle: DataListenerHandle
  
  private let titleSubject = PublishSubject<()>()
  private let addButtonSubject = PublishSubject<()>()
  private let itemSelectedSubject = PublishSubject<IndexPath>()
  private let itemDeletedSubject = PublishSubject<IndexPath>()
  private let constraintSelectedSubject = PublishSubject<IndexPath>()
  private let constraintDeletedSubject = PublishSubject<IndexPath>()

  let userName: Observable<String>
  let items: Observable<[Item]>
  let constraints: Observable<[Constraint]>
  let titleTapped: AnyObserver<()>
  let addTapped: AnyObserver<()>
  let itemSelected: AnyObserver<IndexPath>
  let itemDeleted: AnyObserver<IndexPath>
  let constraintDeleted: AnyObserver<IndexPath>

  init(_ userPath: String, delegate: UserViewModelDelegate, dataService: DataService = DataService()) {
    // User
    let userSubject = BehaviorSubject<User?>(value: nil)
    userListenerHandle = dataService.userListener(path: userPath) { user in
      guard let user = user else { delegate.viewModelDidDismiss(); return }
      userSubject.onNext(user)
    }
    userName = userSubject.map { $0?.name ?? "Unknown User"}

    // Items
    let itemsSubject = BehaviorSubject<[Item]>(value: [])
    itemsListenerHandle = dataService.itemsListener(userPath: userPath) {
      itemsSubject.onNext($0)
    }
    items = itemsSubject.map {
      $0.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    // Constraints
    let constraintsSubject = BehaviorSubject<[Constraint]>(value: [])
    constraintsListenerHandle = dataService.constraintsListener(userPath: userPath) {
      constraintsSubject.onNext($0)
    }
    constraints = constraintsSubject.map {
      $0.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
    
    // Item Actions
    itemSelected = itemSelectedSubject.asObserver()
    itemSelectedSubject.throttle(1.0, latest: false, scheduler: MainScheduler())
      .withLatestFrom(items) { (index, items) in
        return (index, items)
      }.subscribe { result in
        guard let index = result.element?.0.row,
          let items = result.element?.1, items.count > index else { return }
        delegate.select(items[index].path)
      }.disposed(by: disposeBag)
    
    itemDeleted = itemDeletedSubject.asObserver()
    itemDeletedSubject.throttle(1.0, latest: false, scheduler: MainScheduler())
      .withLatestFrom(items) { (index, items) in
        return (index, items)
      }.subscribe { result in
        guard let index = result.element?.0.row,
          let items = result.element?.1, items.count > index else { return }
        dataService.deleteItem(path: items[index].path) { error in
          if let error = error {
            print(error)
          }
        }
      }.disposed(by: disposeBag)
    
    // Constraint Actions
    constraintDeleted = constraintDeletedSubject.asObserver()
    constraintDeletedSubject.throttle(1.0, latest: false, scheduler: MainScheduler())
      .withLatestFrom(constraints) { (index, constraints) in
        return (index, constraints)
      }.subscribe { result in
        guard let index = result.element?.0.row,
          let constraints = result.element?.1, constraints.count > index else { return }
        dataService.deleteConstraint(path: constraints[index].path) { error in
          if let error = error {
            print(error)
          }
        }
      }.disposed(by: disposeBag)
    
    // Title Button
    titleTapped = titleSubject.asObserver()
    titleSubject.throttle(1.0, latest: false, scheduler: MainScheduler())
      .withLatestFrom(userSubject).subscribe { event in
        if case let .next(userOptional) = event, let user = userOptional {
          delegate.edit()
        }
      }.disposed(by: disposeBag)
    
    // Add Button
    addTapped = addButtonSubject.asObserver()
    addButtonSubject.throttle(1.0, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.add()
      }
      }.disposed(by: disposeBag)
  }
  
  deinit {
    userListenerHandle.remove()
    itemsListenerHandle.remove()
    constraintsListenerHandle.remove()
  }
}
