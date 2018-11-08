//
//  BinaryOperatorExpression.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 20/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// A struct that describes an expression that uses a binary
/// operator (such as + or /) to perform an operation
/// on two expressions.
///
/// Example operator expression: `x + y`.
public struct BinaryOperatorExpression: Expression {
  /// The expression on the left-hand-side
  let lhs: Expression
  /// The operator that defines the operation
  let operation: Operator
  /// The expression on the right-hand-side
  let rhs: Expression
}
