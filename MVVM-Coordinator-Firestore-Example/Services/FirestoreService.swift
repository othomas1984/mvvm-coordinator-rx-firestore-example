//
//  FirestoreService.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import FirebaseFirestore

class FirestoreService {
  struct Path {
    static let userCollection = Firestore.firestore().collection("users-mvvm-coordinator-example").path
    static func itemCollection(userPath path: String) -> String {
      return Firestore.firestore().document(path).collection("items").path
    }
    static func constraintCollection(userPath path: String) -> String {
      return Firestore.firestore().document(path).collection("constraints").path
    }
    static func detailCollection(itemPath path: String) -> String {
      return Firestore.firestore().document(path).collection("details").path
    }
  }
  
  // MARK: - User
  static func createUser(with name: String, completion: ((User?) -> Void)? = nil) {
    return create(data: ["name": name], in: Path.userCollection, completion: completion)
  }
  
  static func userListener(path: String, completion: @escaping (User?) -> Void) -> ListenerRegistration {
    return documentListener(path: path, completion: completion)
  }
  
  static func usersListener(completion: @escaping ([User]) -> Void) -> ListenerRegistration {
    return collectionListener(path: Path.userCollection, completion: completion)
  }
  
  static func updateUser(path: String, with data: [String: Any], completion: ((Error?) -> Void)?) {
    update(path: path, with: data, completion: completion)
  }

  static func deleteUser(path: String, completion: ((Error?) -> Void)?) {
    delete(path: path, completion: completion)
  }
  
  // MARK: - Item
  static func createItem(userPath: String, with name: String, completion: ((Item?) -> Void)? = nil) {
    return create(data: ["name": name], in: Path.itemCollection(userPath: userPath), completion: completion)
  }
  
  static func itemListener(path: String, completion: @escaping (Item?) -> Void) -> ListenerRegistration {
    return documentListener(path: path, completion: completion)
  }
  
  static func itemsListener(userPath: String, completion: @escaping ([Item]) -> Void) -> ListenerRegistration {
    return collectionListener(path: Path.itemCollection(userPath: userPath), completion: completion)
  }
  
  static func updateItem(path: String, with data: [String: Any], completion: ((Error?) -> Void)?) {
    update(path: path, with: data, completion: completion)
  }
  
  static func deleteItem(path: String, completion: ((Error?) -> Void)?) {
    delete(path: path, completion: completion)
  }
  
  // MARK: - Constraint
  static func createConstraint(userPath: String, with name: String, completion: ((Constraint?) -> Void)? = nil) {
    return create(data: ["name": name], in: Path.constraintCollection(userPath: userPath), completion: completion)
  }
  
  static func constraintListener(path: String, completion: @escaping (Constraint?) -> Void) -> ListenerRegistration {
    return documentListener(path: path, completion: completion)
  }
  
  static func constraintsListener(userPath: String, completion: @escaping ([Constraint]) -> Void) -> ListenerRegistration {
    return collectionListener(path: Path.constraintCollection(userPath: userPath), completion: completion)
  }
  
  static func updateConstraint(path: String, with data: [String: Any], completion: ((Error?) -> Void)?) {
    update(path: path, with: data, completion: completion)
  }
  
  static func deleteConstraint(path: String, completion: ((Error?) -> Void)?) {
    delete(path: path, completion: completion)
  }
  
  // MARK: - Detail
  static func createDetail(itemPath: String, with name: String, constraint: String, completion: ((Detail?) -> Void)? = nil) {
    return create(data: ["name": name, "constraint": constraint], in: Path.detailCollection(itemPath: itemPath), completion: completion)
  }
  
  static func detailListener(path: String, completion: @escaping (Detail?) -> Void) -> ListenerRegistration {
    return documentListener(path: path, completion: completion)
  }
  
  static func detailsListener(itemPath: String, completion: @escaping ([Detail]) -> Void) -> ListenerRegistration {
    return collectionListener(path: Path.detailCollection(itemPath: itemPath), completion: completion)
  }
  
  static func updateDetail(path: String, with data: [String: Any], completion: ((Error?) -> Void)?) {
    update(path: path, with: data, completion: completion)
  }
  
  static func deleteDetail(path: String, completion: ((Error?) -> Void)?) {
    delete(path: path, completion: completion)
  }
  
  // MARK: - Generics
  private static func collectionListener<T: Decodable>(path: String, completion:  @escaping ([T]) -> Void) -> ListenerRegistration {
    return Firestore.firestore().collection(path)
      .addSnapshotListener { (snapshot, error) in
        if let error = error { print(error); return }
        let items: [T] = snapshot?.documents.compactMap { $0.as(T.self) } ?? []
        completion(items)
    }
  }
  
  private static func documentListener<T: Decodable>(path: String, completion: @escaping ((T?) -> Void)) -> ListenerRegistration {
    return Firestore.firestore().document(path).addSnapshotListener { (snapshot, error) in
      if let error = error { print(error); return }
      completion(snapshot?.as(T.self))
    }
  }
  
  private static func create<T: Codable>(data: [String: Any], in path: String, completion: ((T?) -> Void)?) {
    Firestore.firestore().collection(path).addDocument(data: data).getDocument { (snapshot, error) in
      if let error = error { print(error); return }
      completion?(snapshot?.as(T.self))
    }
  }
  
  private static func delete(path: String, completion: ((Error?) -> Void)?) {
    Firestore.firestore().document(path).delete(completion: completion)
  }
  
  private static func update(path: String, with data: [String: Any], completion: ((Error?) -> Void)?) {
    Firestore.firestore().document(path).updateData(data, completion: completion)
  }
}
