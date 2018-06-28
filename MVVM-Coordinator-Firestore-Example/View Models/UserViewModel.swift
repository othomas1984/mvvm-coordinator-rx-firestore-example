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
  func didSelect(_ item: Item)
  func didDelete(_ item: Item)
  func didDelete(_ constraint: Constraint)
  func didTapAdd()
}

class UserViewModel {
  private var disposeBag = DisposeBag()
  private weak var delegate: UserViewModelDelegate?
  private var privateUser: Variable<User>
  private var privateItems = Variable<[Item]>([])
  private var privateConstraints = Variable<[Constraint]>([])

  init(_ user: User, delegate: UserViewModelDelegate) {
    self.delegate = delegate
    privateUser = Variable<User>(user)
    itemsListenerHandle = FirestoreService.getItems(userPath: user.path) { [unowned self] in
      self.privateItems.value = $0
    }
    constraintsListenerHandle = FirestoreService.getConstraints(userPath: user.path) { [unowned self] in
      self.privateConstraints.value = $0
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
    itemsListenerHandle?.remove()
    constraintsListenerHandle?.remove()
  }
  
  lazy var userName: Observable<String> = {
    return privateUser.asObservable().map { [unowned self] in $0.name }
  }()
  lazy var items: Observable<[Item]> = {
    privateItems.asObservable()
      .map { [unowned self] in $0.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending } }
  }()
  lazy var constraints: Observable<[Constraint]> = {
    privateConstraints.asObservable()
      .map { [unowned self] in $0.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending } }
  }()

  var itemDeleted: Observable<(IndexPath)>? {
    didSet {
      itemDeleted?.subscribe { [unowned self] event in
        guard let index = event.element?.row else { return }
        let item = self.privateItems.value.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }[index]
        self.delegate?.didDelete(item)
        }.disposed(by: disposeBag)
    }
  }
  
  var constraintDeleted: Observable<(IndexPath)>? {
    didSet {
      constraintDeleted?.subscribe { [unowned self] event in
        guard let index = event.element?.row else { return }
        let constraint = self.privateConstraints.value.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }[index]
        self.delegate?.didDelete(constraint)
        }.disposed(by: disposeBag)
    }
  }
  
  var itemSelected: Observable<(IndexPath)>? {
    didSet {
      itemSelected?.subscribe { [unowned self] event in
        guard let index = event.element?.row else { return }
        let item = self.privateItems.value.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }[index]
        self.delegate?.didSelect(item)
      }.disposed(by: disposeBag)
    }
  }
  
  var addButton: Observable<()>? {
    didSet {
      addButton?.subscribe { [unowned self] event in
        switch event {
        case .next:
          self.delegate?.didTapAdd()
        case let .error(error):
          print(error)
        case .completed:
          break
        }
      }.disposed(by: disposeBag)
    }
  }
}
