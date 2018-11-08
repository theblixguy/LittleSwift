//
//  CompileTime.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 20/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

struct CompileTime {
  /// Get the compile time of the program
  static var date: Date {
    let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
    if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
      let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
      let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date {
      return infoDate
    }
    return Date()
  }
}
