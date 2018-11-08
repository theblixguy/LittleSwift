//
//  FunctionDeclaration.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 20/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// A struct that describes a function declaration.
///
/// For example: `func contains(value: Float) -> Bool {}`
public struct FunctionDeclaration: Declaration {
  /// The signature (i.e. prototype) of the function
  let signature: FunctionSignature
  /// The body of the function
  let body: [Expression]
}
