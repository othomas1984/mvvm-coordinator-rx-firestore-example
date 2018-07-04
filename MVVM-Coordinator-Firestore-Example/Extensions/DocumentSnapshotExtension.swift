//
//  DocumentSnapshotExtension.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 7/4/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import FirebaseFirestore

extension DocumentSnapshot {
  func `as`<T: Decodable>(_ type: T.Type) -> T? {
    return (data()?.merging(["id": documentID, "path": reference.path]) { $1 }).flatMap { $0.as(T.self) }
  }
}
