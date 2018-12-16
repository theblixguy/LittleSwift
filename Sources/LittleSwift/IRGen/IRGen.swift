//
//  IRGen.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 21/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation
import LLVM

/// An enum that describes an IRGen error
enum IRError: Error {
  case unsupportedExpression
  case unknownFunction(String)
  case unknownVariable(String)
  case arityMismatch(String, expected: Int, got: Int)
  case invalidType
  case invalidStatement
}

/// An enum that describes a printf type specifier
enum PrintTypeSpecifier {
  case string, float, double, int
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
  private var signatureMap: [String: FunctionSignature] = [:]
  
  /// A map of parameter name to its value
  private var parameterValues: [String: IRValue] = [:]
  
  /// A map of local parameter name to its value
  private var localParams: [String: IRValue] = [:]
  
  /// A map of printf specifiers to their values
  private var printTypeSpecifiers: [PrintTypeSpecifier: IRValue] = [:]
  
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
  
  func lookup(for specifier: PrintTypeSpecifier) -> IRValue? {
    return printTypeSpecifiers[specifier]
  }
  
  /// Emit LLVM IR for the code
  func emit() {
    let funcSignatures = ast.enumerated().filter { $1 is FunctionSignature }
    let funcDecls = ast.enumerated().filter { $1 is FunctionDeclaration }
    
    // Build a function signature map using signatures
    for (_, signature) in funcSignatures {
      if let signature = signature as? FunctionSignature {
        signatureMap[signature.name] = signature
      }
    }
    
    // Build a function signature map using decl's signature,
    // in case we missed it
    for (_, declaration) in funcDecls {
      if let declaration = declaration as? FunctionDeclaration {
        signatureMap[declaration.signature.name] = declaration.signature
      }
    }
    
    // Emit LLVM IR for each function signature
    for (_, signature) in funcSignatures {
      if let signature = signature as? FunctionSignature {
        let _ = emitFunctionSignature(signature)
      }
    }
    
    // Emit LLVM IR for each function declaration
    for (_, declaration) in funcDecls {
      if let declaration = declaration as? FunctionDeclaration {
        let _ = try? emitFunctionDeclaration(declaration)
      }
    }
  }
  
  /// Emit LLVM IR for an expression
  func emitExpression(_ expression: Expression) throws -> IRValue {
    if let typeExpr = expression as? Type {
      return try emitType(typeExpr)
    } else if let callExpr = expression as? FunctionCallExpression {
      return try emitFunctionCallExpr(callExpr)
    } else if let variableDecl = expression as? VariableDeclaration {
      return try emitVariableDecl(variableDecl)
    } else if let binaryOpExpr = expression as? BinaryOperatorExpression {
      return try emitBinaryOperatorExpr(binaryOpExpr)
    } else if let returnStmt = expression as? ReturnStatement {
      return try emitReturnStmt(returnStmt)
    } else if let assignExpr = expression as? AssignmentExpression {
      return try emitAssignmentExpr(assignExpr)
    } else if let printStmt = expression as? PrintStatement {
      return try emitPrintStmt(printStmt)
    } else if let propAccessExpr = expression as? PropertyAccessExpression {
      return try emitPropertyAccessExpr(propAccessExpr)
    }
    throw IRError.unsupportedExpression
  }
  
  /// Emit LLVM IR for a type
  private func emitType(_ type: Type) throws -> IRValue {
    
    switch type {
    case let boolType as BoolType:
      return LLVM.IntType.int1.constant(boolType.value ? 1 : 0)
    case let floatType as FloatType:
      return LLVM.FloatType.float.constant(Double(floatType.value))
    case let intType as IntegerType:
      return LLVM.IntType.int32.constant(intType.value)
    case let stringType as StringType:
      return LLVM.ArrayType.constant(string: stringType.value)
    default: throw IRError.invalidType
    }
  }
  
  /// Emit LLVM IR for a variable declaration
  private func emitVariableDecl(_ decl: VariableDeclaration) throws -> IRValue {
    guard let param = parameterValues[decl.name] else {
      throw IRError.unknownVariable(decl.name)
    }
    
    return param
  }
  
  /// Emit LLVM IR for a binary operation
  private func emitBinaryOperatorExpr(_ expr: BinaryOperatorExpression) throws -> IRValue {
    let lhsVal = try emitExpression(expr.lhs)
    let rhsVal = try emitExpression(expr.rhs)
    
    switch expr.operation {
      
    case .plus:
      return builder.buildAdd(lhsVal, rhsVal)
    case .minus:
      return builder.buildSub(lhsVal, rhsVal)
    case .multiply:
      return builder.buildMul(lhsVal, rhsVal)
    case .divide:
      return builder.buildDiv(lhsVal, rhsVal)
    }
  }
  
  /// Emit LLVM IR for a return statement
  private func emitReturnStmt(_ stmt: ReturnStatement) throws -> IRValue {
    let retValue = try emitExpression(stmt.value)
    return builder.buildRet(retValue)
  }
  
  /// Emit LLVM IR for an assignment exression
  private func emitAssignmentExpr(_ expr: AssignmentExpression) throws -> IRValue {
    let value = try emitExpression(expr.value)
    let type = getIRType(for: expr.variable.type)
    let name = expr.variable.name
    let local = builder.buildAlloca(type: type, name: name)
    let storedRef = builder.buildStore(value, to: local)
    
    addLocalParam(name: name, storedRef: local)
    return storedRef
  }
  
