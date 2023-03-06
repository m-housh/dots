import CliMiddleware
import Dependencies
import FileClient
import Foundation
import LoggingDependency

extension CliMiddleware.NeoVimContext {
  func run() async throws {
    switch self {
    case let .config(config):
      try await config.handleNvim()
    }
  }
}

fileprivate extension CliMiddleware.InstallationContext {
  
  func handleNvim() async throws {
    @Dependency(\.fileClient) var fileClient
    @Dependency(\.globals.dryRun) var dryRun
    @Dependency(\.logger) var logger
    
    let destination = fileClient.nvimDestination
    
    switch self {
    case .install:
      var prefix = "Linked"
      let source = fileClient.nvimDestination
      if !dryRun {
        logger.info("Linking iterm configuration.")
        try await fileClient.ensureConfigDirectory()
        try await fileClient.createSymlink(
          source: source,
          destination: destination
        )
      } else {
        prefix = "Would have linked"
        logger.info("Dry run called")
      }
      logger.info("\(prefix): \(source.absoluteString) -> \(destination.absoluteString)")
      logger.info("You will need to open iterm prefrences and load the profile.")
    case .uninstall:
      var prefix: String = "Moved"
      if !dryRun {
        logger.info("Removing iterm configuration symlink.")
        try await fileClient.moveToTrash(destination)
      } else {
        prefix = "Would have moved"
      }
      logger.info("\(prefix): \(destination.absoluteString) to the trash.")
    }
  }
 
}

fileprivate extension FileClient {
  
  var nvimSource: URL {
    dotfilesDirectory()
      .appendingPathComponent("nvim")
  }
  
  var nvimDestination: URL {
    configDirectory()
      .appendingPathComponent("nvim")
  }
}
