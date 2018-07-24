//
//  DetailViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import FirebaseFirestore
import RxSwift

protocol DetailViewModelDelegate: class {
  func edit(_ detail: Detail)
  func viewModelDidDismiss()
}

class DetailViewModel {
  private let disposeBag = DisposeBag()
  private let titleSubject = PublishSubject<()>()
  private let detailListenerHandle: ListenerRegistration

  let detailName: Observable<String>
  let detailConstraint: Observable<String>
  let titleButton: AnyObserver<()>
  
  init(_ detailPath: String, delegate: DetailViewModelDelegate) {
    let detailSubject = BehaviorSubject<Detail?>(value: nil)
    detailName = detailSubject.map { $0?.name ?? "" }
    detailConstraint = detailSubject.map { $0?.constraint ?? "" }
    titleButton = titleSubject.asObserver()
    titleSubject.throttle(1.0, latest: false, scheduler: MainScheduler())
      .withLatestFrom(detailSubject).subscribe { event in
        if case let .next(detailOptional) = event, let detail = detailOptional {
          delegate.edit(detail)
        }
      }.disposed(by: disposeBag)
    detailListenerHandle = FirestoreService.detailListener(path: detailPath) { detail in
      guard let detail = detail else { delegate.viewModelDidDismiss(); return }
      detailSubject.on(.next(detail))
    }
  }
  
  deinit {
    detailListenerHandle.remove()
  }
}
