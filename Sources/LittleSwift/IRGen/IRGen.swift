//
//  IRGen.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 21/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation
import LLVM

enum IRError: Error {
  case unsupportedExpression
  case unknownFunction(String)
  case unknownVariable(String)
  case arityMismatch(String, expected: Int, got: Int)
}

/// A class to generate LLVM IR for the code
final class IRGen {
  
  /// The AST
  private let ast: [Expression]
  
  // The IR Module
  private let module: Module
  
  /// The IR Builder
  private let builder: IRBuilder
  
  /// A map of function name to its signature
  private var signatureMap: [String: FunctionSignature] = [String: FunctionSignature]()
  
  /// A map of parameter name to its value
  private var parameterValues = [String: IRValue]()
  
  /// A map of local parameter name to its value
  private var localParams = [String: IRValue]()
  
  /// Init
  init(with ast: [Expression]) {
    self.ast = ast
    self.module = Module(name: "main")
    self.builder = IRBuilder(module: module)
  }
  
  /// Get the IR module
  func getModule() -> Module {
    return module
  }
  
  /// Lookup the signature for a function
  func lookup(for functionName: String) -> FunctionSignature? {
    return signatureMap[functionName]
  }
  
  /// Emit LLVM IR for the code
  func emit() {
    let funcSignatures = ast.enumerated().filter { $1 is FunctionSignature }
    let funcDecls = ast.enumerated().filter { $1 is FunctionDeclaration }
    
    for (_, signature) in funcSignatures {
      if let signature = signature as? FunctionSignature {
        signatureMap[signature.name] = signature
      }
    }
    
    for (_, declaration) in funcDecls {
      if let declaration = declaration as? FunctionDeclaration {
        signatureMap[declaration.signature.name] = declaration.signature
      }
    }
    
    for (_, signature) in funcSignatures {
      if let signature = signature as? FunctionSignature {
        let _ = emitFunctionSignature(signature)
      }
    }
    
    for (_, declaration) in funcDecls {
      if let declaration = declaration as? FunctionDeclaration {
        let _ = try? emitFunctionDeclaration(declaration)
      }
    }
  }
  
  /// Emit LLVM IR for an expression
  func emitExpression(_ expression: Expression) throws -> IRValue {
    if let expression = expression as? BoolType {
      return LLVM.IntType.int1.constant(expression.value ? 1 : 0)
    } else if let expression = expression as? FloatType {
      return LLVM.FloatType.float.constant(Double(expression.value))
    } else if let expression = expression as? IntegerType {
      return LLVM.IntType.int32.constant(expression.value)
    } else if let expression = expression as? StringType {
      return LLVM.ArrayType.constant(string: expression.value)
    } else if let expression = expression as? FunctionCallExpression {
      
      guard let funcSignature = lookup(for: expression.name) else {
        throw IRError.unknownFunction(expression.name)
      }
      
      let function = emitFunctionSignature(funcSignature)
      let callArgs = try expression.arguments.map(emitExpression)
      
      return builder.buildCall(function, args: callArgs)
    } else if let expression = expression as? VariableDeclaration {
      
      guard let param = parameterValues[expression.name] else {
        throw IRError.unknownVariable(expression.name)
      }
      
      return param
    } else if let expression = expression as? BinaryOperatorExpression {
      let lhsVal = try emitExpression(expression.lhs)
      let rhsVal = try emitExpression(expression.rhs)
      
      switch expression.operation {
        
      case .plus:
        return builder.buildAdd(lhsVal, rhsVal)
      case .minus:
        return builder.buildSub(lhsVal, rhsVal)
      case .multiply:
        return builder.buildMul(lhsVal, rhsVal)
      case .divide:
        return builder.buildDiv(lhsVal, rhsVal)
      }
    } else if let expression = expression as? ReturnStatement {
      let retValue = try emitExpression(expression.value)
      return builder.buildRet(retValue)
      
    } else if let expression = expression as? AssignmentExpression {
      let value = try emitExpression(expression.value)
      let type = getIRType(for: expression.variable.type)
      let name = expression.variable.name
      let local = builder.buildAlloca(type: type, name: name)
      let storedRef = builder.buildStore(value, to: local)
      
      addLocalParam(name: name, storedRef: local)
      return storedRef
    } else if let expression = expression as? PrintStatement {
      let printFunc = emitPrintf()
      
      if let e = expression.arguments.first as? PropertyAccessExpression {
        let ref = builder.buildLoad(localParams[e.name]!)
        let formatString = builder.buildGlobalStringPtr("%d\n", name: "PRINTF_DEC")
        return builder.buildCall(printFunc, args: [formatString, ref])
      } else if let typeExpr = expression.arguments.first as? Type {
        switch typeExpr {
        case let stringType as StringType:
          let ref = builder.buildGlobalStringPtr(stringType.value.replacingOccurrences(of: "\"", with: ""))
          let formatString = builder.buildGlobalStringPtr("%s\n", name: "PRINTF_STR")
          return builder.buildCall(printFunc, args: [formatString, ref])
          default: break
        }
      }
      
    } else if let expression = expression as? PropertyAccessExpression {
      
      if let value = parameterValues[expression.name] {
        return value
      } else if let value = localParams[expression.name] {
        return builder.buildLoad(value)
      }
    }
    
    throw IRError.unsupportedExpression
  }
  
