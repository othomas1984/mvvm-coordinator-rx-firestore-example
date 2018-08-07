//
//  FirestoreProtocolConformance.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/6/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import FirebaseFirestore

// MARK: - Firestore
extension Firestore: FirestoreProtocol {
  func collection(_ collectionPath: String) -> CollectionReferenceProtocol {
    return collection(collectionPath) as CollectionReference
  }
  func document(_ documentPath: String) -> DocumentReferenceProtocol {
    return document(documentPath) as DocumentReference
  }
}

// MARK: - CollectionReference
extension CollectionReference: CollectionReferenceProtocol {
  func document(_ documentPath: String) -> DocumentReferenceProtocol {
    return document(documentPath) as DocumentReference
  }
  func addSnapshotListener(_ listener: @escaping QuerySnapshotBlock) -> DataListenerHandle {
    return addSnapshotListener(listener as FIRQuerySnapshotBlock)
  }
  func addDocument(data: [String : Any]) -> DocumentReferenceProtocol {
    return addDocument(data: data) as DocumentReference
  }
  func addDocument(data: [String : Any], completion: ((Error?) -> Void)?) -> DocumentReferenceProtocol {
    return addDocument(data: data, completion: completion) as DocumentReference
  }
}

// MARK: - DocumentReference
extension DocumentReference: DocumentReferenceProtocol {
  func addSnapshotListener(_ listener: @escaping DocumentSnapshotBlock) -> DataListenerHandle {
    return addSnapshotListener(listener as FIRDocumentSnapshotBlock)
  }
  func getDocument(completion: @escaping DocumentSnapshotBlock) {
    getDocument(completion: completion as FIRDocumentSnapshotBlock)
  }
  func collection(_ collectionPath: String) -> CollectionReferenceProtocol {
    return collection(collectionPath) as CollectionReference
  }
}

// MARK: - QuerySnapshot
extension QuerySnapshot: QuerySnapshotProtocol {
  var snapshots: [QueryDocumentSnapshotProtocol] {
    return documents
  }
}

// MARK: - QueryDocumentSnapshot
extension QueryDocumentSnapshot: QueryDocumentSnapshotProtocol { }

// MARK: - DocumentSnapshot
extension DocumentSnapshot: DocumentSnapshotProtocol {
  var ref: DocumentReferenceProtocol {
    return reference
  }
  // TODO: Do the `as` methods belong here? Seems more like a (Query)DocumentSnapshot Extension
  func `as`<T: Decodable>(_ type: T.Type) -> T? {
    return (data()?.merging(["id": documentID, "path": ref.path]) { $1 }).flatMap { $0.as(T.self) }
  }
}
