//
//  Sema.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 23/10/2018.
//

import Foundation

/// A struct that defines a scope variable
///
/// A scope is defined by the function signature, which may contain
/// one or more variable declarations.
private struct SemaScopeVariable {
  let scope: FunctionSignature
  let variable: VariableDeclaration
}

/// A class that performs semantic analysis.
class Sema {
  
  /// A dictionary that maps a function name to its signature
  private var functionSignatureMap: [String: FunctionSignature] = [:]
  /// A array of scope variables
  private var variables: [SemaScopeVariable] = []
  /// The AST
  private var ast: [Expression]
  
  /// The initializer for the class
  init(with ast: [Expression]) {
    self.ast = ast
  }
  
  /// Performs semantic analysis over the AST.
  ///
  /// 1) The first phase is to specifically analyse the entry point
  /// (a.k.a the 'main' function).
  /// 2) The second phase is to traverse the AST to build a map of
  /// function signatures and an array of scope variables.
  /// 3) The third phase is to analyse the AST using the signature map
  /// and the scope variables.
  func performSema() throws {
    try visitMainFunction()
    
    try ast.forEach { expr in
      if let decl = expr as? FunctionDeclaration {
        try visitAndParseFunctionDecl(decl)
      }
    }
    
    try ast.forEach { expr in
      if let decl = expr as? FunctionDeclaration {
        try visit(decl)
      }
    }
  }
  
  /// Parse the function declaration to build a signature map and also perform a
  /// basic type check on the declaration body to catch simple mistakes
  private func visitAndParseFunctionDecl(_ decl: FunctionDeclaration) throws {
    functionSignatureMap[decl.signature.name] = decl.signature
    
    decl.signature.arguments.forEach { arg in
      variables.append(SemaScopeVariable(scope: decl.signature, variable: arg))
    }
    
    try decl.body.forEach { expr in
      if let variableDecl = expr as? VariableDeclaration, variableDecl.mutability == .nonmutating {
        throw SemaError.TypeCheck.variableNotAssigned(variableDecl.name)
      } else if let assignExpr = expr as? AssignmentExpression {
        if decl.signature.arguments.contains(where: { $0.name == assignExpr.variable.name }) {
          throw SemaError.TypeCheck.variableCannotBeModified(name: assignExpr.variable.name)
        } else if variables.contains(where: { $0.scope.name == decl.signature.name && $0.variable.name == assignExpr.variable.name }) {
          throw SemaError.TypeCheck.invalidVariableRedeclaration(name: assignExpr.variable.name)
        }
        variables.append(SemaScopeVariable(scope: decl.signature, variable: assignExpr.variable))
      }
    }
  }
  
  /// Visit a specific expression and return the type (optional)
  private func visit(_ expr: Expression, _ scope: FunctionDeclaration) throws -> BuiltinType? {
    
    if let expr = expr as? FunctionCallExpression {
      return try visit(funcCallExpr: expr, scope)
    } else if let expr = expr as? VariableDeclaration {
      return try visit(variableDecl: expr, scope)
    } else if let expr = expr as? AssignmentExpression {
      return try visit(assignExpr: expr, scope)
    } else if let expr = expr as? PropertyAccessExpression {
      return try visit(propExpr: expr, scope)
    } else if let expr = expr as? BinaryOperatorExpression {
      return try visit(binaryOpExpr: expr, scope)
    } else if let expr = expr as? PrintStatement {
      return try visit(printStmt: expr, scope)
    } else if let expr = expr as? ReturnStatement {
      return try visit(returnStmt: expr, scope)
		} else if let expr = expr as? Type {
			return try visit(type: expr)
		}
    
    return nil
  }
  
  /// Visit each expression in the declaration body
  private func visit(_ decl: FunctionDeclaration) throws {
    try decl.body.forEach { expr in
      let _ = try visit(expr, decl)
    }
  }
  
  /// Visit a function call expression and type check it
  private func visit(funcCallExpr: FunctionCallExpression, _ scope: FunctionDeclaration) throws -> BuiltinType {
    var argTypes: [Type] = []
    
    funcCallExpr.arguments.forEach { expr in
      guard let _type = expr as? Type else { return }
      argTypes.append(_type)
    }
    
    guard let functionSignature = functionSignatureMap[funcCallExpr.name] else {
      throw SemaError.TypeCheck.invalidFunctionCall
    }
    
    let funcSignatureArity = functionSignature.arguments.count
    let functionCallArity = argTypes.count
    
    guard funcSignatureArity == functionCallArity else {
      throw SemaError.TypeCheck.arityMismatch(name: funcCallExpr.name, gotCount: functionCallArity, expectedCount: funcSignatureArity)
    }
    
    let funcSignatureArgTypes = functionSignature.arguments.map { $0.type }
    
    let mappedArgTypes = argTypes.compactMap { mapSwiftTypeToBuiltinType($0) }
    
    guard funcSignatureArgTypes == mappedArgTypes else {
      throw SemaError.TypeCheck.invalidParameters
    }
    
    return functionSignature.returnType
  }
  
