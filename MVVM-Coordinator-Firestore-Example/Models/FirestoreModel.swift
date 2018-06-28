//
//  FirestoreModel.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation
import FirebaseFirestore

protocol FirestoreModel {
  static var collectionPath: String { get }
  var path: DocumentReference { get }
  init(snapShot: DocumentSnapshot)
}
