//
//  Item.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Item: FirestoreModel {
  static var collectionPath: String = "items"
  var path: DocumentReference
  var name: String
  
  required init(snapShot: DocumentSnapshot) {
    self.path = snapShot.reference
    let data = snapShot.data() ?? [String: Any]()
    self.name = data["name"] as? String ?? "Unknown Name"
  }
}
