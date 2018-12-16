//
//  Token.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 16/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// An enum that describes the types of token that the parser
/// can work with
public enum Token {
  case colon
  case semicolon
  case parensOpen
  case parensClose
  case braceOpen
  case braceClose
  case comma
  case period
  
  case `func`
  case `let`
  case `var`
  case `int`
  case `float`
  case `void`
  case `bool`
  case `enum`
  case `case`
  case `if`
  case `else`
  case `return`
  case print
  case string
  
  case functionArrow
  case assignment
  
  case identifier(String)
  
  case constant(type: Constant, value: Value)
  case `operator`(type: Operator, precedence: Precedence)
  
  // Check if the token is an identifier (ex: a function name)
  func isIdentifier() -> Bool {
    if case .identifier(_) = self {
      return true
    }
    
    return false
  }
  
  // Check if the token is a constant (ex: integer literal)
  func isConstant() -> Bool {
    if case .constant(_, _) = self {
      return true
    }
    
    return false
  }
}

/// An enum that represents a constant token
public enum Constant {
  case `int`
  case `float`
  case `bool`
  case string
}

/// An enum that represents a value token containing a value
/// of any type
public enum Value {
  case value(Any)
}

/// An operator token
public enum Operator {
  case plus
  case minus
  case multiply
  case divide
}

/// A precedence token
public enum Precedence {
  case addition
  case multiplication
}

extension Token {
  /// Returns the length of the token
  var length: Int {
    switch self {
    case .colon,
         .semicolon,
         .parensOpen,
         .parensClose,
         .braceOpen,
         .braceClose,
         .comma,
         .period,
         .assignment: return 1
    case .if,
         .functionArrow: return 2
    case .var,
         .let,
         .int: return 3
    case .func,
         .void,
         .bool,
         .enum,
         .case,
         .else: return 4
    case .float,
         .print: return 5
    case .return,
         .string: return 6
      
    case let .identifier(id): return id.count
      
    case let .constant(type, .value(v)):
      switch type {
      case .int where v is Int: return String(v as! Int).count
      case .float where v is Float: return String(v as! Float).count
      case .bool where v is Bool: return (v as! Bool) ? 4 : 5
      case .string where v is String: return (v as! String).count
      default: return 0
      }
      
    case let .operator(type, _):
      switch type {
      case .plus,
           .minus,
           .multiply,
           .divide: return 1
      }
    }
  }
}

extension Token {
  /// Create a token from a lexeme. Return nil if the lexeme cannot be
  /// recognized
  init?(rawValue lexeme: String) {
    if lexeme ~= "[ \t\n]" {
      return nil
    } else if lexeme ~= "func" {
      self = .func
    } else if lexeme ~= "let" {
      self = .let
    } else if lexeme ~= "var" {
      self = .var
    } else if lexeme ~= "Int" {
      self = .int
    } else if lexeme ~= "Float" {
      self = .float
    } else if lexeme ~= "Void" {
      self = .void
    } else if lexeme ~= "Bool" {
      self = .bool
    } else if lexeme ~= "String" {
      self = .string
    } else if lexeme ~= "return" {
      self = .return
    } else if lexeme ~= "print" {
      self = .print
    } else if lexeme ~= "enum" {
      self = .enum
    } else if lexeme ~= "case" {
      self = .case
    } else if lexeme ~= "if" {
      self = .if
    } else if lexeme ~= "else" {
      self = .else
    } else if lexeme ~= "->" {
      self = .functionArrow
    } else if lexeme ~= "\\=" {
      self = .assignment
    } else if lexeme ~= "\\+" {
      self = .operator(type: .plus, precedence: .addition)
    } else if lexeme ~= "\\-" {
      self = .operator(type: .minus, precedence: .addition)
    } else if lexeme ~= "\\*" {
      self = .operator(type: .multiply, precedence: .multiplication)
    } else if lexeme ~= "\\/" {
      self = .operator(type: .divide, precedence: .multiplication)
    } else if lexeme ~= "\\:" {
      self = .colon
    } else if lexeme ~= "\\;" {
      self = .semicolon
    } else if lexeme ~= "\\(" {
      self = .parensOpen
    } else if lexeme ~= "\\)" {
      self = .parensClose
    } else if lexeme ~= "\\{" {
      self = .braceOpen
    } else if lexeme ~= "\\}" {
      self = .braceClose
    } else if lexeme ~= "\\," {
      self = .comma
    } else if lexeme ~= "\\." {
      self = .period
    } else if lexeme ~= "true|false" {
      guard let bool = Bool(lexeme.match("true|false")) else { return nil }
      self = .constant(type: .bool, value: .value(bool))
    } else if lexeme ~= "[a-zA-Z][a-zA-Z0-9]*" {
      self = .identifier(lexeme.match("[a-zA-Z][a-zA-Z0-9]*"))
    } else if lexeme ~= "[0-9]+\\.[0-9]*" {
      guard let float = Float(lexeme.match("[0-9]+\\.[0-9]*")) else { return nil }
      self = .constant(type: .float, value: .value(float))
    } else if lexeme ~= "[0-9]+" {
      guard let int = Int(lexeme.match("[0-9]+")) else { return nil }
      self = .constant(type: .int, value: .value(int))
    } else if lexeme ~= "\".*\"" {
      let string = String(lexeme.match("\".*\""))
      guard string.count > 0 else { return nil }
      self = .constant(type: .string, value: .value(string))
    } else {
      fatalError("No token for lexeme: \(lexeme)")
    }
  }
}
