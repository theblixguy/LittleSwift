//
//  VariableDeclaration.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 20/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// A struct that describes a variable declaration.
///
/// For example: `let text: String`
public struct VariableDeclaration: Declaration {
  /// The mutability of the variable (mutable or non-mutable/immutable)
  let mutability: DeclarationModifier.Mutation
  /// The name of the variable
  let name: String
  /// The type of the variable
  var type: BuiltinType
  
  mutating func updateType(to type: BuiltinType) {
    self.type = type
  }
}
