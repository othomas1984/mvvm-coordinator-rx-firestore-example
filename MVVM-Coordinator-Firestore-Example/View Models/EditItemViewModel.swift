//
//  EditItemViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/13/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation
import RxSwift

class EditItemViewModel {
  private let disposeBag = DisposeBag()
  
  let okTapped: AnyObserver<()>
  let cancelTapped: AnyObserver<()>
  let itemNameToView: Observable<String>
  let itemNameFromView: AnyObserver<String>
  let itemLoading: Observable<Bool>
  
  init(itemPath: String, delegate: ViewModelDelegate, dataService: DataService = DataService()) {
    
    let itemSubject = Observable<Item?>.create { (observer) -> Disposable in
      let handle = dataService.itemListener(path: itemPath) { item in
        observer.onNext(item)
      }
      return Disposables.create {
        handle.remove()
      }
    }
    itemNameToView = itemSubject.map { $0?.name ?? ""}
    itemLoading = itemSubject.map { $0 == nil }
    
    let itemNameFromViewSubject = PublishSubject<String>()
    itemNameFromView = itemNameFromViewSubject.asObserver()
    
    let okTappedSubject = PublishSubject<()>()
    okTapped = okTappedSubject.asObserver()
    okTappedSubject.withLatestFrom(itemNameFromViewSubject).throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      guard case let .next(name) = event else {
        return
      }
      guard !name.isEmpty else {
        delegate.send(.dismiss); return
      }
      dataService.updateUser(path: itemPath, with: ["name": name], completion: nil)
      delegate.send(.dismiss); return
      }.disposed(by: disposeBag)
    
    let cancelTappedSubject = PublishSubject<()>()
    cancelTapped = cancelTappedSubject.asObserver()
    cancelTappedSubject.throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      if case .next = event {
        delegate.send(.dismiss)
      }
      }.disposed(by: disposeBag)
  }
}
