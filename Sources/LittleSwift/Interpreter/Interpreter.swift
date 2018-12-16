//
//  Interpreter.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 15/12/2018.
//

import Foundation

/// A class that walks the type-checked AST and evaluates it
final class Interpreter {
  
  /// The AST expressions
  private let ast: [Expression]
  
  /// A flag that indicates whether the interpreter should dump
  /// the results for each expression
  private let shouldDumpResults: Bool
  
  /// An array of `ExpressionResult` that contains the result for
  /// each evaluated expression
  private var expressionResults: [ExpressionResult] = []
  
  /// A stack that contains the evaluated results for the arguments of
  /// the to-be-invoked function call
  private var callStack: Stack<Expression> = .init()
  
  /// A cache to store recently popped results for the arguments of
  /// the invoked function call.
  ///
  /// This allows us to refer to arguments that are passed in
  /// function calls more than once, as otherwise they won't
  /// exist on the stack once accessed
  private var callStackExpressionCache: [ExpressionResult] = .init()
  
  /// Initialize the interpreter with the AST
  init(with ast: [Expression], shouldDumpResults: Bool = false) {
    self.ast = ast
    self.shouldDumpResults = shouldDumpResults
  }
  
  /// Run the interpreter (REPL)
  func run() {
    guard let mainFunction = ast.mainFunction() else { unreachable() }
    
    mainFunction.body.forEach { expression in
      let result = evaluate(expression)
      append(result, for: expression)
    }
    
    if shouldDumpResults {
      Printer.printReplResults(expressionResults)
    }
  }
  
  /// Evaluates an AST expression and returns the result
  private func evaluate(_ expr: Expression) -> Result {
    switch expr {
      
    case let type as Type:
      return evaluateLiteralType(type)
    case let assignmentExpr as AssignmentExpression:
      return evaluateAssignmentExpression(assignmentExpr)
    case let operatorExpr as BinaryOperatorExpression:
      return evaluateOperatorExpr(operatorExpr)
    case let printStmt as PrintStatement:
      return evaluatePrintStatement(printStmt)
    case let propAccess as PropertyAccessExpression:
      return evaluatePropertyAccessExpr(propAccess)
    case let returnStmt as ReturnStatement:
      return evaluateReturnStmt(returnStmt)
    case let callExpr as FunctionCallExpression:
      return evaluateFunctionCallExpr(callExpr)
    default:
      return Result.empty()
    }
  }
  
  /// Evaluates a literal type (like an Int or Bool) and returns the result
  private func evaluateLiteralType(_ type: Type) -> Result {
    switch type {
    case let intType as IntegerType:
      return Result(value: intType.value)
    case let floatType as FloatType:
      return Result(value: floatType.value)
    case let boolType as BoolType:
      return Result(value: boolType.value)
    case let stringType as StringType:
      return Result(value: stringType.value)
    default:
      return Result.empty()
    }
  }
  
  /// Evaluates a variable assignment and returns the result
  private func evaluateAssignmentExpression(_ expr: AssignmentExpression) -> Result {
    return evaluate(expr.value)
  }
  
  /// Evaluates an operator expression (like 1 + 2) and returns the result
  private func evaluateOperatorExpr(_ expr: BinaryOperatorExpression) -> Result {
    let lhs = evaluate(expr.lhs)
    let rhs = evaluate(expr.rhs)
    
    guard !lhs.isInvalid() && !rhs.isInvalid() else {
      return Result.empty()
    }
    
    guard lhs.isNumber() && rhs.isNumber() else {
      return Result.empty()
    }
    
    if lhs.valueType() == .int && rhs.valueType() == .int {
      return evaluateOperatorWithIntLiteral(operator: expr.operation, lhs: lhs.int(), rhs: rhs.int())
    } else if lhs.valueType() == .float && rhs.valueType() == .float {
      return evaluateOperatorWithFloatLiteral(operator: expr.operation, lhs: lhs.float(), rhs: rhs.float())
    }
    
    unreachable()
  }
  
  /// Evaluates the operator expression with Int types and returns the result
  private func evaluateOperatorWithIntLiteral(operator: Operator, lhs: Int, rhs: Int) -> Result {
    switch `operator` {
    case .plus:
      let addedValue = lhs + rhs
      return Result(value: addedValue)
    case .minus:
      let subtractedValue = lhs - rhs
      return Result(value: subtractedValue)
    case .multiply:
      let multipliedValue = lhs * rhs
      return Result(value: multipliedValue)
    case .divide:
      let dividedValue = lhs / rhs
      return Result(value: dividedValue)
    }
  }
  
