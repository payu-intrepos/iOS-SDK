// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PayUIndia-PG-SDK",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PayUIndia-PG-SDK",
            targets: ["PayUIndia-PG-SDKTarget"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "PayUIndia-PayUParams",url: "https://github.com/payu-intrepos/payu-params-iOS", from: "6.4.0"),
        .package(name: "PayUIndia-CrashReporter",url: "https://github.com/payu-intrepos/PayUCrashReporter-iOS",from: "4.0.1"),
        .package(name: "PayUIndia-NetworkReachability", url: "https://github.com/payu-intrepos/PayUNetworkReachability-iOS", from: "2.1.1")
    ],
    targets: [
        
        .target(
            name: "PayUIndia-PG-SDKTarget",
            dependencies: [
                "PayUBizCoreKit",
                .product(name: "PayUIndia-CrashReporter", package: "PayUIndia-CrashReporter"),
                .product(name: "PayUIndia-PayUParams", package: "PayUIndia-PayUParams"),
                .product(name: "PayUIndia-NetworkReachability", package: "PayUIndia-NetworkReachability")
            ],
            path: "PayUIndia-PG-SDKWrapper"
        ),
        
            .binaryTarget(name: "PayUBizCoreKit", path: "./PayUBizCoreKit.xcframework")
    ]
)
