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
  func select(_ detailPath: String)
  func edit(_ item: Item)
  func add()
  func viewModelDidDismiss()
}

class ItemViewModel {
  private var disposeBag = DisposeBag()
  
  private var titleSubject = PublishSubject<()>()
  private var addButtonSubject = PublishSubject<()>()
  private var detailSelectedSubject = PublishSubject<IndexPath>()
  private var detailDeletedSubject = PublishSubject<IndexPath>()
  
  var itemName: Observable<String>
  var details: Observable<[Detail]>
  var titleTapped: AnyObserver<()>
  var addTapped: AnyObserver<()>
  var detailSelected: AnyObserver<IndexPath>
  var detailDeleted: AnyObserver<IndexPath>
  
  init(_ item: Item, delegate: ItemViewModelDelegate) {
    // Item
    let itemSubject = BehaviorSubject<Item?>(value: nil)
    itemListenerHandle = FirestoreService.itemListener(path: item.path) { item in
      guard let item = item else { delegate.viewModelDidDismiss(); return }
      itemSubject.onNext(item)
    }
    itemName = itemSubject.map { $0?.name ?? "" }
    
    // Details List
    let detailsSubject = BehaviorSubject<[Detail]>(value: [])
    detailsListenerHandle = FirestoreService.detailsListener(itemPath: item.path) {
      detailsSubject.onNext($0)
    }
    details = detailsSubject.map {
      $0.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
    
    // Detail Actions
    detailSelected = detailSelectedSubject.asObserver()
    detailSelectedSubject.throttle(1.0, latest: false, scheduler: MainScheduler())
      .withLatestFrom(details) { (index, details) in
        return (index, details)
      }.subscribe { result in
        guard let index = result.element?.0.row,
          let details = result.element?.1, details.count > index else { return }
        delegate.select(details[index].path)
      }.disposed(by: disposeBag)
    
    detailDeleted = detailDeletedSubject.asObserver()
    detailDeletedSubject.throttle(1.0, latest: false, scheduler: MainScheduler())
      .withLatestFrom(details) { (index, details) in
        return (index, details)
      }.subscribe { result in
        guard let index = result.element?.0.row,
          let details = result.element?.1, details.count > index else { return }
        FirestoreService.deleteDetail(path: details[index].path) { error in
          if let error = error {
            print(error)
          }
        }
      }.disposed(by: disposeBag)
    
    // Title Button
    titleTapped = titleSubject.asObserver()
    titleSubject.throttle(1.0, latest: false, scheduler: MainScheduler())
      .withLatestFrom(itemSubject).subscribe { event in
        if case let .next(itemOptional) = event, let item = itemOptional {
          delegate.edit(item)
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
}
