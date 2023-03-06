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
      
      let destination = fileClient.espansoDestination
      
      switch config {
      case .install:
        var prefix = "Linked"
        let source = fileClient.espansoSource
        if !dryRun {
          logger.info("Installing espanso configuration.")
          try await fileClient.ensureConfigDirectory()
          try await fileClient.createSymlink(
            source: source,
            destination: destination
          )
        } else {
          prefix = "Would have linked"
        }
        logger.info("\(prefix): \(source.absoluteString) -> \(destination.absoluteString)")
        
      case .uninstall:
        var prefix = "Moved"
        if !dryRun {
          logger.info("Removing espanso configuration.")
          try await fileClient.moveToTrash(destination)
        } else {
          prefix = "Would have moved"
        }
        logger.info("\(prefix): \(destination.absoluteString)")
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
