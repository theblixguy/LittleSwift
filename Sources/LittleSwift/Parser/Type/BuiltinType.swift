//
//  BuiltinType.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 20/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// A struct that defines a builtin LLVM type
public struct BuiltinType: Type {
  /// The raw (Swift) name of the type
  let rawName: String
}

/// An extension that defines different builtin types
extension BuiltinType {
  static let integer = BuiltinType(rawName: "Int")
  static let float = BuiltinType(rawName: "Float")
  static let string = BuiltinType(rawName: "String")
  static let bool = BuiltinType(rawName: "Bool")
  static let void = BuiltinType(rawName: "Void")
}

/// An extension that adds equatable conformance to `BuiltinTypre`
extension BuiltinType: Equatable {
  public static func ==(lhs: BuiltinType, rhs: BuiltinType) -> Bool {
    return lhs.rawName == rhs.rawName
  }
}
