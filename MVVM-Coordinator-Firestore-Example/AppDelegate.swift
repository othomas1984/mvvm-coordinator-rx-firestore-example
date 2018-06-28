//
//  AppDelegate.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 6/25/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var baseCoordinator: StartCoordinator!
  
  var window: UIWindow?
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    configureFirebase()
    
    let newWindow = UIWindow(frame: UIScreen.main.bounds)
    window = newWindow
    baseCoordinator = StartCoordinator(newWindow)
    baseCoordinator.start()
    return true
  }
  
  private func configureFirebase() {
    FirebaseApp.configure()
    let db = Firestore.firestore()
    let settings = db.settings
    settings.areTimestampsInSnapshotsEnabled = true
    db.settings = settings
  }
}
