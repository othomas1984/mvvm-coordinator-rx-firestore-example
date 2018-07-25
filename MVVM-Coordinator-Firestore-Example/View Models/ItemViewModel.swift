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
  private let disposeBag = DisposeBag()
  
  private let titleSubject = PublishSubject<()>()
  private let addButtonSubject = PublishSubject<()>()
  private let detailSelectedSubject = PublishSubject<IndexPath>()
  private let detailDeletedSubject = PublishSubject<IndexPath>()
  private let detailsListenerHandle: ListenerRegistration
  private let itemListenerHandle: ListenerRegistration

  let itemName: Observable<String>
  let details: Observable<[Detail]>
  let titleTapped: AnyObserver<()>
  let addTapped: AnyObserver<()>
  let detailSelected: AnyObserver<IndexPath>
  let detailDeleted: AnyObserver<IndexPath>
  
  init(_ itemPath: String, userPath: String, delegate: ItemViewModelDelegate, firestoreService: FirestoreService.Type = FirestoreService.self) {
    // Item
    let itemSubject = BehaviorSubject<Item?>(value: nil)
    itemListenerHandle = firestoreService.itemListener(path: itemPath) { item in
      guard let item = item else { delegate.viewModelDidDismiss(); return }
      itemSubject.onNext(item)
    }
    itemName = itemSubject.map { $0?.name ?? "" }
    
    // Details List
    let detailsSubject = BehaviorSubject<[Detail]>(value: [])
    detailsListenerHandle = firestoreService.detailsListener(itemPath: itemPath) {
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
        firestoreService.deleteDetail(path: details[index].path) { error in
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
  
  deinit {
    detailsListenerHandle.remove()
    itemListenerHandle.remove()
  }
}
