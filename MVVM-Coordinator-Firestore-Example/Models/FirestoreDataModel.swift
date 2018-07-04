//
//  FirestoreDataModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation

protocol FirestoreDataModel {
  var id: String { get }
  var path: String { get }
}
