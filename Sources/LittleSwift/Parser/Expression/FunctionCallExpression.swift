//
//  FunctionCallExpression.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 20/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// A struct that describes a function call expression.
///
/// Example: `print("Hello, world!")` where `print` is
/// a function call & "Hello, world!" is the argument.
public struct FunctionCallExpression: Expression {
  /// The name of the function
  let name: String
  /// The arguments passed to the function
  let arguments: [Expression]
}
