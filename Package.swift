// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "dots",
  platforms: [
    .macOS(.v12)
  ],
  products: [
    .executable(name: "builder", targets: ["builder"]),
    .executable(name: "dots", targets: ["dots"]),
    .library(name: "CliMiddleware", targets: ["CliMiddleware"]),
    .library(name: "CliMiddlewareLive", targets: ["CliMiddlewareLive"]),
    .library(name: "FileClient", targets: ["FileClient"]),
  ],
  dependencies: [
    .package(url: "https://github.com/m-housh/swift-cli-version.git", from: "0.1.0"),
    .package(url: "https://github.com/m-housh/swift-shell-client.git", from: "0.1.3"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "0.1.4"),
  ],
  targets: [
    .executableTarget(
      name: "builder",
      dependencies: [
        "FileClient",
        .product(name: "ShellClient", package: "swift-shell-client"),
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ],
      plugins: [
        .plugin(name: "BuildWithVersionPlugin", package: "swift-cli-version")
      ]
    ),
    .target(
      name: "CliMiddleware",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
    .target(
      name: "CliMiddlewareLive",
      dependencies: [
        "CliMiddleware",
        "FileClient",
        .product(name: "ShellClient", package: "swift-shell-client")
      ]
    ),
    .target(
      name: "FileClient",
      dependencies: [
        .product(name: "ShellClient", package: "swift-shell-client"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
    .executableTarget(
      name: "dots",
      dependencies: [
        "CliMiddlewareLive",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ],
      plugins: [
        .plugin(name: "BuildWithVersionPlugin", package: "swift-cli-version")
      ]
    ),
    .testTarget(
      name: "dotsTests",
      dependencies: ["dots"]
    ),

  ]
)
