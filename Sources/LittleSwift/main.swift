//
//  main.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 16/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation
import LLVM

let argumentCount = CommandLine.argc
let arguments = CommandLine.arguments

Printer.printAppHeader()

if argumentCount <= 1 || argumentCount > 12 {
  Printer.printHelp()
} else {
  
  let firstArgumentKey = arguments[1]
  let firstArgumentValue = arguments[2]
  
  let dumpTokens: Bool = arguments.contains(ArgumentType.dumpTokens.rawValue) || arguments.contains(ArgumentType.dumpTokensCompact.rawValue)
  let dumpAst: Bool = arguments.contains(ArgumentType.dumpAst.rawValue) || arguments.contains(ArgumentType.dumpAstCompact.rawValue)
  let dumpIr: Bool = arguments.contains(ArgumentType.dumpIr.rawValue) || arguments.contains(ArgumentType.dumpIrCompact.rawValue)
  let jit: Bool = arguments.contains(ArgumentType.jitIR.rawValue) || arguments.contains(ArgumentType.jitIRCompact.rawValue)
  let irVerification: Bool = arguments.contains(ArgumentType.performIRVerification.rawValue) || arguments.contains(ArgumentType.performIRVerificationCompact.rawValue)
  let convertLangFlag: Bool = arguments.contains(ArgumentType.convertLang.rawValue) || arguments.contains(ArgumentType.convertLangCompact.rawValue)
  let convertLang: ConversionTargets = arguments.contains(ConversionTargets.kotlin.rawValue) ? .kotlin : .llvm
  let replFlag: Bool = arguments.contains(ArgumentType.repl.rawValue) || arguments.contains(ArgumentType.repltCompact.rawValue)
  let dumpReplFlag: Bool = arguments.contains(ArgumentType.dumpRepl.rawValue) || arguments.contains(ArgumentType.dumpReplCompact.rawValue)
  
  guard let firstArgumentType = ArgumentType(rawValue: firstArgumentKey), (firstArgumentType != .sourceFilePath || firstArgumentType != .sourceFilePathCompact) else {
    Printer.printInvalidArgumentMessage(receivedArguments: Array(arguments.dropFirst()))
    Printer.printHelp()
    fatalError()
  }
  
  if let (contents, fileName) = File.load(firstArgumentValue) {
    
    if (!firstArgumentValue.hasSuffix(".swift")) {
      Printer.printToScreen("> Invalid source file, must end with .swift!")
      Printer.waitForInputToExit()
    }
    
    Printer.printToScreen("> Loaded source file: \(firstArgumentValue)")
    Printer.printToScreen("> Tokenizing...")
    
    // Generate Tokens
    
    let lexer = Lexer(with: contents)
    let tokens = lexer.tokenize()
    
    if tokens.isEmpty {
      Printer.printToScreen("Unable to generate tokens!")
      Printer.waitForInputToExit()
    }
    
    if dumpTokens {
      Printer.printTokens(tokens)
    }
    
    // Build AST
    
    Printer.printToScreen("> Parsing...")
    
    let parser = Parser(tokens: tokens)
    let ast = try parser.parseTokens()
    
    if ast.isEmpty {
      Printer.printToScreen("Unable to perform parsing!")
      Printer.waitForInputToExit()
    }
    
    if dumpAst {
      Printer.printAst(ast)
    }
    
    Printer.printToScreen("> Semantic Analysis...")
    
    // Perform Semantic analysis
    
    let sema = Sema(with: ast)
    
    do {
      try sema.performSema()
    } catch let error {
      print("> Sema error: \(error)")
      fatalError()
    }
    
    // Run the interpreter
    
    if replFlag {
      Printer.printToScreen("> Running REPL...")
      
      let interpreter = Interpreter(with: ast, shouldDumpResults: dumpReplFlag)
      interpreter.run()
    }
    
    switch convertLang {
    case .kotlin:
      Printer.printToScreen("> Generating Kotlin code...")
      let emitter = KotlinEmitterProvider(with: ast)
      File.write(fileName: "\(fileName).kt", contents: emitter.emit().value)
      Printer.printToScreen("Saved to file \(fileName).kt!")
    case .llvm:
      
      // Pass to LLVM
      Printer.printToScreen("> Generating LLVM IR...")
      
      let emitter = IRGen(with: ast)
      emitter.emit()
      
      if dumpIr {
        Printer.printIR(emitter.getModule().description)
      }
      
      if irVerification {
        Printer.printToScreen("> Performing IR verification...")
        try emitter.getModule().verify()
      }
      
      if jit {
        Printer.printToScreen("> Performing JIT compilation...")
        
        if let mainFunction = emitter.getModule().function(named: "main") {
          let jit = try! JIT(module: emitter.getModule(), machine: TargetMachine())
          
          Printer.printToScreen("> JIT output:")
          let _ = jit.runFunctionAsMain(mainFunction, args: [])
        }
      } else {
        Printer.printToScreen("> Creating output program...")
        let binary = Binary(with: emitter.getModule(), sourceFileName: fileName)
        
        binary.generate() { success in
          if success {
            Printer.printToScreen("> Binary succesfully generated!")
          } else {
            Printer.printToScreen("> There was an error while generating a binary!")
          }
        }
      }
    }
    
    // Finished
    
    Printer.printToScreen("> Finished!")
  } else {
    Printer.printInvalidFilePathMessage()
  }
  
  Printer.waitForInputToExit()
}
