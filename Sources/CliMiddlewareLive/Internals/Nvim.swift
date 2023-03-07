import CliMiddleware
import Dependencies
import FileClient
import Foundation
import LoggingDependency
import ShellClient

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
    @Dependency(\.shellClient) var shellClient
    
    switch self {
    case .install:
      logger.info("Installing neovim configuration.")
      try await fileClient.install(
        source: \.nvimSource,
        destination: \.nvimDestination,
        dryRun: dryRun
      )
      if !dryRun {
        logger.info("You will need to open iterm prefrences and load the profile.")
      }
    case .uninstall:
      logger.info("Uninstalling neovim configuration.")
      try await fileClient.uninstall(destination: \.nvimDestination, dryRun: dryRun)
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
