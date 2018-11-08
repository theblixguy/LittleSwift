//
//  FunctionSignature.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 20/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// A struct that describes a function signature (also known
/// as a function prototype)
///
/// For example: `contains(value: Float) -> Bool`
public struct FunctionSignature: Declaration {
  /// The name of the function
  let name: String
  /// The function arguments
  let arguments: [VariableDeclaration]
  /// The return type of the function
  let returnType: BuiltinType
}
