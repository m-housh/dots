import CliMiddleware
import Dependencies
import FileClient
import Foundation
import LoggingDependency

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
    
    let destination = fileClient.vimrcDestination
    
    switch self {
    case .install:
      var prefix = "Linked"
      let source = fileClient.vimrcSource
      
      if !dryRun {
        logger.info("Installing vim configuration.")
        try await fileClient.createDirectory(at: fileClient.vimDirectory)
        try await fileClient.createSymlink(source: source, destination: destination)
      } else {
        prefix = "Would have linked"
      }
      logger.info("\(prefix): \(source.absoluteString) -> \(destination.absoluteString)")
      logger.info("You will need to start vim for plugins to load.")
    case .uninstall:
      var prefix = "Moved"
      if !dryRun {
        logger.info("Removing vim configuration.")
        try await fileClient.moveToTrash(destination)
      } else {
        prefix = "Would have moved"
      }
      logger.info("\(prefix): \(destination.absoluteString) to the trash.")
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
