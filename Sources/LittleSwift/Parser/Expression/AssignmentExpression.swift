//
//  AssignmentExpression.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 20/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// A struct that defines an assignment expression.
///
/// Example: `let pi: Float = 3.14`.
///
/// The assignment operator (=) is being used to assign
/// `pi` (a variable) a value of 3.14 (an expression).
/// The assigned value does not have to be a literal. It
/// can also be a value that is returned via a function
/// call. For example: `let json: String = networkCall()`
/// where `networkCall` has a signature of `networkCall()
/// -> String`.
public class AssignmentExpression: Expression {
  var variable: VariableDeclaration
  let value: Expression
  
  init(variable: VariableDeclaration, value: Expression) {
    self.variable = variable
    self.value = value
  }
}
