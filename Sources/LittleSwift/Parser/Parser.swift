//
//  Parser.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 16/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// A class responsible for parsing the tokens and generating
/// an AST
public class Parser {
  
  /// The tokens
  private let tokens: [Token]
  /// The index of the current token. This is the token that the
  /// parser is currently looking at.
  private var currentTokenIndex = 0
  
  /// The initializer for the class
  init(tokens: [Token]) {
    self.tokens = tokens
  }
  
  /// Returns whether there are still tokens available for parsing
  private func tokensAvailable() -> Bool {
    return currentTokenIndex < tokens.count
  }
  
  /// Get the current token that the parser is looking at
  private func getCurrentToken() -> Token {
    return tokens[currentTokenIndex]
  }
  
  /// Peek at the next token
  private func peekNextToken() -> Token {
    return tokens[currentTokenIndex + 1]
  }
  
  /// Move to the next token and return the previous token
  private func getCurrentTokenAndMoveToNext() -> Token {
    let token = tokens[currentTokenIndex]
    currentTokenIndex += 1
    return token
  }
  
  /// Consume the current token and move to the next token
  private func consumeToken() {
    currentTokenIndex += 1
  }
  
  /// Decrease the current token index (default by 1)
  private func rewindToken(by steps: Int = 1) {
    currentTokenIndex -= steps
  }
  
  /// Peek at the previous token
  private func peekLastToken() -> Token {
    return tokens[currentTokenIndex - 1]
  }
  
  /// Get the precedence of the current token. Returns
  /// Int.min if the current token isn't an operator
  private func getCurrentTokenPrecedence() -> Int {
    guard tokensAvailable() else {
      return Int.min
    }
    
    let currentToken = getCurrentToken()
    
    switch currentToken {
    case let .operator(type, _):
      switch type {
      case .plus: return 140
      case .minus: return 140
      case .multiply: return 150
      case .divide: return 150
      }
    default: return Int.min
    }
  }
  
  /// Parse the tokens and return an AST
  func parseTokens() throws -> [Expression] {
    var nodes = [Expression]()
    while tokensAvailable() {
      let statement = try parseAnyExpression()
      nodes.append(statement)
    }
    return nodes
  }
  
  /// Parse an expression depending on the current token
  private func parseAnyExpression() throws -> Expression {
    switch getCurrentToken() {
    case .func:
      return try parseFunctionDeclaration()
      
    case .if:
      return try parseIfStatement()
      
    case .let, .var:
      return try parseVariableDeclarationOrAssignment()
      
    case .return:
      return try parseReturnStatement()
      
    case .print:
      return try parsePrintStatement()
      
    default:
      return try parseSimpleOrOperatorExpression()
    }
  }
  
  /// Parse a simple operation and then try parsing a operation expression
  /// with that expression
  private func parseSimpleOrOperatorExpression() throws -> Expression {
    let lhs = try parseSimpleExpression()
    return try parseOperatorExpression(expression: lhs)
  }
  
  /// Parse a simple expression (such as identifiers or types)
  private func parseSimpleExpression() throws -> Expression {
    switch getCurrentToken() {
    case .identifier(_):
      return try parseFunctionCallOrAnIdentifier()
      
    case let .constant(type, _):
      switch type {
      case .int:
        return try parseInteger()
      case .float:
        return try parseFloat()
      case .bool:
        return try parseBool()
      case .string:
        return try parseString()
      }
      
    case .parensOpen:
      return try parseParenthesis()
      
    default:
      throw ParseError.Category.Expectation.expression
    }
  }
  
  /// Parse an if statement expression
  private func parseIfStatement() throws -> IfStatement {
    guard case .if = getCurrentTokenAndMoveToNext() else {
      throw ParseError.Category.Expectation.character("if")
    }
    
    var conditional: Expression! = nil
    
    if case .let = getCurrentToken() {
      let bindingExpression = try parseAnyExpression()
      conditional = bindingExpression
    }
    else {
      let conditionalExpression = try parseSimpleOrOperatorExpression()
      conditional = conditionalExpression
    }
    
    let body = try parseFunctionBody()
    return IfStatement(conditional: conditional, body: body)
  }
  
