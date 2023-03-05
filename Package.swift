// swift-tools-version: 5.7


import PackageDescription

let package = Package(
  name: "dots",
  platforms: [
    .macOS(.v12)
  ],
  products: [
    .executable(name: "dots", targets: ["dots"]),
    .library(name: "CliMiddleware", targets: ["CliMiddleware"]),
    .library(name: "CliMiddlewareLive", targets: ["CliMiddlewareLive"]),
    .library(name: "FileClient", targets: ["FileClient"]),
    .library(name: "LoggingDependency", targets: ["LoggingDependency"]),
    .library(name: "ShellClient", targets: ["ShellClient"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "0.1.4"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    .package(url: "https://github.com/adorkable/swift-log-format-and-pipe.git", from: "0.1.0"),
  ],
  targets: [
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
        "LoggingDependency",
        "ShellClient"
      ]
    ),
    .target(
      name: "FileClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
    .target(
      name: "LoggingDependency",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "LoggingFormatAndPipe", package: "swift-log-format-and-pipe"),
      ]
    ),
    .executableTarget(
      name: "dots",
      dependencies: [
        "CliMiddlewareLive",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
    .testTarget(
      name: "dotsTests",
      dependencies: ["dots"]
    ),
    .target(
      name: "ShellClient",
      dependencies: [
        "LoggingDependency",
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    ),
  ]
)
