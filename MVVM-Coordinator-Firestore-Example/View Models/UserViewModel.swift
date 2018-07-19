//
//  UserViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import FirebaseFirestore
import RxSwift

protocol UserViewModelDelegate: class {
  func select(_ itemPath: String)
  func edit(_ user: User)
  func add()
  func viewModelDidDismiss()
}

class UserViewModel {
  private var disposeBag = DisposeBag()
  
  private var titleSubject = PublishSubject<()>()
  private var addButtonSubject = PublishSubject<()>()
  private var itemSelectedSubject = PublishSubject<IndexPath>()
  private var itemDeletedSubject = PublishSubject<IndexPath>()
  private var constraintSelectedSubject = PublishSubject<IndexPath>()
  private var constraintDeletedSubject = PublishSubject<IndexPath>()

  var userName: Observable<String>
  var items: Observable<[Item]>
  var constraints: Observable<[Constraint]>
  var titleTapped: AnyObserver<()>
  var addTapped: AnyObserver<()>
  var itemSelected: AnyObserver<IndexPath>
  var itemDeleted: AnyObserver<IndexPath>
  var constraintDeleted: AnyObserver<IndexPath>

  init(_ user: User, delegate: UserViewModelDelegate) {
    // User
    let userSubject = BehaviorSubject<User?>(value: nil)
    userListenerHandle = FirestoreService.userListener(path: user.path) { user in
      guard let user = user else { delegate.viewModelDidDismiss(); return }
      userSubject.onNext(user)
    }
    userName = userSubject.map { $0?.name ?? "Unknown User"}

    // Items
    let itemsSubject = BehaviorSubject<[Item]>(value: [])
    items = itemsSubject.map {
      $0.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    // Constraints
    let constraintsSubject = BehaviorSubject<[Constraint]>(value: [])
    itemsListenerHandle = FirestoreService.itemsListener(userPath: user.path) {
      itemsSubject.onNext($0)
    }
    constraintsListenerHandle = FirestoreService.constraintsListener(userPath: user.path) {
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
        FirestoreService.deleteItem(path: items[index].path) { error in
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
        FirestoreService.deleteConstraint(path: constraints[index].path) { error in
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
          delegate.edit(user)
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
  
  var userListenerHandle: ListenerRegistration? {
    didSet {
      oldValue?.remove()
    }
  }
  
  var itemsListenerHandle: ListenerRegistration? {
    didSet {
      oldValue?.remove()
    }
  }
  
  var constraintsListenerHandle: ListenerRegistration? {
    didSet {
      oldValue?.remove()
    }
  }
  
  deinit {
    userListenerHandle?.remove()
    itemsListenerHandle?.remove()
    constraintsListenerHandle?.remove()
  }
}
