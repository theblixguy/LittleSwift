// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LittleSwift",
    products: [
      .executable(name: "lswiftc", targets: ["LittleSwift"]),
      ],
    dependencies: [
        .package(url: "https://github.com/llvm-swift/LLVMSwift.git", from: "0.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "LittleSwift",
            dependencies: ["LLVM"]),
        .testTarget(
            name: "LittleSwiftTests",
            dependencies: ["LittleSwift"]),
    ]
)
