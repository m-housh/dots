import CliMiddleware
import Dependencies
import FileClient
import Foundation
import LoggingDependency

extension CliMiddleware.EspansoContext {
  func run() async throws {
    @Dependency(\.fileClient) var fileClient
    @Dependency(\.globals.dryRun) var dryRun
    @Dependency(\.logger) var logger
    
    switch self {
    case let .config(config):
      switch config {
      case .install:
        logger.info("Installing espanso configuration.")
        try await fileClient.install(
          source: \.espansoSource,
          destination: \.espansoDestination,
          dryRun: dryRun
        )
      case .uninstall:
        logger.info("Uninstalling espanso configuration.")
        try await fileClient.uninstall(destination: \.espansoDestination, dryRun: false)
      }
    }
  }
}

fileprivate extension FileClient {
  var espansoSource: URL {
    dotfilesDirectory()
      .appendingPathComponent("espanso")
      .appendingPathComponent("espanso")
  }
  
  var espansoDestination: URL {
    configDirectory()
      .appendingPathComponent("espanso")
  }
}
