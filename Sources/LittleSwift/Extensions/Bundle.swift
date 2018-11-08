//
//  Bundle.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 20/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// An extension that returns version number and build number
extension Bundle {
  /// Get the program's version number
  var releaseVersionNumber: String? {
    return infoDictionary?["CFBundleShortVersionString"] as? String
  }
  /// Get the program's build number
  var buildVersionNumber: String? {
    return infoDictionary?["CFBundleVersion"] as? String
  }
}
