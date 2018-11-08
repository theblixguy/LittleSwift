//
//  PropertyAccessExpression.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 20/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// A struct that defines a property access expression.
///
/// If you define a property and then pass that property
/// to a function or assign it to another property, then
/// that counts as property access.
///
/// Example: `let newProperty: String = previouslyDeclaredProperty`
///
/// where `previouslyDeclaredProperty` is a property that has
/// been previously declared in the code (locally or globally).
public struct PropertyAccessExpression: Expression {
  let name: String
}
