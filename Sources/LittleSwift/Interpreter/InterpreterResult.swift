//
//  InterpreterResult.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 15/12/2018.
//

import Foundation

extension Interpreter {
  /// A struct that contains the result of the evaluation of
  /// an expression
  struct Result {
    
    /// An enum that describes the type of the result
    enum ValueType {
      /// An Integer type
      case int
      /// A float type
      case float
      /// A String type
      case string
      /// A Bool type
      case bool
      /// A Void type
      case void
      /// An invalid type
      case invalid
    }
    
    /// The raw value of the result
    private var rawValue: Any!
    /// The type of the raw value
    private var rawValueType: ValueType!
    
    /// Initialize the result with a value
    init(value: Any) {
      set(to: value)
    }
    
    /// Initialize the result with nothing
    private init(with value: Any? = nil) {
      // No-op
    }
    
    /// Set the value of the result
    private mutating func set(to value: Any) {
      precondition(isValidValue(value))
      
      rawValue = value
      rawValueType = type(of: rawValue)
    }
    
    /// Check if this result can be safely accessed
    func canAccess() -> Bool {
      return rawValue != nil && rawValueType != .invalid
    }
    
    /// Return the result as an Int
    func int() -> Int {
      precondition(rawValueType == .int)
      precondition(rawValue != nil)
      
      return rawValue as! Int
    }
    
    /// Return the result as a Float
    func float() -> Float {
      precondition(rawValueType == .float)
      precondition(rawValue != nil)
      
      return rawValue as! Float
    }
    
    /// Return the result as a String
    func string() -> String {
      precondition(rawValueType == .string)
      precondition(rawValue != nil)
      
      return rawValue as! String
    }
    
    /// Return the result as a Bool
    func bool() -> Bool {
      precondition(rawValueType == .bool)
      precondition(rawValue != nil)
      
      return rawValue as! Bool
    }
    
    /// Return the type of the result
    func valueType() -> ValueType {
      precondition(rawValueType != nil)
      
      return rawValueType
    }
    
    /// Return the raw result value
    func raw() -> Any {
      precondition(rawValue != nil)
      
      return rawValue
    }
    
    /// Return the result value as `String`
    func rawAsString() -> String {
      precondition(rawValue != nil)
      precondition(rawValueType != .invalid)
      
      switch valueType() {
      case .bool:
        return String(rawValue as! Bool)
      case .float:
        return String(rawValue as! Float)
      case .int:
        return String(rawValue as! Int)
      case .string:
        return (rawValue as! String).replacingOccurrences(of: "\"", with: "")
      case .void:
        return ""
      default: unreachable()
      }
    }
    
    /// Check if the result is invalid
    func isInvalid() -> Bool {
      precondition(rawValue != nil)
      precondition(rawValueType != nil)
      
      return isValidValue(rawValueType)
    }
    
    /// Check if the result is a number
    func isNumber() -> Bool {
      precondition(rawValueType != nil)
      
      return rawValueType == .int || rawValueType == .float
    }
    
    /// Check if the result is a Void
    func isVoid() -> Bool {
      precondition(rawValueType != nil)
      
      return rawValueType == .void
    }
    
    /// Check if the result has a valid type
    private func isValidValue(_ value: Any) -> Bool {
      return type(of: value) != .invalid
    }
    
    /// Check the type of the result
    private func type(of someValue: Any) -> ValueType {
      if someValue is Int {
        return .int
      }
      
      if someValue is Float {
        return .float
      }
      
      if someValue is Bool {
        return .bool
      }
      
      if someValue is String {
        return .string
      }
      
      if someValue is Void {
        return .void
      }
      
      return .invalid
    }
    
    /// Fatal error when this function is called
    private func unreachable() -> Never {
      fatalError("Unreachable")
    }
    
    /// Return an empty result
    static func empty() -> Result {
      return Result()
    }
    
    /// Return a result with a Void value
    static func void() -> Result {
      return Result(value: Void())
    }
  }
}
