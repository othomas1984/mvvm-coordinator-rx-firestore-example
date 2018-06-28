//
//  Detail.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Detail: FirestoreModel {
  static var collectionPath: String = "details"
  var path: DocumentReference
  var name: String
  var constraint: String

  required init(snapShot: DocumentSnapshot) {
    self.path = snapShot.reference
    let data = snapShot.data() ?? [String: Any]()
    self.name = data["name"] as? String ?? "Unknown Name"
    self.constraint = data["constraint"] as? String ?? "Unknown Constraint"
  }
}
