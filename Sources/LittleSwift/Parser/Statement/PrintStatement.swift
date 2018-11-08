//
//  PrintStatement.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 20/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// A struct that describes a print statement
///
/// Example: `print(3.14)` or `print("Hello, world!")
public struct PrintStatement: Statement {
  let arguments: [Expression]
}
