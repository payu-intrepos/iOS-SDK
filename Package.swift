// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PayUIndia-PG-SDK",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PayUIndia-PG-SDK",
            targets: ["PayUIndia-PG-SDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "PayUIndia-PayUParam",url: "https://github.com/payu-intrepos/payu-params-iOS", from: "3.0.0"),
        .package(name: "PayUIndia-CrashReporter",url: "https://github.com/payu-intrepos/PayUCrashReporter-iOS", from: "2.0.0")
    ],
    targets: [
            .binaryTarget(name: "PayUIndia-PG-SDK", path: "./PayUBizCoreKit.xcframework")
        ]
)
