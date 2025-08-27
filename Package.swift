// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mParticle-Google-Analytics-Firebase",
    platforms: [ .iOS(.v15), .tvOS(.v15) ],
    products: [
        .library(
            name: "mParticle-Google-Analytics-Firebase",
            targets: ["mParticle-Google-Analytics-Firebase"]),
    ],
    dependencies: [
      .package(url: "https://github.com/mParticle/mparticle-apple-sdk",
               .upToNextMajor(from: "8.22.0")),
      .package(url: "https://github.com/firebase/firebase-ios-sdk.git",
               .upToNextMajor(from: "12.0.0")),
    ],
    targets: [
        .target(
            name: "mParticle-Google-Analytics-Firebase",
            dependencies: [
              .product(name: "mParticle-Apple-SDK", package: "mparticle-apple-sdk"),
              .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
            ],
            path: "mParticle-Google-Analytics-Firebase",
            exclude: ["Info.plist", "dummy.swift"],
            resources: [.process("PrivacyInfo.xcprivacy")],
            publicHeadersPath: "."),
    ]
)
