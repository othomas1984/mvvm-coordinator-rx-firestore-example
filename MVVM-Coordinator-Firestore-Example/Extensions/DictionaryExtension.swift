//
//  DictionaryExtension.swift
//  MVVM-Coordinator-Firestore-Example
//
//  Created by Owen Thomas on 7/4/18.
//  Copyright © 2018 Owen Thomas. All rights reserved.
//

import Foundation

extension Dictionary where Key: StringProtocol {
  func `as`<T: Decodable>(_ type: T.Type) -> T? {
    return (try? JSONSerialization.data(withJSONObject: self, options: []))
      .flatMap { try? JSONDecoder().decode(T.self, from: $0) }
  }
}