  /// Parse the function body and return the containing statements
  private func parseFunctionBody() throws -> [Expression] {
    consumeToken()
    
    var statements = [Expression]()
    
    if case .braceClose = getCurrentToken() {
      consumeToken()
      statements = []
    }
    else {
      while true {
        if case .braceClose = getCurrentToken() {
          consumeToken()
          break
        }
        
        let node = try parseAnyExpression()
        statements.append(try parseOperatorExpression(expression: node))
      }
    }
    
    return statements
  }
  
  /// Parse the return statement
  private func parseReturnStatement() throws -> ReturnStatement {
    guard case .return = getCurrentTokenAndMoveToNext() else {
      throw ParseError.Category.Expectation.return
    }
    
    let value = try parseSimpleOrOperatorExpression()
    return ReturnStatement(value: value)
  }
  
  /// Parse the print statement
  private func parsePrintStatement() throws -> PrintStatement {
    guard case .print = getCurrentTokenAndMoveToNext() else {
      throw ParseError.Category.Expectation.print
    }
    
    let arguments = try parseFunctionCallArguments()
    return PrintStatement(arguments: arguments)
  }
  
  /// Parse a variable declaration or a variable assignment expression
  private func parseVariableDeclarationOrAssignment() throws -> Expression {
    var mutability: DeclarationModifier.Mutation! = nil
    let curToken = getCurrentToken()
    
    if case .let = curToken {
      mutability = .nonmutating
    }
    else if case .var = curToken {
      mutability = .mutating
    }
    else {
      throw ParseError.Category.Expectation.variable
    }
    
    consumeToken()
    
    guard case let .identifier(id) = getCurrentTokenAndMoveToNext() else {
      throw ParseError.Category.Expectation.identifier
    }
    
    if peekNextToken().isConstant() || peekNextToken().isIdentifier() {
      consumeToken()
      let assignedValue = try parseSimpleOrOperatorExpression()
      let variable = VariableDeclaration(mutability: mutability, name: id, type: .placeholder)
      return AssignmentExpression(variable: variable, value: assignedValue)
    }
    
    consumeToken()
    
    let type = try parseType()
    
    if case .assignment = getCurrentToken() {
      consumeToken()
      let assignedValue = try parseSimpleOrOperatorExpression()
      let variable = VariableDeclaration(mutability: mutability, name: id, type: type)
      return AssignmentExpression(variable: variable, value: assignedValue)
    }
    
    return VariableDeclaration(mutability: mutability, name: id, type: type)
  }
  
  /// Parse a LLVM builtin type
  private func parseType() throws -> BuiltinType {
    switch getCurrentTokenAndMoveToNext() {
    case .int: return BuiltinType.integer
    case .float: return BuiltinType.float
    case .string: return BuiltinType.string
    case .bool: return BuiltinType.bool
    case .void: return BuiltinType.void
    case let .identifier(id): return BuiltinType(rawName: id)
    default:
      throw ParseError.Category.Expectation.type
    }
  }
  
  /// Parse a function declaration
  private func parseFunctionDeclaration() throws -> FunctionDeclaration {
    guard case .func = getCurrentTokenAndMoveToNext() else {
      throw ParseError.Category.Expectation.function
    }
    
    let signature = try parseFunctionSignature()
    let body = try parseFunctionBody()
    return FunctionDeclaration(signature: signature, body: body)
  }
  
  /// Parse a function signature
  private func parseFunctionSignature() throws -> FunctionSignature {
    guard case let .identifier(name) = getCurrentTokenAndMoveToNext() else {
      throw ParseError.Category.Expectation.identifier
    }
    
    let arguments = try parseFunctionSignatureArguments()
    
    if case .braceOpen = getCurrentToken() {
      return FunctionSignature(name: name, arguments: arguments, returnType: .void)
    }
    
    consumeToken()
    
    let returnType = try parseType()
    return FunctionSignature(name: name, arguments: arguments, returnType: returnType)
  }
  
