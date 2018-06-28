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
  func didSelect(_ user: User)
  func didTapAdd()
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
      .map { $0.sorted { $0.name < $1.name } }
  }()
  
  func didSelect(_ index: Int) {
    delegate?.didSelect(privateUsers.value[index])
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