  /// Append a local parameter to the parameter map
  func addLocalParam(name: String, storedRef: IRValue) {
    localParams[name] = storedRef
  }
  
  /// Emit LLVM IR for a function signature
  func emitFunctionSignature(_ signature: FunctionSignature) -> Function {
    
    if let function = module.function(named: signature.name) {
      return function
    }
    
    var argTypes: [IRType] = [IRType]()
    
    signature.arguments.forEach { argument in
      let type = getIRType(for: argument.type)
      argTypes.append(type)
    }
    
    let returnType: IRType = getIRType(for: signature.returnType)
    
    let funcType = FunctionType(argTypes: argTypes, returnType: returnType)
    
    let function = builder.addFunction(signature.name, type: funcType)
    
    for (var signature, name) in zip(function.parameters, signature.arguments) {
      signature.name = name.name
    }
    
    return function
  }
  
  /// Emit LLVM IR for a function declaration
  @discardableResult
  func emitFunctionDeclaration(_ definition: FunctionDeclaration) throws -> Function {
    let function = emitFunctionSignature(definition.signature)
    
    for (idx, arg) in definition.signature.arguments.enumerated() {
      let param = function.parameter(at: idx)!
      parameterValues[arg.name] = param
    }
    
    let entryBlock = function.appendBasicBlock(named: "entry")
    builder.positionAtEnd(of: entryBlock)
    
    var exprs: [IRValue] = [IRValue]()
    
    try definition.body.forEach { expression in
      let expr = try emitExpression(expression)
      exprs.append(expr)
    }
    
    if function.name == "main" || definition.signature.returnType == .void {
      builder.buildRetVoid()
    }
    
    parameterValues.removeAll()
    
    return function
  }
  
  /// Emit the LLVM IR for the C printf function
  func emitPrintf() -> Function {
    if let function = module.function(named: "printf") { return function }
    
    let printfType = FunctionType(argTypes: [PointerType(pointee: IntType.int8)], returnType: IntType.int32, isVarArg: true)
    return builder.addFunction("printf", type: printfType)
  }
  
  /// Map the built-in type to actual LLVM IR type
  private func getIRType(for typeNode: BuiltinType) -> IRType {
    switch typeNode.rawName {
    case BuiltinType.void.rawName:
      return LLVM.VoidType()
    case BuiltinType.float.rawName:
      return LLVM.FloatType.float
    case BuiltinType.integer.rawName:
      return LLVM.IntType.int32
    case BuiltinType.bool.rawName:
      return LLVM.IntType.int1
    case BuiltinType.string.rawName:
      return LLVM.ArrayType(elementType: IntType.int8, count: 128)
    default: break
    }
    return LLVM.VoidType()
  }
}