   /// Evaluates the operator expression with Float types and returns the result
  private func evaluateOperatorWithFloatLiteral(operator: Operator, lhs: Float, rhs: Float) -> Result {
    switch `operator` {
    case .plus:
      let addedValue = lhs + rhs
      return Result(value: addedValue)
    case .minus:
      let subtractedValue = lhs - rhs
      return Result(value: subtractedValue)
    case .multiply:
      let multipliedValue = lhs * rhs
      return Result(value: multipliedValue)
    case .divide:
      let dividedValue = lhs / rhs
      return Result(value: dividedValue)
    }
  }
  
  /// Evaluates a print statement, prints the value and returns the result
  private func evaluatePrintStatement(_ stmt: PrintStatement) -> Result {
    guard let toPrint = stmt.arguments.first else { unreachable() }
    
    let result = evaluate(toPrint)
    Printer.printReplString(result.rawAsString())
    
    return .void()
  }
  
  /// Evaluates a property access expression and returns the result
  private func evaluatePropertyAccessExpr(_ expr: PropertyAccessExpression) -> Result {
    
    // Check if the result exists in the cache first and return if it does
    if let cachedResult = callStackExpressionCache.first(where: { ($0.expression as? PropertyAccessExpression)?.name == expr.name })?.result {
      return cachedResult
    }
    
    // Check if the call stack is empty, if it is then we don't need to
    // evaluate anything
    guard !callStack.empty() else {
      // Nothing in the call stack, lookup the property and return it
      return lookupResult(for: expr.name)
    }
    
    // Evaluate the argument on the call stack
    guard let expr = callStack.pop() else { unreachable() }
    
    let result = evaluate(expr)
    
    callStackExpressionCache.append(ExpressionResult(expression: expr, result: result))
    
    return result
  }
  
  /// Evaluates a return statement and returns the result
  private func evaluateReturnStmt(_ stmt: ReturnStatement) -> Result {
    return evaluate(stmt.value)
  }
  
  /// Evaluate a function call and return the result
  private func evaluateFunctionCallExpr(_ expr: FunctionCallExpression) -> Result {
    
    expr.arguments.forEach { argResult in
      callStack.push(argResult)
    }
    
    let decl = lookupDecl(for: expr.name)
    
    var results: [ExpressionResult] = []
    
    decl.body.forEach { expression in
      let result = evaluate(expression)
      results.append(ExpressionResult(expression: expression, result: result))
    }
    
    // Clean up the cache
    callStackExpressionCache.removeAll()
    
    var resultToReturn: Result = .void()
    
    if let returnStatementResult = lookupReturnStatement(in: results) {
      resultToReturn = returnStatementResult
    }
    
    return resultToReturn
  }
  
  /// A helper that calls fatalError().
  ///
  /// This is used for many things, such as to enforce that expressions are evaluated
  /// before their results are accessed or that only supported scenarios are evaluated.
  private func unreachable() -> Never {
    return fatalError("Unreachable")
  }
  
  /// Append the result for an expression to the array
  private func append(_ result: Result, for expression: Expression) {
    expressionResults.append(ExpressionResult(expression: expression, result: result))
  }
  
  /// Lookup a result for a property (i.e. a variable)
  private func lookupResult(for property: String) -> Result {
    precondition(!expressionResults.isEmpty)
    
    let potentialResults = expressionResults.filter { $0.expression is AssignmentExpression || $0.expression is VariableDeclaration }
    
    precondition(!potentialResults.isEmpty)
    
    if potentialResults.count == 1 {
      return potentialResults.first!.result
    }
    
    guard let result = potentialResults.first(where: { ($0.expression as? AssignmentExpression)?.variable.name == property })?.result else { unreachable() }
    
    return result
  }
  
  /// Lookup the result for an expression
  private func lookupResult<E: Expression>(for expression: E) -> Result {
    precondition(!expressionResults.isEmpty)
    
    guard let result = expressionResults.first(where: { $0.expression is E })?.result else { unreachable() }
    
    return result
  }
  
  private func lookupReturnStatement(in results: [ExpressionResult]) -> Result? {
    precondition(!results.isEmpty)
    
    return results.first(where: { $0.expression is ReturnStatement })?.result
  }
  
  /// Lookup the declaration for a function
  private func lookupDecl(for functionName: String) -> FunctionDeclaration {
    let _decl = ast
      .filter { $0 is FunctionDeclaration }
      .compactMap { $0 as? FunctionDeclaration }
      .first { $0.signature.name == functionName }
    
    guard let decl = _decl else { unreachable() }
    
    return decl
  }
}
