//
//  User.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import FirebaseFirestore

struct User: FirestoreDataModel, Codable {
  let id: String
  let path: String
  let name: String
}
