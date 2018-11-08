//
//  CollectionExtensions.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 23/10/2018.
//

import Foundation

extension Collection {
  func count(where test: (Element) throws -> Bool) rethrows -> Int {
    return try self.filter(test).count
  }
}
