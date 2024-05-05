// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swift_Metal_Project",
    products: [
        .executable(name: "Swift_Metal_Project", targets: ["Swift_Metal_Project"])
        // Add other products if needed
    ],
    targets: [
        // .executableTarget(
        //     name: "Swift_Metal_Project",
        //     dependencies: ["ShaderResources"],
        //     path: "Sources/Swift_Metal_Project"
        // ),
        // .target(
        //     name: "ShaderResources",
        //     resources: [
        //         .copy("Shaders")
        //     ]
        // ),
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "Swift_Metal_Project",
            resources: [
                .copy("Shaders")
            ]
        ),
    ]
)
