//
//  FirestoreService.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import FirebaseFirestore

class FirestoreService {
  static func getUsers(completion: @escaping ([User]) -> Void) -> ListenerRegistration {
    return get(type: User.self, atPath: nil, completion: completion)
  }

  static func getItems(userPath: DocumentReference, completion: @escaping ([Item]) -> Void) -> ListenerRegistration {
    return get(type: Item.self, atPath: userPath, completion: completion)
  }

  static func getConstraints(userPath: DocumentReference, completion: @escaping ([Constraint]) -> Void) -> ListenerRegistration {
    return get(type: Constraint.self, atPath: userPath, completion: completion)
  }
  
  static func getDetails(userPath: DocumentReference, completion: @escaping ([Detail]) -> Void) -> ListenerRegistration {
    return get(type: Detail.self, atPath: userPath, completion: completion)
  }
  
  static func get<T: FirestoreModel>(type: FirestoreModel.Type, atPath path: DocumentReference?, completion:  @escaping ([T]) -> Void) -> ListenerRegistration {
    return (path?.collection(T.collectionPath) ?? Firestore.firestore().collection(T.collectionPath))
      .addSnapshotListener { (snapshot, error) in
        if let error = error { print(error); return }
        guard let snapshot = snapshot else { print("No data found"); return }
        
        let items: [T] = snapshot.documents.compactMap { T(snapShot: $0) }
        completion(items)
    }
  }
}
