# LittleSwift

## A simple self-hosted Swift compiler

LittleSwift is a simple compiler written in Swift that can compile Swift code. It's simply a project I've been working on to gain further understanding about compilers and it's not meant to replace the real Swift compiler any time soon.

**Note:** It's a basic compiler at the moment and it's not meant for production use!

### What can it do?

- Tokenize, Parse, Sema, IRGen, Emit (Kotlin)
- Supports a strict subset of Swift grammar
    - Functions and variables
    - Primitive types (`String`, `Int`, `Float`, `Void`, `Bool`)
    - Binary operators (`+`, `-`, `*`, `/`)
    - `print` (only integers at the moment)
- Just-in-time (JIT) compilation

### What it can't do?

- Output a binary (only does JIT at the moment)
- Type inference
- Support classes, protocols, generics, etc
- Support other types like `Array` and `List`
- Module maps
- Optimizations
- Many more things...

## Installation

1. Install LLVM 6 (`brew install llvm@6`)
2. Install the LLVM pkg-config file (`swift utils/make-pkgconfig.swift`)
3. Run `swift package resolve` and then `swift package generate-xcodeproj`.

## Usage

Refer to the command-line parameters. You can simply invoke the compiler without any arguments and it will print all the parameters it supports.