//
//  ViewModelDelegate.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/7/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

enum ViewModelAction {
  case edit
  case show(type: String, id: String?)
  case dismiss
}

protocol ViewModelDelegate {
  func send(_ action: ViewModelAction)
}
