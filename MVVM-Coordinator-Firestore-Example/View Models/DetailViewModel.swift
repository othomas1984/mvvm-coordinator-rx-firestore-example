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
}

class DetailViewModel {
  private weak var delegate: DetailViewModelDelegate?
  private var disposeBag = DisposeBag()
  private var privateDetail: Variable<Detail>
  
  init(_ detail: Detail, delegate: DetailViewModelDelegate) {
    self.delegate = delegate
    privateDetail = Variable<Detail>(detail)
    detailListenerHandle = FirestoreService.detailListener(detail: detail) { [unowned self] detail in
      // TODO: Shoudl probably dismiss this VC if the user no longer exists
      guard let detail = detail else { print("Object seems to have been deleted"); return }
      
      self.privateDetail.value = detail
    }
  }
  
  var detailListenerHandle: ListenerRegistration? {
    didSet {
      oldValue?.remove()
    }
  }
  
  deinit {
    detailListenerHandle?.remove()
  }

  lazy var detailName: Observable<String> = {
    return privateDetail.asObservable().map { [unowned self] in $0.name }
  }()
  
  lazy var detailConstraint: Observable<String> = {
    return privateDetail.asObservable().map { [unowned self] in $0.constraint }
  }()
  
  var titleButton: Observable<()>? {
    didSet {
      titleButton?.subscribe { [unowned self] event in
        switch event {
        case .next:
          self.delegate?.edit(self.privateDetail.value)
        case let .error(error):
          print(error)
        case .completed:
          break
        }
        }.disposed(by: disposeBag)
    }
  }
}
