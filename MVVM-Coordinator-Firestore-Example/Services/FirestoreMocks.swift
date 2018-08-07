//
//  FirestoreMocks.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 8/6/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation

// MARK: - Firestore
class MockFirestore: FirestoreProtocol {
  static var methodCalls = [String: [String: Int]]()
  static func methodCalled(className: String, methodName: String) {
    var classCounts = methodCalls[className] ?? [String: Int]()
    classCounts[methodName] = (classCounts[methodName] ?? 0) + 1
    methodCalls[className] = classCounts
  }
  
  static func firestore() -> Self {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    return firestoreHelper()
  }
  func collection(_ collectionPath: String) -> CollectionReferenceProtocol {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    return MockCollectionReference()
  }
  func document(_ documentPath: String) -> DocumentReferenceProtocol {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    return MockDocumentReference()
  }
  private class func firestoreHelper<T>() -> T {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    return MockFirestore() as! T
  }
}

// MARK: - CollectionReference
class MockCollectionReference: CollectionReferenceProtocol {
  func addSnapshotListener(_ listener: @escaping QuerySnapshotBlock) -> DataListenerHandle {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    listener(MockQuerySnapshot(), nil)
    return MockDataListenerHandle()
  }
  func document(_ documentPath: String) -> DocumentReferenceProtocol {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    return MockDocumentReference()
  }
  func addDocument(data: [String : Any]) -> DocumentReferenceProtocol {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    return MockDocumentReference()
  }
  func addDocument(data: [String : Any], completion: ((Error?) -> Void)?) -> DocumentReferenceProtocol {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    completion?(nil)
    return MockDocumentReference()
  }
  var path: String {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    return "Collection-Path"
  }
}

// MARK: - DocumentReference
class MockDocumentReference: DocumentReferenceProtocol {
  func addSnapshotListener(_ listener: @escaping DocumentSnapshotBlock) -> DataListenerHandle {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    listener(MockDocumentSnapshot(), nil)
    return MockDataListenerHandle()
  }
  func getDocument(completion: @escaping DocumentSnapshotBlock) {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    completion(MockDocumentSnapshot(), nil)
  }
  func delete(completion: ((Error?) -> Void)?) {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    completion?(nil)
  }
  func updateData(_ fields: [AnyHashable : Any], completion: ((Error?) -> Void)?) {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    completion?(nil)
  }
  var path: String {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    return "Document-Path"
  }
  func collection(_ collectionPath: String) -> CollectionReferenceProtocol {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    return MockCollectionReference()
  }
}

// MARK: - QuerySnapshot
class MockQuerySnapshot: QuerySnapshotProtocol {
  var snapshots: [QueryDocumentSnapshotProtocol] {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    return [MockQueryDocumentSnapshot]()
  }
}

// MARK: - QueryDocumentSnapshot
class MockQueryDocumentSnapshot: QueryDocumentSnapshotProtocol {
  func data() -> [String : Any] {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    return [:]
  }
  var documentID: String {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    return "Document-ID"
  }
  var ref: DocumentReferenceProtocol {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    return MockDocumentReference()
  }
  // TODO: Do the `as` methods belong here? Seems more like a (Query)DocumentSnapshot Extension
  func `as`<T>(_ type: T.Type) -> T? where T : Decodable {
    return nil
  }
}

// MARK: - DocumentSnapshot
class MockDocumentSnapshot: DocumentSnapshotProtocol {
  func data() -> [String : Any]? {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    return [:]
  }
  var documentID: String {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    return "Document-ID"
  }
  var ref: DocumentReferenceProtocol {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
    return MockDocumentReference()
  }
  // TODO: Do the `as` methods belong here? Seems more like a (Query)DocumentSnapshot Extension
  func `as`<T>(_ type: T.Type) -> T? where T : Decodable {
    return nil
  }
}

// MARK: - ListenerRegistration
class MockDataListenerHandle: NSObject, DataListenerHandle {
  func remove() {
    MockFirestore.methodCalled(className: "\(type(of: self))", methodName: #function)
  }
}
