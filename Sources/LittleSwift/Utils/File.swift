//
//  FileLoader.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 16/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// A struct that is responsible for loading and saving files
struct File {
  
  // TODO: Use a struct instead of a tuple
  
  /// Load a file from the specified path and return its contents, along
  /// with the name of the file
  static func load(_ path: String) -> (String, String)? {
    guard exists(path) == true, let contents = try? String(contentsOfFile: path) else {
      return nil
    }
    return (contents, URL(string: path)!.deletingPathExtension().lastPathComponent)
  }
  
  /// Write the given string to the specified file in the current directory
  static func write(fileName: String, contents: String) {
    let path = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let savePath = path.appendingPathComponent(fileName)
    do {
      try contents.write(to: savePath, atomically: true, encoding: .utf8)
    } catch let err {
      print("There was an error when writing to the file at location: \(path.absoluteString)/\(fileName). The full error is: \(err.localizedDescription)")
    }
  }
  
  /// Check if a file exists at the given path
  private static func exists(_ path: String) -> Bool {
    return FileManager().fileExists(atPath: path)
  }
}
