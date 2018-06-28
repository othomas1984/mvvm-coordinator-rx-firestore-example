//
//  ItemViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import FirebaseFirestore
import RxSwift

protocol ItemViewModelDelegate: class {
  func didSelect(_ detail: Detail)
  func didTapAdd()
}

class ItemViewModel {
  private var disposeBag = DisposeBag()
  private weak var delegate: ItemViewModelDelegate?
  private var privateItem: Variable<Item>
  private var privateDetails = Variable<[Detail]>([])
  
  init(_ item: Item, delegate: ItemViewModelDelegate) {
    self.delegate = delegate
    privateItem = Variable<Item>(item)
    listenerHandle = FirestoreService.getDetails(userPath: item.path) { [unowned self] in
      self.privateDetails.value = $0
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
  
  lazy var itemName: Observable<String> = {
    return privateItem.asObservable().map { [unowned self] in $0.name }
  }()
  lazy var details: Observable<[Detail]> = {
    privateDetails.asObservable()
      .map { [unowned self] in $0.sorted { $0.name < $1.name } }
  }()
  
  func didSelect(_ index: Int) {
    delegate?.didSelect(privateDetails.value[index])
  
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
