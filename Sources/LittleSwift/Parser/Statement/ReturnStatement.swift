//
//  ReturnStatement.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 20/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// A struct that defines a return statement
///
/// Example: `return 1 + 2`
public struct ReturnStatement: Statement {
  let value: Expression
}
