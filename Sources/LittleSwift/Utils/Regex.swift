//
//  Regex.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 16/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

infix operator ~=

/// An overloaded function to apply a given regular expression
/// on a given string
func ~= (_ string: String, _ regex: String) -> Bool {
  return string.match(regex) != ""
}
