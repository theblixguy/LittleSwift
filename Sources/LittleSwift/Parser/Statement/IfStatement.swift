//
//  IfStatement.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 20/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// A struct that defines an if statement
///
/// Example: `if (conditional) { // body }`
public struct IfStatement: Statement {
  let conditional: Expression
  let body: [Expression]
}