  /// Emit LLVM IR for a function call
  private func emitFunctionCallExpr(_ expr: FunctionCallExpression) throws -> Call {
    guard let funcSignature = lookup(for: expr.name) else {
      throw IRError.unknownFunction(expr.name)
    }
    
    let emittedFunc = emitFunctionSignature(funcSignature)
    let callArgs = try expr.arguments.map(emitExpression)
    
    return builder.buildCall(emittedFunc, args: callArgs)
  }
  
  /// Emit LLVM IR for a print statement
  private func emitPrintStmt(_ stmt: PrintStatement) throws -> Call {
    let printFunc = emitPrintf()
    
    if let propExpr = stmt.arguments.first as? PropertyAccessExpression {
      let toPrint = builder.buildLoad(localParams[propExpr.name]!)
      
      var formatSpecifier: IRValue
      
      switch getBuiltinType(for: toPrint.type) {
      case .string:
        formatSpecifier = printfSpecifierForString()
      case .integer, .bool:
        formatSpecifier = printfSpecifierForInt()
      case .float:
        formatSpecifier = printfSpecifierForFloat()
      default: throw IRError.invalidType
      }
      
      return builder.buildCall(printFunc, args: [formatSpecifier, toPrint])
    }
    
    if let typeExpr = stmt.arguments.first as? Type {
      switch typeExpr {
        
      case let intType as IntegerType:
        let formatSpecifier = printfSpecifierForInt()
        let type = getIRType(for: .integer)
        let value = LLVM.IntType.int32.constant("\(intType.value)")
        let local = builder.buildAlloca(type: type)
        let storedRef = builder.buildStore(value, to: local)
        return builder.buildCall(printFunc, args: [formatSpecifier, storedRef])
        
      case let floatType as FloatType:
        let formatSpecifier = printfSpecifierForFloat()
        let type = getIRType(for: .float)
        let value = LLVM.FloatType.float.constant("\(floatType.value)")
        let local = builder.buildAlloca(type: type)
        let storedRef = builder.buildStore(value, to: local)
        return builder.buildCall(printFunc, args: [formatSpecifier, storedRef])
        
      case let boolType as BoolType:
        let formatSpecifier = printfSpecifierForInt()
        let type = getIRType(for: .bool)
        let value = LLVM.IntType.int1.constant("\(boolType.value)")
        let local = builder.buildAlloca(type: type)
        let storedRef = builder.buildStore(value, to: local)
        return builder.buildCall(printFunc, args: [formatSpecifier, storedRef])
        
      case let stringType as StringType:
        let formatSpecifier = printfSpecifierForString()
        let storedRef = builder.buildGlobalStringPtr(stringType.value.replacingOccurrences(of: "\"", with: ""))
        return builder.buildCall(printFunc, args: [formatSpecifier, storedRef])
        
      default: throw IRError.invalidType
      }
    }
    
    unreachable()
  }
  
  /// Emit LLVM IR for a property (i.e. variable) access expression
  private func emitPropertyAccessExpr(_ expr: PropertyAccessExpression) throws -> IRValue {
    if let value = parameterValues[expr.name] {
      return value
    } else if let value = localParams[expr.name] {
      return builder.buildLoad(value)
    }
    
    unreachable()
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
  
  /// Return the format specifier for a String
  ///
  /// If the specifier does not exist, emit it and then return it
  private func printfSpecifierForString() -> IRValue {
    if let specifier = lookup(for: .string) {
      return specifier
    }
    
    let formatSpecifier = builder.buildGlobalStringPtr("%s\n", name: "PRINTF_STRING")
    printTypeSpecifiers[.string] = formatSpecifier
    return formatSpecifier
  }
  
  /// Return the format specifier for a Integer
  ///
  /// If the specifier does not exist, emit it and then return it
  private func printfSpecifierForInt() -> IRValue {
    if let specifier = lookup(for: .int) {
      return specifier
    }
    
    let formatSpecifier = builder.buildGlobalStringPtr("%d\n", name: "PRINTF_INTEGER")
    printTypeSpecifiers[.int] = formatSpecifier
    return formatSpecifier
  }
  
  /// Return the format specifier for a Float
  ///
  /// If the specifier does not exist, emit it and then return it
  private func printfSpecifierForFloat() -> IRValue {
    if let specifier = lookup(for: .float) {
      return specifier
    }
    
    let formatSpecifier = builder.buildGlobalStringPtr("%f\n", name: "PRINTF_FLOAT")
    printTypeSpecifiers[.float] = formatSpecifier
    return formatSpecifier
  }
  
  private func unreachable() -> Never {
    fatalError("Unreachable")
  }
  
  /// Append a local parameter to the parameter map
  func addLocalParam(name: String, storedRef: IRValue) {
    localParams[name] = storedRef
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
    default: unreachable()
    }
  }
  
  /// Map LLVM IR type to builtin type
  private func getBuiltinType(for llvmType: IRType) -> BuiltinType {
    switch llvmType {
    case _ as LLVM.ArrayType: return .string
    case _ as LLVM.VoidType: return .void
    case _ as LLVM.FloatType: return .float
    case _ as LLVM.IntType: return .integer
    default: return .void
    }
  }
}
