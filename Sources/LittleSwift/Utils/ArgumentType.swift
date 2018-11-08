//
//  ArgumentType.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 16/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

// TODO: Stop handling this on our own and use a third-party framework?

/// An enum that describes the different kinds of arguments that our program
/// supports
enum ArgumentType: String {
  case sourceFilePath = "--source-file-path"
  case sourceFilePathCompact = "-s"
  case dumpTokens = "--dump-tokens"
  case dumpTokensCompact = "-dt"
  case dumpAst = "--dump-ast"
  case dumpAstCompact = "-da"
  case dumpIr = "--dump-ir"
  case dumpIrCompact = "-di"
  case convertLang = "--convert"
  case convertLangCompact = "-c"
  case jitIR = "--jit"
  case jitIRCompact = "-j"
  case performIRVerification = "--perform-verification"
  case performIRVerificationCompact = "-v"
}

/// An enum that describes the output code that the program can generate/emit
enum ConversionTargets: String {
  case llvm = "llvm"
  case kotlin = "kotlin"
}
