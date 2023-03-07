import CliMiddleware
import Dependencies
import FileClient
import Foundation
import LoggingDependency

extension CliMiddleware.ItermContext {
  func run() async throws {
    switch self {
    case let .config(config):
      try await config.handleIterm()
    }
  }
}

fileprivate extension CliMiddleware.InstallationContext {
  
  func handleIterm() async throws {
    @Dependency(\.fileClient) var fileClient
    @Dependency(\.globals.dryRun) var dryRun
    @Dependency(\.logger) var logger
    
    switch self {
    case .install:
      logger.info("Installing iterm2 configuration.")
      // Create the iterm2 directory, as it sometimes exists and sometimes does not
      // depending on if iterm2 has been opened / customized.
      try await fileClient.ensureItermConfigDirectory()
      try await fileClient.install(
        source: \.itermSource,
        destination: \.itermDestination,
        dryRun: dryRun,
        ensureConfigDirectory: true
      )
      if !dryRun {
        logger.info("You will need to open iterm prefrences and load the profile.")
      }
    case .uninstall:
      try await fileClient.uninstall(destination: \.itermDestination, dryRun: dryRun)
    }
  }
 
}

fileprivate extension FileClient {
  
  var itermSource: URL {
    dotfilesDirectory()
      .appendingPathComponent("macOS")
      .appendingPathComponent(".config")
      .appendingPathComponent("iterm")
      .appendingPathComponent("profile.json")
  }
  
  var itermDestination: URL {
    configDirectory()
      .appendingPathComponent("iterm2")
      .appendingPathComponent("profile.json")
  }
  
  func ensureItermConfigDirectory() async throws {
    try await ensureConfigDirectory()
    try await createDirectory(
      at: configDirectory().appendingPathComponent("iterm2")
    )
  }
}
