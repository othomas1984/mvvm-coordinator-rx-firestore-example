//
//  DetailViewModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation
import RxSwift

protocol DetailViewModelDelegate: class {
}

class DetailViewModel {
  private weak var delegate: DetailViewModelDelegate?
  private var privateDetail: Variable<Detail>
  
  init(_ detail: Detail, delegate: DetailViewModelDelegate) {
    self.delegate = delegate
    privateDetail = Variable<Detail>(detail)
  }
  
  lazy var detailName: Observable<String> = {
    return privateDetail.asObservable().map { [unowned self] in $0.name }
  }()
  
  lazy var detailConstraint: Observable<String> = {
    return privateDetail.asObservable().map { [unowned self] in $0.constraint }
  }()
}
