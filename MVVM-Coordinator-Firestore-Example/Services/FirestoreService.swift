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
    return get(atPath: nil, completion: completion)
  }
  
  static func createUser(with name: String, completion: ((User?) -> Void)? = nil) {
    return create(forParent: nil, with: ["name": name], completion: completion)
  }
  
  static func getItems(userPath: DocumentReference, completion: @escaping ([Item]) -> Void) -> ListenerRegistration {
    return get(atPath: userPath, completion: completion)
  }

  static func createItem(for user: User, with name: String, completion: ((Item?) -> Void)? = nil) {
    return create(forParent: user, with: ["name": name], completion: completion)
  }
  
  static func getConstraints(userPath: DocumentReference, completion: @escaping ([Constraint]) -> Void) -> ListenerRegistration {
    return get(atPath: userPath, completion: completion)
  }
  
  static func createConstraint(for user: User, with name: String, completion: ((Constraint?) -> Void)? = nil) {
    return create(forParent: user, with: ["name": name], completion: completion)
  }
  
  static func getDetails(userPath: DocumentReference, completion: @escaping ([Detail]) -> Void) -> ListenerRegistration {
    return get(atPath: userPath, completion: completion)
  }
  
  // TODO: Require constraint to be an existing constraint somehow
  static func createDetail(for item: Item, with name: String, constraint: String, completion: ((Detail?) -> Void)? = nil) {
    return create(forParent: item, with: ["name": name, "constraint": constraint], completion: completion)
  }
  
  static func delete(_ object: FirestoreModel, completion: ((Error?) -> Void)?) {
    // TODO: Needs to have server code to delete sub collections and items
    object.path.delete(completion: completion)
  }

  private static func get<T: FirestoreModel>(atPath path: DocumentReference?, completion:  @escaping ([T]) -> Void) -> ListenerRegistration {
    return (path?.collection(T.collectionPath) ?? Firestore.firestore().collection(T.collectionPath))
      .addSnapshotListener { (snapshot, error) in
        if let error = error { print(error); return }
        guard let snapshot = snapshot else { print("No data found"); completion([]); return }
        
        let items: [T] = snapshot.documents.compactMap { T(snapShot: $0) }
        completion(items)
    }
  }
  
  private static func create<T: FirestoreModel>(forParent parent: FirestoreModel?, with data: [String: Any], completion: ((T?) -> Void)?) {
    (parent?.path.collection(T.collectionPath) ?? Firestore.firestore().collection(T.collectionPath)).addDocument(data: data).getDocument { (snapshot, error) in
      if let error = error { print(error); return }
      guard let snapshot = snapshot else { print("New item not found"); completion?(nil); return}
      let item = T(snapShot: snapshot)
      completion?(item)
    }
  }
}
