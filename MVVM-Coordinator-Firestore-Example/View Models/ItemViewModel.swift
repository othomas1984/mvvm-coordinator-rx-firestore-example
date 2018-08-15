//
//  ItemViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import RxSwift

class ItemViewModel {
  private let disposeBag = DisposeBag()
  
  private let titleSubject = PublishSubject<()>()
  private let addButtonSubject = PublishSubject<()>()
  private let detailSelectedSubject = PublishSubject<IndexPath>()
  private let detailDeletedSubject = PublishSubject<IndexPath>()
  private let detailsListenerHandle: DataListenerHandle
  private let itemListenerHandle: DataListenerHandle

  let itemName: Observable<String>
  let details: Observable<[Detail]>
  let titleTapped: AnyObserver<()>
  let addTapped: AnyObserver<()>
  let detailSelected: AnyObserver<IndexPath>
  let detailDeleted: AnyObserver<IndexPath>
  
  init(_ itemPath: String, userPath: String, delegate: ViewModelDelegate, dataService: DataService = DataService()) {
    // Item
    let itemSubject = BehaviorSubject<Item?>(value: nil)
    itemListenerHandle = dataService.itemListener(path: itemPath) { item in
      guard let item = item else { delegate.send(.dismiss); return }
      itemSubject.onNext(item)
    }
    itemName = itemSubject.map { $0?.name ?? "" }
    
    // Details List
    let detailsSubject = BehaviorSubject<[Detail]>(value: [])
    detailsListenerHandle = dataService.detailsListener(itemPath: itemPath) {
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
        delegate.send(.show(type: "detail", id: details[index].path))
      }.disposed(by: disposeBag)
    
    detailDeleted = detailDeletedSubject.asObserver()
    detailDeletedSubject.throttle(1.0, latest: false, scheduler: MainScheduler())
      .withLatestFrom(details) { (index, details) in
        return (index, details)
      }.subscribe { result in
        guard let index = result.element?.0.row,
          let details = result.element?.1, details.count > index else { return }
        dataService.deleteDetail(path: details[index].path) { error in
          if let error = error {
            print(error)
          }
        }
      }.disposed(by: disposeBag)
    
    // Title Button
    titleTapped = titleSubject.asObserver()
    titleSubject.throttle(1.0, latest: false, scheduler: MainScheduler()).subscribe { event in
        if case .next = event {
          delegate.send(.edit)
        }
      }.disposed(by: disposeBag)
    
    // Add Button
    addTapped = addButtonSubject.asObserver()
    addButtonSubject.throttle(1.0, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.send(.show(type: "addDetail", id: nil))
      }
      }.disposed(by: disposeBag)
  }
  
  deinit {
    detailsListenerHandle.remove()
    itemListenerHandle.remove()
  }
}
