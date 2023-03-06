import CliMiddleware
import Dependencies
import FileClient
import Foundation
import LoggingDependency

extension CliMiddleware.GitContext {
  func run() async throws {
    switch self {
    case let .config(config):
      try await config.handleGit()
    }
  }
}

fileprivate extension CliMiddleware.InstallationContext {
  
  func handleGit() async throws {
    @Dependency(\.fileClient) var fileClient
    @Dependency(\.globals) var globals
    @Dependency(\.logger) var logger
    
    let dotConfig = fileClient.gitConfigDirectory
    let destination = fileClient.gitConfigDestination
    switch self {
      
    case .install:
      if !globals.dryRun {
        logger.info("Linking git configuration.")
        logger.debug("Linking source: \(dotConfig.absoluteString) -> \(destination.absoluteString)")
        try await fileClient.createSymlink(
          source: dotConfig,
          destination: destination
        )
        logger.info("Done linking configuration to: \(destination.absoluteString)")
      } else {
        logger.info("Dry run called")
        logger.info("Would link source: \(dotConfig.absoluteString) -> \(destination.absoluteString)")
      }
    case .uninstall:
      var prefix: String = "Moved"
      if !globals.dryRun {
        logger.info("Removing git configuration symlink.")
        try await fileClient.moveToTrash(destination)
      } else {
        prefix = "Would have moved"
      }
      logger.info("\(prefix): \(destination.absoluteString) to the trash.")
    }
  }
 
}

fileprivate extension FileClient {
  
  var gitConfigDirectory: URL {
    dotfilesDirectory()
      .appendingPathComponent("git")
      .appendingPathComponent("git")
  }
  
  var gitConfigDestination: URL {
    configDirectory()
      .appendingPathComponent("git")
  }
}
