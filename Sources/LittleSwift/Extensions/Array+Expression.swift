//
//  Array+Expression.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 15/12/2018.
//

import Foundation

extension Array where Element == Expression {
  func mainFunction() -> FunctionDeclaration? {
    return first { $0 is FunctionDeclaration } as? FunctionDeclaration
  }
}
