//
//  Expression.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 20/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

/// A protocol that describes an expression.
///
/// An expression can be really simple (`let phi: Float = 1.618`) or
/// be really complex (contain many smaller expressions, such
/// as if statements, function calls, etc). An expression is
/// the most basic entity of the AST and everything else (such
/// as declarations, statements, types, etc) extend an expression.
public protocol Expression { }