  /// Visit a variable declaration. There is no need to check a variable declaration as they always
  /// contain a type so just return its type directly
  private func visit(variableDecl: VariableDeclaration, _ scope: FunctionDeclaration) -> BuiltinType {
    return variableDecl.type
  }
  
  /// Visit an assignment expression and type check it
  private func visit(assignExpr: AssignmentExpression, _ scope: FunctionDeclaration) throws -> BuiltinType {
    let lhs = assignExpr.variable.type
    
    guard let rhs = try visit(assignExpr.value, scope) else {
      throw SemaError.TypeCheck.invalidType
    }
    
    guard lhs == rhs else {
      throw SemaError.TypeCheck.typeMismatch(expected: lhs, got: rhs)
    }
    
    return lhs
  }
  
  /// Visit a property access expression and type check it
  private func visit(propExpr: PropertyAccessExpression, _ scope: FunctionDeclaration) throws -> BuiltinType? {
    guard let propType = variables.first(where: { $0.scope.name == scope.signature.name && $0.variable.name == propExpr.name })?.variable.type else {
      throw SemaError.TypeCheck.variableNotDeclared(propExpr.name)
    }
    
    return propType
  }
  
  /// Visit a binary operator expression and type check it
  private func visit(binaryOpExpr: BinaryOperatorExpression, _ scope: FunctionDeclaration) throws -> BuiltinType {
    guard let lhs = try visit(binaryOpExpr.lhs, scope), let rhs = try visit(binaryOpExpr.rhs, scope) else {
      throw SemaError.TypeCheck.invalidType
    }
    
    guard lhs == rhs else {
      throw SemaError.TypeCheck.typeMismatch(expected: lhs, got: rhs)
    }
    
    return lhs
  }
	
	/// Visit a type expression and return the built in type
	private func visit(type: Type) -> BuiltinType {
		return mapSwiftTypeToBuiltinType(type) ?? .void
	}
  
  /// Visit a print statement and type check all of its arguments. At the moment, it only type
  /// checks the first argument, but this function must check all the arguments and ensure they
  /// are all of the same type for now, unless we add add proper support for multiple types
  /// in IRGen
  private func visit(printStmt: PrintStatement, _ scope: FunctionDeclaration) throws -> BuiltinType? {
    guard let firstStatement = printStmt.arguments.first else {
      throw SemaError.TypeCheck.emptyPrintStatement
    }
    
    return try visit(firstStatement, scope)
  }
  
  /// Visit a return statement and type check it
  private func visit(returnStmt: ReturnStatement, _ scope: FunctionDeclaration) throws -> BuiltinType? {
    let lhs = scope.signature.returnType
    guard let rhs = try visit(returnStmt.value, scope) else {
      throw SemaError.TypeCheck.invalidType
    }
    
    guard lhs == rhs else {
      throw SemaError.TypeCheck.typeMismatch(expected: lhs, got: rhs)
    }
    
    return rhs
  }
  
  ///
  private func mapSwiftTypeToBuiltinType(_ type: Type) -> BuiltinType? {
    if type is IntegerType {
      return BuiltinType.integer
    } else if type is FloatType {
      return BuiltinType.float
    } else if type is StringType {
      return BuiltinType.string
    } else if type is BoolType {
      return BuiltinType.bool
    } else {
      return BuiltinType.void
    }
  }
  
  /// Visit the main function and type check it.
  ///
  /// This is a dedicated visit function to specifically type check the main function
  /// as we're currently imposing some extra constraints on it and so it must be
  /// handled separately. Some of the constraints are automatically handled by
  /// other visit() functions so some of the checking is redundant here.
  private func visitMainFunction() throws {
    guard let mainFunc = ast.first as? FunctionDeclaration, mainFunc.signature.name == "main" else {
      throw SemaError.EntryPointError.notTopLevel
    }
    
    let mainFuncCountInAst = ast.count { ($0 as? FunctionDeclaration)?.signature.name == "main" }
    let mainFuncRetType = mainFunc.signature.returnType
    let mainFuncRetIsVoid = mainFuncRetType.rawName == BuiltinType.void.rawName
    let mainFuncArity = mainFunc.signature.arguments.count
    let mainFuncArityIsZero = mainFuncArity == 0
    
    if mainFuncCountInAst > 1 {
      throw SemaError.TypeCheck.invalidFunctionRedeclaration(name: "main", count: mainFuncCountInAst)
    }
    
    if !mainFuncArityIsZero {
      throw SemaError.TypeCheck.arityMismatch(name: "main", gotCount: mainFuncArity, expectedCount: 0)
    }
    
    if !mainFuncRetIsVoid {
      throw SemaError.TypeCheck.typeMismatch(expected: BuiltinType.void, got: mainFuncRetType)
    }
  }
  
}
