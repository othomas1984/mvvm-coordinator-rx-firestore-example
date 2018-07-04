//
//  Constraint.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation

struct Constraint: FirestoreDataModel, Codable {
  let id: String
  let path: String
  let name: String
}
