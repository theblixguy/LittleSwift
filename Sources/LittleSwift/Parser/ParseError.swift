//
//  ParseError.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 20/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// A namespace to access different parsing errors
public struct ParseError {
  
  /// A namespace to access categories of parsing errors
  public struct Category {
    
    /// An enum that describes a parsing expectation error
    ///
    /// - character: The parser expected a character
    /// - literal: The parser expect a literal (.int, .string)
    /// - identifier: The parser expected an identifier
    /// - number: The parser expected a number
    /// - expression: The parser expected an expression
    /// - print: The parser expected the print statement
    /// - type: The parser expected a type
    /// - variable: The parser expected a variable
    /// - operator: The parser expected an `Operator`
    /// - return: The parser expected the `return` statement
    /// - enum: The parser expected an enum
    /// - string: The parser expected a `String`
    /// - bool: The parser expected a `Bool`
    /// - function: The parser expected a `func`
    public enum Expectation: Error {
      case character(String)
      case literal(Literal)
      case identifier
      case number
      case expression
      case print
      case type
      case variable
      case `operator`
      case `return`
      case `enum`
      case function
      case parens(ParensType)
      
      /// An enum that describes different types of literals
      /// that the parser can read
      ///
      /// - string: A string literal
      /// - bool: A bool literal
      public enum Literal {
        case string, `bool`
      }
      
      /// An enum that describes the type of parenthesis
      public enum ParensType {
        case open, close
      }
    }
  }
}
