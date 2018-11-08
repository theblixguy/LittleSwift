//
//  DeclarationModifier.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 20/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// A namespace to access modifiers for declarations
public struct DeclarationModifier {
  
  /// An enum that describes the mutability of a
  /// declared property
  ///
  /// - mutating: Mutable (can change state)
  /// - nonmutating: Immutable (cannot change state)
  public enum Mutation {
    /// A property that can be mutated
    case mutating
    /// A property that cannot be mutated
    case nonmutating
  }
}
