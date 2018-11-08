//
//  SemaError.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 23/10/2018.
//

import Foundation

/// A struct that encapsulates the different errors that can be
/// thrown during Sema
struct SemaError {
  
  /// Type checking errors
  enum TypeCheck: Error {
    case arityMismatch(name: String, gotCount: Int, expectedCount: Int)
    case typeMismatch(expected: BuiltinType, got: BuiltinType)
    case invalidFunctionRedeclaration(name: String, count: Int)
    case invalidVariableRedeclaration(name: String)
    case variableCannotBeModified(name: String)
    case unreachableCode(String)
    case invalidReturnType(expected: BuiltinType, got: BuiltinType)
    case variableNotAssigned(String)
    case variableNotDeclared(String)
    case invalidExpression
    case invalidParameters
    case invalidFunctionCall
    case invalidType
    case emptyReturnStatement
    case emptyPrintStatement
  }
  
  /// Entry-point specific error
  enum EntryPointError: Error {
    case notTopLevel
  }
}
