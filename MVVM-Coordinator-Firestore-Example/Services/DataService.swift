//
//  DataService.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/4/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import FirebaseFirestore

class DataService {
  private let service: FirestoreProtocol.Type

  init(_ dataServiceProtocol: FirestoreProtocol.Type = Firestore.self) {
    service = dataServiceProtocol
  }

  // MARK: - User Services
  func createUser(with name: String, completion: ((User?) -> Void)? = nil) {
    return create(data: ["name": name], in: usersPath, completion: completion)
  }
  
  func userListener(path: String, completion: @escaping (User?) -> Void) -> DataListenerHandle {
    return documentListener(path: path, completion: completion)
  }
  
  func usersListener(completion: @escaping ([User]) -> Void) -> DataListenerHandle {
    return collectionListener(path: usersPath, completion: completion)
  }
  
  func updateUser(path: String, with data: [String: Any], completion: ((Error?) -> Void)?) {
    update(path: path, with: data, completion: completion)
  }
  
  func deleteUser(path: String, completion: ((Error?) -> Void)?) {
    delete(path: path, completion: completion)
  }
  
  // MARK: - Item Services
  func createItem(userPath: String, with name: String, completion: ((Item?) -> Void)? = nil) {
    return create(data: ["name": name], in: itemsPath(forUserPath: userPath), completion: completion)
  }
  
  func itemListener(path: String, completion: @escaping (Item?) -> Void) -> DataListenerHandle {
    return documentListener(path: path, completion: completion)
  }
  
  func itemsListener(userPath: String, completion: @escaping ([Item]) -> Void) -> DataListenerHandle {
    return collectionListener(path: itemsPath(forUserPath: userPath), completion: completion)
  }
  
  func updateItem(path: String, with data: [String: Any], completion: ((Error?) -> Void)?) {
    update(path: path, with: data, completion: completion)
  }
  
  func deleteItem(path: String, completion: ((Error?) -> Void)?) {
    delete(path: path, completion: completion)
  }
  
  // MARK: - Constraint Services
  func createConstraint(userPath: String, with name: String, completion: ((Constraint?) -> Void)? = nil) {
    return create(data: ["name": name], in: constraintsPath(forUserPath: userPath), completion: completion)
  }
  
  func constraintListener(path: String, completion: @escaping (Constraint?) -> Void) -> DataListenerHandle {
    return documentListener(path: path, completion: completion)
  }
  
  func constraintsListener(userPath: String, completion: @escaping ([Constraint]) -> Void) -> DataListenerHandle {
    return collectionListener(path: constraintsPath(forUserPath: userPath), completion: completion)
  }
  
  func updateConstraint(path: String, with data: [String: Any], completion: ((Error?) -> Void)?) {
    update(path: path, with: data, completion: completion)
  }
  
  func deleteConstraint(path: String, completion: ((Error?) -> Void)?) {
    delete(path: path, completion: completion)
  }
  
  // MARK: - Detail Services
  func createDetail(itemPath: String, with name: String, constraint: String = "", completion: ((Detail?) -> Void)? = nil) {
    return create(data: ["name": name, "constraint": constraint], in: detailsPath(forItemPath: itemPath), completion: completion)
  }
  
  func detailListener(path: String, completion: @escaping (Detail?) -> Void) -> DataListenerHandle {
    return documentListener(path: path, completion: completion)
  }
  
  func detailsListener(itemPath: String, completion: @escaping ([Detail]) -> Void) -> DataListenerHandle {
    return collectionListener(path: detailsPath(forItemPath: itemPath), completion: completion)
  }
  
  func updateDetail(path: String, with data: [String: Any], completion: ((Error?) -> Void)?) {
    update(path: path, with: data, completion: completion)
  }
  
  func deleteDetail(path: String, completion: ((Error?) -> Void)?) {
    delete(path: path, completion: completion)
  }

  // MARK: - Private
  private var usersPath: String {
    return "users-mvvm-coordinator-example"
  }
  private func itemsPath(forUserPath path: String) -> String {
    return path + "/items"
  }
  private func constraintsPath(forUserPath path: String) -> String {
    return path + "/constraints"
  }
  private func detailsPath(forItemPath path: String) -> String {
    return path + "/details"
  }

  private func collectionListener<T: Decodable>(path: String, completion: @escaping ([T]) -> Void) -> DataListenerHandle {
    return service.firestore().collection(path)
      .addSnapshotListener { (snapshot, error) in
        if let error = error { print(error); return }
        let items: [T] = snapshot?.snapshots.compactMap { $0.as(T.self) } ?? []
        completion(items)
    }
  }
  
  private func documentListener<T: Decodable>(path: String, completion: @escaping ((T?) -> Void)) -> DataListenerHandle {
    return service.firestore().document(path).addSnapshotListener { (snapshot, error) in
      if let error = error { print(error); return }
      completion(snapshot?.as(T.self))
    }
  }
  
  private func create<T: Codable>(data: [String: Any], in path: String, completion: ((T?) -> Void)?) {
    service.firestore().collection(path).addDocument(data: data).getDocument { (snapshot, error) in
      if let error = error { print(error); return }
      completion?(snapshot?.as(T.self))
    }
  }
  
  private func delete(path: String, completion: ((Error?) -> Void)?) {
    service.firestore().document(path).delete(completion: completion)
  }
  
  private func update(path: String, with data: [String: Any], completion: ((Error?) -> Void)?) {
    service.firestore().document(path).updateData(data, completion: completion)
  }
}
