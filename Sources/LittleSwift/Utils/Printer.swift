//
//  Printer.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 16/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// A struct that is responsible for printing text to the screen, including
/// some program-specific text, such as help information
struct Printer {
  
  static func printToScreen(_ something: Any) {
    print(something)
  }
  
  static func printHelp() {
    printNewLine()
    printToScreen("usage: lswiftc [options]")
    printNewLine()
    printToScreen("Options:")
    printToScreen("\t-s, --source-file-path\t\t\t\t\tpath to file which needs to be compiled (*.swift)")
    printToScreen("\t-c, --convert\t\t\t\t\tconvert swift code to a different target representation")
    printToScreen("\t-v, --dump-ir\t\t\t\t\tperform LLVM IR Verification")
    printToScreen("\t-j, --jit\t\t\t\t\tcompile JIT instead of outputting binary")
    printToScreen("\t-dt, --dump-tokens\t\t\t\t\tdump tokens generated by Lexer")
    printToScreen("\t-da, --dump-ast\t\t\t\t\tdump AST generated by Parser")
    printToScreen("\t-da, --dump-ir\t\t\t\t\tdump LLVM IR generated by IRGen")
    printToScreen("\t-i, --repl\t\t\t\t\tevaluate the program using REPL")
    printNewLine()
  }
  
  /// Print the app's header
  static func printAppHeader() {
    
    var version: String {
      if let _version = Bundle.main.releaseVersionNumber {
        return _version
      }
      return "1.0.0" // Default
    }
    
    var build: String {
      if let _build = Bundle.main.buildVersionNumber {
        return _build
      }
      return "1" // Default
    }
    
    let compileDate = CompileTime.date.fullDate
    
    printAsterisksLine()
    printToScreen("LittleSwift v\(version) Build \(build)")
    printToScreen("Compiled on \(compileDate)")
    printToScreen("Written by Suyash Srijan")
    printAsterisksLine()
  }
  
  /// Print an invalid argument message
  static func printInvalidArgumentMessage(receivedArguments: [String]) {
    printToScreen("Invalid argument received: ")
    printToScreen(receivedArguments)
    printNewLine()
  }
  
  /// Print an invalid path message
  static func printInvalidFilePathMessage() {
    printToScreen("Invalid file path received!")
    printNewLine()
  }
  
  /// Dump the tokens to the screen
  static func printTokens(_ tokens: [Token]) {
    printAsterisksLine()
    printToScreen("> TOKEN DUMP")
    printAsterisksLine()
    dump(tokens)
  }
  
  /// Dump the AST to the screen
  static func printAst(_ expressions: [Expression]) {
    printAsterisksLine()
    printToScreen("> AST DUMP")
    printAsterisksLine()
    dump(expressions)
  }
  
  /// Dump the LLVM IR to the screen
  static func printIR(_ ir: String) {
    printAsterisksLine()
    printToScreen("> LLVM IR DUMP")
    printAsterisksLine()
    print(ir)
  }
  
  /// Print a new line
  static func printNewLine() {
    printToScreen("\n")
  }
  
  /// Print a specified number of new lines
  static func printNewLines(count: Int) {
    guard count > 0 && count <= 10 else { return }
    
    for _ in 0..<count {
      printNewLine()
    }
  }
  
  /// Wait for input & exit the program
  static func waitForInputToExit() {
    printToScreen("Press any key to exit...")
    let _ = readLine()
  }
  
  /// Print a stream of asterisks (to create a separator)
  private static func printAsterisksLine() {
    printToScreen("*************************************************************")
  }
}
