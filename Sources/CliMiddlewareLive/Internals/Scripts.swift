import CliMiddleware
import Dependencies
import FileClient
import Foundation
import LoggingDependency

extension CliMiddleware.ScriptsContext {
  
  func run() async throws {
    switch self {
    case let .config(config):
      try await config.handleScripts()
    }
  }
  
}

fileprivate extension CliMiddleware.InstallationContext {
  
  func handleScripts() async throws {
    @Dependency(\.fileClient) var fileClient
    @Dependency(\.globals) var globals
    @Dependency(\.logger) var logger
    
    let destination = fileClient.scriptsDestination
    
    switch self {
      
    case .install:
      let source = fileClient.scriptsDirectory
      var prefix = "Linked"
      
      if !globals.dryRun {
        logger.info("Linking scripts.")
        logger.debug("Linking scripts: \(source.absoluteString) -> \(destination.absoluteString)")
        try await fileClient.createDirectory(
          at: fileClient.homeDirectory().appendingPathComponent(".local")
        )
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
      if !globals.dryRun {
        logger.info("Removing scripts symlink.")
        try await fileClient.moveToTrash(destination)
      } else {
        prefix = "Would have moved"
      }
      logger.info("\(prefix): \(destination.absoluteString) to the trash.")
    }
  }
}

fileprivate extension FileClient {
  var dotLocal: URL {
    homeDirectory()
      .appendingPathComponent(".local")
  }
  
  var scriptsDirectory: URL {
    configDirectory()
      .appendingPathComponent("scripts")
      .appendingPathComponent("scripts")
  }
  
  var scriptsDestination: URL {
    dotLocal
      .appendingPathComponent("scripts")
  }
}
