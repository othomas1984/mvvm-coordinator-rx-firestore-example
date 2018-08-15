//
//  EditDetailViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/14/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation
import RxSwift

class EditDetailViewModel {
  private let disposeBag = DisposeBag()
  
  let okTapped: AnyObserver<()>
  let cancelTapped: AnyObserver<()>
  let detailNameToView: Observable<String>
  let detailNameFromView: AnyObserver<String>
  let detailLoading: Observable<Bool>
  
  init(detailPath: String, delegate: ViewModelDelegate, dataService: DataService = DataService()) {
    
    let detailSubject = Observable<Detail?>.create { (observer) -> Disposable in
      let handle = dataService.detailListener(path: detailPath) { detail in
        observer.onNext(detail)
      }
      return Disposables.create {
        handle.remove()
      }
    }
    detailNameToView = detailSubject.map { $0?.name ?? ""}
    detailLoading = detailSubject.map { $0 == nil }
    
    let detailNameFromViewSubject = PublishSubject<String>()
    detailNameFromView = detailNameFromViewSubject.asObserver()
    
    let okTappedSubject = PublishSubject<()>()
    okTapped = okTappedSubject.asObserver()
    okTappedSubject.withLatestFrom(detailNameFromViewSubject).throttle(1, latest: false, scheduler: MainScheduler()).subscribe { event in
      guard case let .next(name) = event else {
        return
      }
      guard !name.isEmpty else {
        delegate.send(.dismiss); return
      }
      dataService.updateDetail(path: detailPath, with: ["name": name], completion: nil)
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
