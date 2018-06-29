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
  func select(_ user: User)
  func delete(_ user: User)
  func add()
}

class StartViewModel {
  private var privateUsers = Variable<[User]>([])
  private weak var delegate: StartViewModelDelegate?
  private var disposeBag = DisposeBag()
  
  init(delegate: StartViewModelDelegate) {
    self.delegate = delegate
    listenerHandle = FirestoreService.getUsers { [unowned self] in
      self.privateUsers.value = $0
    }
  }
  
  var listenerHandle: ListenerRegistration? {
    didSet {
      oldValue?.remove()
    }
  }
  
  deinit {
    listenerHandle?.remove()
  }
  
  lazy var users: Observable<[User]> = {
    privateUsers.asObservable()
      .map { $0.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending } }
  }()
  
  var userDeleted: Observable<(IndexPath)>? {
    didSet {
      userDeleted?.subscribe { [unowned self] event in
        guard let index = event.element?.row else { return }
        let user = self.privateUsers.value.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }[index]
        self.delegate?.delete(user)
        }.disposed(by: disposeBag)
    }
  }
  
  var userSelected: Observable<(IndexPath)>? {
    didSet {
      userSelected?.subscribe { [unowned self] event in
        guard let index = event.element?.row else { return }
        let user = self.privateUsers.value.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }[index]
        self.delegate?.select(user)
        }.disposed(by: disposeBag)
    }
  }
  
  var addButton: Observable<()>? {
    didSet {
      addButton?.subscribe { [unowned self] event in
        switch event {
        case .next:
          self.delegate?.add()
        case let .error(error):
          print(error)
        case .completed:
          break
        }
      }.disposed(by: disposeBag)
    }
  }
}

