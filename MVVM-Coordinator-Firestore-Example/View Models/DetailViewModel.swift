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
  private var disposeBag = DisposeBag()
  private var titleSubject = PublishSubject<()>()

  var detailName: Observable<String>
  var detailConstraint: Observable<String>
  var titleButton: AnyObserver<()>
  
  init(_ detailPath: String, delegate: DetailViewModelDelegate) {
    let detailSubject = BehaviorSubject<Detail?>(value: nil)
    detailName = detailSubject.map { $0?.name ?? "" }
    detailConstraint = detailSubject.map { $0?.constraint ?? "" }
    titleButton = titleSubject.asObserver()
    titleSubject.throttle(1.0, latest: false, scheduler: MainScheduler()).subscribe { event in
      do {
        if case .next = event, let detail = try detailSubject.value() {
          delegate.edit(detail)
        }
      } catch { print(error) }
    }.disposed(by: disposeBag)
    detailListenerHandle = FirestoreService.detailListener(path: detailPath) { detail in
      guard let detail = detail else { delegate.viewModelDidDismiss(); return }
      detailSubject.on(.next(detail))
    }
  }
  
  private var detailListenerHandle: ListenerRegistration? {
    didSet {
      oldValue?.remove()
    }
  }
  
  deinit {
    detailListenerHandle?.remove()
  }
}
