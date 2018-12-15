//
//  ExpressionResult.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 15/12/2018.
//

import Foundation

extension Interpreter {
  /// A struct that contains an expression and its evaluated
  /// result
  struct ExpressionResult {
    let expression: Expression
    let result: Result
  }
}
