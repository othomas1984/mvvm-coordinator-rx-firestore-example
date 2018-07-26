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
  func addConstraint()
  func viewModelDidDismiss()
}

class DetailViewModel {
  private let disposeBag = DisposeBag()
  private let detailListenerHandle: ListenerRegistration
  private let constraintsListenerHandle: ListenerRegistration

  let titleButtonTapped = PublishSubject<()>()
  let pickerSelectionChanged = PublishSubject<(row: Int, component: Int)>()

  let detailName: Observable<String>
  let detailConstraint: Observable<String>
  let selectedIndex: Observable<Int>
  let pickerRowNames: Observable<[String]>

  init(_ detailPath: String, userPath: String, delegate: DetailViewModelDelegate, firestoreService: FirestoreService.Type = FirestoreService.self) {
    let detailSubject = PublishSubject<Detail>()
    let constraintsSubject = PublishSubject<[Constraint]>()
    let selectedIndexSubject = PublishSubject<Int>()

    // Setup Database Listeners
    detailListenerHandle = FirestoreService.detailListener(path: detailPath) { detail in
      guard let detail = detail else { delegate.viewModelDidDismiss(); return }
      detailSubject.on(.next(detail))
    }
    constraintsListenerHandle = FirestoreService.constraintsListener(userPath: userPath) {
      constraintsSubject.onNext($0.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
    }
    
    // Update UI elements
    detailName = detailSubject.map { $0.name }
    detailConstraint = detailSubject.map { $0.constraint }
    
    // Handle Title Button Taps
    titleButtonTapped.throttle(1.0, latest: false, scheduler: MainScheduler())
      .withLatestFrom(detailSubject).subscribe { event in
        if case let .next(detail) = event {
          delegate.edit(detail)
        }
      }.disposed(by: disposeBag)
    selectedIndex = selectedIndexSubject.asObservable()
    pickerRowNames = constraintsSubject.map { constraints in
        var constraintNames = constraints.map { $0.name }
        constraintNames.append("[Add New Constraint]")
        return constraintNames
    }
    
    // Update picker selected item if either Detail or available Constraints change
    Observable.combineLatest(detailSubject, constraintsSubject).debounce(0.01, scheduler: MainScheduler()).subscribe { event in
      if let index = event.element?.1.index(where: {$0.name == event.element?.0.constraint}) {
        selectedIndexSubject.onNext(index)
      }
      }.disposed(by: disposeBag)
    
    // Handle picker selection changes
    pickerSelectionChanged
      .withLatestFrom(constraintsSubject) { ($0, $1) }
      .withLatestFrom(selectedIndexSubject) { ($0.0, $0.1, $1) }
      .subscribe { event in
      if case let .next(((index, _), constraints, selectedIndex)) = event {
        if index == constraints.count {
          delegate.addConstraint()
          selectedIndexSubject.onNext(selectedIndex)
        } else {
          firestoreService.updateDetail(path: detailPath, with: ["constraint": constraints[index].name], completion: nil)
          selectedIndexSubject.onNext(index)
        }
      }
    }.disposed(by: disposeBag)
  }
  
  deinit {
    detailListenerHandle.remove()
  }
}
