//
//  FirestoreProtocols.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/6/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import FirebaseFirestore

typealias QuerySnapshotBlock = (QuerySnapshotProtocol?, Error?) -> Void
typealias DocumentSnapshotBlock = (DocumentSnapshotProtocol?, Error?) -> Void
typealias DataListenerHandle = ListenerRegistration

// MARK: - Firestore
protocol FirestoreProtocol {
  static func firestore() -> Self
  func collection(_ collectionPath: String) -> CollectionReferenceProtocol
  func document(_ documentPath: String) -> DocumentReferenceProtocol
}

// MARK: - CollectionReference
protocol CollectionReferenceProtocol {
  func document(_ documentPath: String) -> DocumentReferenceProtocol
  func addSnapshotListener(_ listener: @escaping QuerySnapshotBlock) -> DataListenerHandle
  func addDocument(data: [String: Any]) -> DocumentReferenceProtocol
  func addDocument(data: [String: Any], completion: ((Error?) -> Void)?) -> DocumentReferenceProtocol
  var path: String { get }
}

// MARK: - DocumentReference
protocol DocumentReferenceProtocol {
  func addSnapshotListener(_ listener: @escaping DocumentSnapshotBlock) -> DataListenerHandle
  func getDocument(completion: @escaping DocumentSnapshotBlock)
  func delete(completion: ((Error?) -> Void)?)
  func updateData(_ fields: [AnyHashable: Any], completion: ((Error?) -> Void)?)
  func collection(_ collectionPath: String) -> CollectionReferenceProtocol
  var path: String { get }
}

// MARK: - QuerySnapshot
protocol QuerySnapshotProtocol {
  var snapshots: [QueryDocumentSnapshotProtocol] { get }
}

// MARK: - QueryDocumentSnapshot
protocol QueryDocumentSnapshotProtocol {
  func data() -> [String: Any]
  var documentID: String { get }
  var ref: DocumentReferenceProtocol { get }
  // TODO: Do the `as` methods belong here? Seems more like a (Query)DocumentSnapshot Extension
  func `as`<T: Decodable>(_ type: T.Type) -> T?
}

// MARK: - DocumentSnapshot
protocol DocumentSnapshotProtocol {
  func data() -> [String: Any]?
  var documentID: String { get }
  var ref: DocumentReferenceProtocol { get }
  func `as`<T: Decodable>(_ type: T.Type) -> T?
}
