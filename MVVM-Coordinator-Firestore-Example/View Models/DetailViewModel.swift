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
  private let constraintSelectedSubject = PublishSubject<(row: Int, component: Int)>()
  private let detailListenerHandle: ListenerRegistration
  private let constraintsListenerHandle: ListenerRegistration
  
  let detailName: Observable<String>
  let detailConstraint: Observable<String>
  let titleButton: AnyObserver<()>
  let constraintSelected: AnyObserver<(row: Int, component: Int)>
  let constraints: Observable<[Constraint]>
  let selectedConstraint: Observable<Int?>

  init(_ detailPath: String, userPath: String, delegate: DetailViewModelDelegate) {
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
    
    let constraintsSubject = BehaviorSubject<[Constraint]>(value: [])
    constraintsListenerHandle = FirestoreService.constraintsListener(userPath: userPath) {
      constraintsSubject.onNext($0)
    }
    constraints = constraintsSubject.map {
      $0.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
    constraintSelected = constraintSelectedSubject.asObserver()
    constraintSelectedSubject.withLatestFrom(constraints) { (selection, constraints) in
      return (selection: selection, constraints: constraints)
    }.subscribe { event in
      if case let .next(result) = event {
        let constraint = result.constraints[result.selection.row]
        FirestoreService.updateDetail(path: detailPath, with: ["constraint": constraint.name], completion: nil)
      }
    }.disposed(by: disposeBag)
    
    selectedConstraint = Observable.combineLatest(constraints, detailSubject).map { (constraints, detail) in
      guard let detail = detail, let index = constraints.index(where: { $0.name == detail.constraint }) else { return nil }
      return index
    }
  }
  
  deinit {
    detailListenerHandle.remove()
  }
}
