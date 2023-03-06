import CliMiddleware
import Dependencies
import FileClient
import Foundation
import LoggingDependency

extension CliMiddleware.TmuxContext {
  func run() async throws {
    switch self {
    case let .config(config):
      try await config.handleTmux()
    }
  }
}

fileprivate extension CliMiddleware.InstallationContext {
  
  func handleTmux() async throws {
    @Dependency(\.fileClient) var fileClient
    @Dependency(\.globals.dryRun) var dryRun
    @Dependency(\.logger) var logger
    
    let destination = fileClient.tmuxDestination
    
    switch self {
    case .install:
      var prefix = "Linked"
      let source = fileClient.tmuxSource
      if !dryRun {
        logger.info("Linking iterm configuration.")
        try await fileClient.createSymlink(
          source: source,
          destination: destination
        )
      } else {
        prefix = "Would have linked"
        logger.info("Dry run called")
      }
      logger.info("\(prefix): \(source.absoluteString) -> \(destination.absoluteString)")
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
  
  var tmuxSource: URL {
    dotfilesDirectory()
      .appendingPathComponent("tmux")
      .appendingPathComponent(".tmux.conf")
  }
  
  var tmuxDestination: URL {
    homeDirectory()
      .appendingPathComponent(".tmux.conf")
  }
}