  /// Parse a function's arguments in its signature
  private func parseFunctionSignatureArguments() throws -> [VariableDeclaration] {
    consumeToken()
    
    var arguments = [VariableDeclaration]()
    
    while true {
      if case .parensClose = getCurrentToken() {
        break
      }
      else {
        if case let .identifier(name) = getCurrentTokenAndMoveToNext() {
          consumeToken()
          let type = try parseType()
          let argument = VariableDeclaration(mutability: .nonmutating, name: name, type: type)
          arguments.append(argument)
        }
      }
    }
    
    consumeToken()
    
    return arguments
  }
  
  /// Parse the arguments to a function call
  private func parseFunctionCallArguments() throws -> [Expression] {
    consumeToken()
    
    var arguments = [Expression]()
    
    while true {
      if case .parensClose = getCurrentToken() {
        break
      }
      if case .comma = getCurrentToken() {
        consumeToken()
      }
      else {
        let argument = try parseSimpleOrOperatorExpression()
        arguments.append(argument)
      }
    }
    
    consumeToken()
    
    return arguments
  }
  
  /// Parse a function call or an identifier
  private func parseFunctionCallOrAnIdentifier() throws -> Expression {
    let name = try parseIdentifierValue()
    
    guard case .parensOpen = getCurrentToken() else {
      return PropertyAccessExpression(name: name)
    }
    
    let arguments = try parseFunctionCallArguments()
    return FunctionCallExpression(name: name, arguments: arguments)
  }
  
  /// Parse an operator expression (if possible)
  private func parseOperatorExpression(expression: Expression, precedence: Int = 0) throws -> Expression {
    var leftExpression = expression
    
    while true {
      let tokenPrecedence = getCurrentTokenPrecedence()
      
      if tokenPrecedence < precedence {
        return leftExpression
      }
      
      guard case let .operator(op, _) = getCurrentTokenAndMoveToNext() else {
        throw ParseError.Category.Expectation.operator
      }
      
      var rightExpression = try parseSimpleOrOperatorExpression()
      let nextTokenPrecedence = getCurrentTokenPrecedence()
      
      if tokenPrecedence < nextTokenPrecedence {
        rightExpression = try parseOperatorExpression(expression: rightExpression, precedence: tokenPrecedence + 1)
      }
      
      leftExpression = BinaryOperatorExpression(lhs: leftExpression, operation: op, rhs: rightExpression)
    }
    
  }
  
  /// Parse parenthesis
  private func parseParenthesis() throws -> Expression {
    guard case .parensOpen = getCurrentTokenAndMoveToNext() else {
      throw ParseError.Category.Expectation.parens(.open)
    }
    
    let expression = try parseSimpleOrOperatorExpression()
    
    guard case .parensClose = getCurrentTokenAndMoveToNext() else {
      throw ParseError.Category.Expectation.parens(.close)
    }
    
    return expression
  }
  
  /// Parse a boolean literal
  private func parseBool() throws -> BoolType {
    guard case let .constant(type, .value(v)) = getCurrentTokenAndMoveToNext(), type == .bool else {
      throw ParseError.Category.Expectation.literal(.bool)
    }
    
    return BoolType(value: v as! Bool)
  }
  
  /// Parse a integer literal
  private func parseInteger() throws -> Expression {
    guard case let .constant(type, .value(v)) = getCurrentTokenAndMoveToNext(), type == .int else {
      throw ParseError.Category.Expectation.number
    }
    
    return IntegerType(value: v as! Int)
  }
  
  /// Parse a float literal
  private func parseFloat() throws -> Expression {
    guard case let .constant(type, .value(v)) = getCurrentTokenAndMoveToNext(), type == .float else {
      throw ParseError.Category.Expectation.number
    }
    
    return FloatType(value: v as! Float)
  }
  
  /// Parse a string literal
  private func parseString() throws -> Expression {
    guard case let .constant(type, .value(v)) = getCurrentTokenAndMoveToNext(), type == .string else {
      throw ParseError.Category.Expectation.literal(.string)
    }
    
    return StringType(value: v as! String)
  }
  
  /// Parse the value of an identifier
  private func parseIdentifierValue() throws -> String {
    guard case let .identifier(value) = getCurrentTokenAndMoveToNext() else {
      throw ParseError.Category.Expectation.identifier
    }
    return value
  }
  
}
