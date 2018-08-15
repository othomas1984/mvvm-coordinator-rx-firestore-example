//
//  DetailViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import RxSwift

class DetailViewModel {
  private let disposeBag = DisposeBag()
  private let detailListenerHandle: DataListenerHandle
  private let constraintsListenerHandle: DataListenerHandle

  let titleButtonTapped = PublishSubject<()>()
  let pickerSelectionChanged = PublishSubject<(row: Int, component: Int)>()

  let detailName: Observable<String>
  let detailConstraint: Observable<String>
  let selectedIndex: Observable<Int>
  let pickerRowNames: Observable<[String]>

  init(_ detailPath: String, userPath: String, delegate: ViewModelDelegate, dataService: DataService = DataService()) {
    let detailSubject = PublishSubject<Detail>()
    let constraintsSubject = PublishSubject<[Constraint]>()
    let selectedIndexSubject = PublishSubject<Int>()

    // Setup Database Listeners
    detailListenerHandle = dataService.detailListener(path: detailPath) { detail in
      guard let detail = detail else { delegate.send(.dismiss); return }
      detailSubject.on(.next(detail))
    }
    constraintsListenerHandle = dataService.constraintsListener(userPath: userPath) {
      constraintsSubject.onNext($0.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
    }
    
    // Update UI elements
    detailName = detailSubject.map { $0.name }
    detailConstraint = detailSubject.map { $0.constraint }
    
    // Handle Title Button Taps
    titleButtonTapped.throttle(1.0, latest: false, scheduler: MainScheduler()).subscribe { event in
        if case let .next = event {
          delegate.send(.edit)
        }
      }.disposed(by: disposeBag)
    selectedIndex = selectedIndexSubject.asObservable()
    pickerRowNames = Observable.combineLatest(constraintsSubject, detailSubject).map { constraints, detail in
      var constraintNames = constraints.map { $0.name }
      if !constraintNames.contains(detail.constraint) {
        constraintNames.insert("[Select One]", at: 0)
      }
      constraintNames.append("[Add New Constraint]")
      return constraintNames
    }
    
    // Update picker selected item if either Detail or available Constraints change
    Observable.combineLatest(detailSubject, pickerRowNames).debounce(0.01, scheduler: MainScheduler()).subscribe { event in
      if let index = event.element?.1.index(where: {$0 == event.element?.0.constraint}) {
        selectedIndexSubject.onNext(index)
      } else {
        selectedIndexSubject.onNext(0)
      }
      }.disposed(by: disposeBag)
    
    // Handle picker selection changes
    pickerSelectionChanged
      .withLatestFrom(pickerRowNames) { ($0, $1) }
      .withLatestFrom(selectedIndexSubject) { ($0.0, $0.1, $1) }
      .subscribe { event in
      if case let .next(((index, _), pickerNames, selectedIndex)) = event {
        if index == pickerNames.count - 1 {
          delegate.send(.show(type: "addConstraint", id: nil))
          selectedIndexSubject.onNext(selectedIndex)
        } else {
          dataService.updateDetail(path: detailPath, with: ["constraint": pickerNames[index]], completion: nil)
        }
      }
    }.disposed(by: disposeBag)
  }
  
  deinit {
    detailListenerHandle.remove()
  }
}
