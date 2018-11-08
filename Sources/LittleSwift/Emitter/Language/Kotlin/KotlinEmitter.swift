//
//  KotlinEmitter.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 21/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

public protocol KotlinEmittable: Emittable {
  func emit() -> KotlinEmitted
}

public protocol KotlinEmitter: Emitter {
  func emit() -> KotlinEmitted
}

public protocol KotlinEmitted: Emitted {
  var value: String { get }
}

struct KotlinEmittedContainer: KotlinEmitted {
  let value: String
}

extension KotlinEmittedContainer {
  static func empty() -> KotlinEmitted {
    return KotlinEmittedContainer(value: "")
  }
}

struct KotlinEmitterProvider: KotlinEmitter {
  private let ast: [Expression]
  
  init(with ast: [Expression]) {
    self.ast = ast
  }
  
  func emit() -> KotlinEmitted {
    
    var emittedExpr: String = ""
    
    ast.forEach { expression in
      guard let expression = expression as? KotlinEmittable else { return }
      emittedExpr.append(expression.emit().value)
      emittedExpr.append("\n\n")
    }
    
    return KotlinEmittedContainer(value: emittedExpr)
  }
}

extension AssignmentExpression: KotlinEmittable {
  
  public func emit() -> KotlinEmitted {
    guard let value = value as? KotlinEmittable else {
      return KotlinEmittedContainer.empty()
    }
    
    let assignExpr = variable.emit().value
    let _value = value.emit().value
    return KotlinEmittedContainer(value: "\(assignExpr) = \(_value)")
  }
}

extension VariableDeclaration: KotlinEmittable {
  
  public func emit() -> KotlinEmitted {
    let _mutability = mutability == .mutating ? "var" : "val"
    let _typeNode = BuiltinType(rawName: type.rawName)
    let _type = returnTypeString(for: _typeNode)
    let decl = "\(_mutability) \(name): \(_type)"
    return KotlinEmittedContainer(value: decl)
  }
  
  private func returnTypeString(for type: BuiltinType) -> String {
    switch type.rawName {
    case BuiltinType.void.rawName: return ""
    case BuiltinType.string.rawName: return "String"
    case BuiltinType.integer.rawName: return "Int"
    case BuiltinType.float.rawName: return "Float"
    case BuiltinType.bool.rawName: return "Boolean"
    default: return ""
    }
  }
}

extension StringType: KotlinEmittable {
  
  public func emit() -> KotlinEmitted {
    return KotlinEmittedContainer(value: value)
  }
}

extension IntegerType: KotlinEmittable {
  
  public func emit() -> KotlinEmitted {
    return KotlinEmittedContainer(value: "\(value)")
  }
}

extension FloatType: KotlinEmittable {
  
  public func emit() -> KotlinEmitted {
    return KotlinEmittedContainer(value: "\(value)")
  }
}

extension BoolType: KotlinEmittable {
  
  public func emit() -> KotlinEmitted {
    return KotlinEmittedContainer(value: "\(value)")
  }
}

extension BinaryOperatorExpression: KotlinEmittable {
  
  public func emit() -> KotlinEmitted {
    guard let lhs = lhs as? KotlinEmittable, let rhs = rhs as? KotlinEmittable else {
      return KotlinEmittedContainer.empty()
    }
    
    return KotlinEmittedContainer(value: "\(lhs.emit().value) \(returnOperatorString(for: operation)) \(rhs.emit().value)")
  }
  
  private func returnOperatorString(for operator: Operator) -> String {
    switch `operator` {
    case .plus: return "+"
    case .minus: return "-"
    case .multiply: return "*"
    case .divide: return "/"
    }
  }
}

extension PropertyAccessExpression: KotlinEmittable {
  
  public func emit() -> KotlinEmitted {
    return KotlinEmittedContainer(value: name)
  }
}

extension IfStatement: KotlinEmittable {
  
  public func emit() -> KotlinEmitted {
    guard let conditional = conditional as? KotlinEmittable, let body = body as? [KotlinEmittable] else {
      return KotlinEmittedContainer.empty()
    }
    
    var _emitted = ""
    _emitted.append("if (\(conditional.emit().value)) {\n")
    _emitted.append(body.map { "\t\t" + $0.emit().value }.joined(separator: "\n"))
    _emitted.append("\n\t}")
    return KotlinEmittedContainer(value: _emitted)
  }
}

extension PrintStatement: KotlinEmittable {
  
  public func emit() -> KotlinEmitted {
    guard let printExpressions = arguments as? [KotlinEmittable] else {
      return KotlinEmittedContainer.empty()
    }
    
    let _printExprs = "print(\(printExpressions.map { $0.emit().value }.first ?? ""))"
    return KotlinEmittedContainer(value: _printExprs)
  }
}

extension ReturnStatement: KotlinEmittable {
  
  public func emit() -> KotlinEmitted {
    guard let returnExpression = value as? KotlinEmittable else {
      return KotlinEmittedContainer.empty()
    }
    
    return KotlinEmittedContainer(value: "return \(returnExpression.emit().value)")
  }
}

extension FunctionDeclaration: KotlinEmittable {
  
  public func emit() -> KotlinEmitted {
    guard let body = body as? [KotlinEmittable] else {
      return KotlinEmittedContainer.empty()
    }
    
    let _signature = signature.emit().value
    let _body = body.map { "\t" + $0.emit().value }.joined(separator: "\n")
    let declaration = "\(_signature) {\n\(_body)\n}"
    return KotlinEmittedContainer(value: declaration)
  }
}

extension FunctionSignature: KotlinEmittable {
  
  public func emit() -> KotlinEmitted {
    var signature: String {
      let _signature = arguments.map { $0.emit().value.dropFirst(4) }.joined(separator: ", ")
      if _signature.isEmpty && name.elementsEqual("main") {
        return "args: Array<String>"
      }
      return _signature
    }
    
    let _returnTypeStr = returnTypeString(for: returnType)
    
    var _fullSignature = ""
    
    if returnType.rawName == BuiltinType.void.rawName {
      _fullSignature = "fun \(name)(\(signature))"
    } else {
      _fullSignature = "fun \(name)(\(signature)): \(_returnTypeStr)"
    }
    
    return KotlinEmittedContainer(value: _fullSignature)
  }
  
  private func returnTypeString(for type: BuiltinType) -> String {
    switch type.rawName {
    case BuiltinType.void.rawName: return ""
    case BuiltinType.string.rawName: return "String"
    case BuiltinType.integer.rawName: return "Int"
    case BuiltinType.float.rawName: return "Float"
    case BuiltinType.bool.rawName: return "Boolean"
    default: return ""
    }
  }
}

extension FunctionCallExpression: KotlinEmittable {
  
  public func emit() -> KotlinEmitted {
    guard let arguments = arguments as? [KotlinEmittable] else {
      return KotlinEmittedContainer.empty()
    }
    
    let _arguments = arguments.map { $0.emit().value }.joined(separator: ", ")
    return KotlinEmittedContainer(value: "\(name)(\(_arguments))")
  }
}
