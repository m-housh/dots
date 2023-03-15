import CliMiddleware
import Dependencies
import FileClient
import Foundation
import ShellClient

extension CliMiddleware.VimContext {
  
  func run() async throws {
    switch self {
    case let .config(config):
      try await config.handleVim()
    }
  }
}

fileprivate extension CliMiddleware.InstallationContext {
  func handleVim() async throws {
    @Dependency(\.fileClient) var fileClient
    @Dependency(\.globals.dryRun) var dryRun
    @Dependency(\.logger) var logger
    
    switch self {
    case .install:
      logger.info("Installing vim configuration.")
      if !dryRun {
        try await fileClient.createDirectory(at: fileClient.vimDirectory)
      }
      try await fileClient.install(
        source: \.vimrcSource,
        destination: \.vimrcDestination,
        dryRun: dryRun,
        ensureConfigDirectory: false
      )
      if !dryRun {
        logger.info("You will need to start vim for plugins to load.")
      }
    case .uninstall:
      logger.info("Uninstalling vim configuration.")
      try await fileClient.uninstall(destination: \.vimrcDestination, dryRun: dryRun)
    }
  }
}

fileprivate extension FileClient {
  var vimDirectory: URL {
    homeDirectory()
      .appendingPathComponent(".vim")
  }
  
  var vimrcSource: URL {
    dotfilesDirectory()
      .appendingPathComponent("vim")
      .appendingPathComponent("vimrc")
  }
  
  var vimrcDestination: URL {
    vimDirectory
      .appendingPathComponent("vimrc")
  }
}
