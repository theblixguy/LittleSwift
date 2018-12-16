# LittleSwift

## A simple self-hosted Swift compiler

LittleSwift is a simple compiler written in Swift that can compile Swift code. It's simply a project I've been working on to gain further understanding about compilers and it's not meant to replace the real Swift compiler any time soon.

**Note:** It's a basic compiler at the moment and it's not meant for production use!

## Features

### What can it do?

- Tokenize, Parse, Sema, IRGen, Output Binary
- Supports a strict subset of Swift grammar
    - Functions and variables
    - Primitive types (`String`, `Int`, `Float`, `Void`, `Bool`)
    - Binary operators (`+`, `-`, `*`, `/`)
    - `print`
- Just-in-time (JIT) compilation
- Interpreter (REPL)
- Emit Kotlin code
- Basic type inference

### What it can't do?

- Support classes, protocols, generics, etc
- Support other types like `Array` and `List`
- Module maps
- Optimizations
- Many more things...

## Example

```swift
func main() {
    print("Hello! This program prints the square root of 5.")
    
    let numberToSquare = 5
    let answer = square(numberToSquare)
    
    print("The square root of 5 is: ")
    print(answer)
}

func square(number: Int) -> Int {
    return multiply(number, number)
}

func multiply(first: Int, second: Int) -> Int {
    return first * second
}

// Output:
//
// Hello! This program prints the square root of 5.
// The square root of 5 is:
// 25
```

## Installation

1. Install LLVM 6 (`brew install llvm@6`)
2. Install the LLVM pkg-config file (`swift utils/make-pkgconfig.swift`)
3. Run `swift package resolve` and then `swift package generate-xcodeproj`.

## Usage

Refer to the command-line parameters. You can simply invoke the compiler without any arguments and it will print all the parameters it supports.

## License

LittleSwift

Copyright (C) 2018 Suyash Srijan

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
