//
//  Emitter.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 17/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// A protocol that describes an entity which takes an AST
/// as input and emits code in some other language.
public protocol Emitter {}

/// A protocol that describes a container which stores the
/// emitted code.
public protocol Emitted {}

/// A protocol that describes an AST node which can be emitted
/// in some other language.
public protocol Emittable {}
