//
//  Binary.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 16/12/2018.
//

import Foundation
import LLVM

/// A class responsible for generating an executable
final class Binary {
  
  /// The LLVM IR module to generate the executable for
  private let module: Module
  
  /// The name of the source (Swift) file
  private let sourceFileName: String
  
  /// Init
  init(with module: Module, sourceFileName: String) {
    self.module = module
    self.sourceFileName = sourceFileName
  }
  
  /// Create an executable and save it to file
  func generate(_ completionHandler: @escaping (Bool) -> ()) {
    File.write(fileName: "\(sourceFileName).ll", contents: rawIR())
    invokeStaticCompiler(completionHandler)
  }
  
  /// Get the raw IR code
  private func rawIR() -> String {
    return module.description
  }
  
  // FIXME: Don't use a hardcoded path
  /// Invoke the LLVM Static Compiler to create an object file from the raw IR
  private func invokeStaticCompiler(_ completionHandler: @escaping (Bool) -> ()) {
    let task = Process()
    
    task.launchPath = "/usr/local/opt/llvm@6/bin/llc"
    task.currentDirectoryPath = FileManager().currentDirectoryPath
    task.arguments = ["-filetype=obj", "\(sourceFileName).ll", "-o", "\(sourceFileName).o"]
    task.launch()
    task.waitUntilExit()
    
    if task.terminationStatus == 0 {
      invokeGcc(completionHandler)
    } else {
      Printer.printToScreen("An error occured when running the LLVM Static Compiler (llc).")
      completionHandler(false)
    }
  }
  
  // FIXME: Don't use a hardcoded path
  /// Invoke GCC to generate a binary from the object file
  private func invokeGcc(_ completionHandler: @escaping (Bool) -> ()) {
    let task = Process()
    
    task.launchPath = "/usr/bin/gcc"
    task.currentDirectoryPath = FileManager().currentDirectoryPath
    task.arguments = ["\(sourceFileName).o", "-o", "\(sourceFileName)"]
    task.launch()
    task.waitUntilExit()
    
    if task.terminationStatus == 0 {
      completionHandler(true)
    } else {
      Printer.printToScreen("An error occured when running the GNU Compiler Collection (gcc).")
      completionHandler(false)
    }
  }
}
