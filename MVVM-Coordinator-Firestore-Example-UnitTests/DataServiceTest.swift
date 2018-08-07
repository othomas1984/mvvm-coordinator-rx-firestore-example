//
//  DataServiceTest.swift
//  MVVM-Coordinator-Firestore-Example-UnitTests
//
//  Created by Owen Thomas on 8/6/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import XCTest
import RxTest
import RxSwift

@testable import MVVM_Coordinator_Firestore_Example

class DataServiceTest: XCTestCase {
  var dataService: DataService!
  var firestore: MockFirestore.Type!
  
  override func setUp() {
    super.setUp()
    firestore = MockFirestore.self
    dataService = DataService(firestore)
  }
  
  override func tearDown() {
    super.tearDown()
    dataService = nil
    firestore.methodCalls = [:]
    firestore = nil
  }
  
  func testListeners() {
    var handle: DataListenerHandle
    let usersExp = XCTestExpectation()
    handle = dataService.usersListener { (users) in
      usersExp.fulfill()
    }
    handle.remove()
    
    let itemsExp = XCTestExpectation()
    handle = dataService.itemsListener(userPath: "fake-user-path") { (users) in
      itemsExp.fulfill()
    }
    handle.remove()
    
    let waiterResult = XCTWaiter.wait(for: [usersExp, itemsExp], timeout: 1.0)
    
    XCTAssertEqual(waiterResult, .completed)
    XCTAssertEqual(firestore.methodCalls["MockCollectionReference"]?["addSnapshotListener"], 2)
    XCTAssertEqual(firestore.methodCalls["MockDataListenerHandle"]?["remove()"], 2)
  }
  
  func testStartViewModel() {
    // TODO: Need to create mock dataService and delegate and check their method calls instead of checking at the
    // firestore level
    var vm: StartViewModel? = StartViewModel(delegate: self, dataService: dataService)
    
    // Using RxTest
    let testScheduler = TestScheduler(initialClock: 0)
    let addButtonTaps = testScheduler.createHotObservable([next(100, ())])
    let addDisposable = addButtonTaps.bind(to: vm!.addTapped)
    let selectButtonTaps = testScheduler.createHotObservable([next(100, (IndexPath(row: 0, section: 0)))])
    let selectDisposable = selectButtonTaps.bind(to: vm!.userSelected)
    let usersDisposable = vm?.users.bind { users in
      print(users)
    }
    testScheduler.start()
    addDisposable.dispose()
    selectDisposable.dispose()
    usersDisposable?.dispose()
    
    // Using RxSwift (pretty sure only one or the other will run, comment out the RxTest version to run the RxSwift one)
    let addButtonSubject = PublishSubject<()>()
    let addDisposable2 = addButtonSubject.bind(to: vm!.addTapped)
    addButtonSubject.onNext(())
    addDisposable2.dispose()


    vm = nil
    XCTAssertEqual(firestore.methodCalls["MockCollectionReference"]?["addSnapshotListener"], 1)
    XCTAssertEqual(firestore.methodCalls["MockDataListenerHandle"]?["remove()"], 1)

    print(firestore.methodCalls)

  }
}

extension DataServiceTest: StartViewModelDelegate {
  func select(_ userPath: String) {
    
  }
  
  func add() {
    print("Test")
  }
}
