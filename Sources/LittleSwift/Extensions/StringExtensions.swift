//
//  StringExtensions.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 17/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

public extension String {
  func match(_ regex: String) -> String {
    do {
      let regex = try NSRegularExpression(pattern: "^\(regex)")
      let results = regex.matches(in: self, range: NSRange(startIndex..., in: self))
      return results.map { String(self[Range($0.range, in: self)!]) }.first ?? ""
    } catch let error {
      print("Invalid regex passed: \(error.localizedDescription)")
      return ""
    }
  }
}
