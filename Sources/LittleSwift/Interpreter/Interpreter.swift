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
    case let assignment as AssignmentExpression:
      return evaluateAssignmentExpression(assignment)
    case let `operator` as BinaryOperatorExpression:
      return evaluateOperatorExpr(`operator`)
    case let printStmt as PrintStatement:
      return evaluatePrintStatement(printStmt)
    case let propAccess as PropertyAccessExpression:
      return evaluatePropertyAccessExpr(propAccess)
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
    print(result.rawAsString())
    
    return Result.void()
  }
  
  /// Evaluates a property access expression and returns the result
  private func evaluatePropertyAccessExpr(_ expr: PropertyAccessExpression) -> Result {
    
    // By this time, the expression would've already been evaluated, so lookup
    // the result and return it
    return lookupResult(for: expr.name)
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
    
    guard let result = potentialResults.first?.result else { unreachable() }
    
    return result
  }
  
  /// Lookup the result for an expression
  private func lookupResult<E: Expression>(for expression: E) -> Result {
    precondition(!expressionResults.isEmpty)
    
    guard let result = expressionResults.first(where: { $0.expression is E })?.result else { unreachable() }
    
    return result
  }
}
