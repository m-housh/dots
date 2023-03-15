import CliMiddleware
import Dependencies
import FileClient
import Foundation
import ShellClient

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
    @Dependency(\.globals.dryRun) var dryRun
    @Dependency(\.logger) var logger
    
    switch self {
    case .install:
      logger.info("Installing scripts.")
      
      if !dryRun {
        // Create a directory at ~/.local if it doesn't exist.
        try await fileClient.createDirectory(
          at: fileClient.homeDirectory().appendingPathComponent(".local")
        )
      }
      try await fileClient.install(
        source: \.scriptsDirectory,
        destination: \.scriptsDestination,
        dryRun: dryRun
      )
    case .uninstall:
      try await fileClient.uninstall(destination: \.scriptsDestination, dryRun: dryRun)
    }
  }
}

fileprivate extension FileClient {
  var dotLocal: URL {
    homeDirectory()
      .appendingPathComponent(".local")
  }
  
  var scriptsDirectory: URL {
    dotfilesDirectory()
      .appendingPathComponent("scripts")
      .appendingPathComponent("scripts")
  }
  
  var scriptsDestination: URL {
    dotLocal
      .appendingPathComponent("scripts")
  }
}
