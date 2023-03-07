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
    
    switch self {
    case .install:
      logger.info("Installing tmux configuration.")
      try await fileClient.install(
        source: \.tmuxSource,
        destination: \.tmuxDestination,
        dryRun: dryRun,
        ensureConfigDirectory: false
      )
    case .uninstall:
      logger.info("Uninstalling tmux configuration.")
      try await fileClient.uninstall(destination: \.tmuxDestination, dryRun: dryRun)
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
