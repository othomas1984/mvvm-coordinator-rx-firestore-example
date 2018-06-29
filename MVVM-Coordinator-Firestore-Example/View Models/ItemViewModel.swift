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
  func select(_ detail: Detail)
  func delete(_ detail: Detail)
  func add()
}

class ItemViewModel {
  private var disposeBag = DisposeBag()
  private weak var delegate: ItemViewModelDelegate?
  private var privateItem: Variable<Item>
  private var privateDetails = Variable<[Detail]>([])
  
  init(_ item: Item, delegate: ItemViewModelDelegate) {
    self.delegate = delegate
    privateItem = Variable<Item>(item)
    detailsListenerHandle = FirestoreService.getDetails(userPath: item.path) { [unowned self] in
      self.privateDetails.value = $0
    }
    itemListenerHandle = FirestoreService.itemListener(item: item) { [unowned self] item in
      // TODO: Shoudl probably dismiss this VC if the user no longer exists
      guard let item = item else { print("Object seems to have been deleted"); return }
      
      self.privateItem.value = item
    }
  }
  
  var detailsListenerHandle: ListenerRegistration? {
    didSet {
      oldValue?.remove()
    }
  }
  
  var itemListenerHandle: ListenerRegistration? {
    didSet {
      oldValue?.remove()
    }
  }
  
  deinit {
    detailsListenerHandle?.remove()
    itemListenerHandle?.remove()
  }
  
  lazy var itemName: Observable<String> = {
    return privateItem.asObservable().map { [unowned self] in $0.name }
  }()
  lazy var details: Observable<[Detail]> = {
    privateDetails.asObservable()
      .map { [unowned self] in $0.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending } }
  }()
  
  var detailDeleted: Observable<(IndexPath)>? {
    didSet {
      detailDeleted?.subscribe { [unowned self] event in
        guard let index = event.element?.row else { return }
        let detail = self.privateDetails.value.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }[index]
        self.delegate?.delete(detail)
        }.disposed(by: disposeBag)
    }
  }
  
  var detailSelected: Observable<(IndexPath)>? {
    didSet {
      detailSelected?.subscribe { [unowned self] event in
        guard let index = event.element?.row else { return }
        let detail = self.privateDetails.value.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }[index]
        self.delegate?.select(detail)
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
