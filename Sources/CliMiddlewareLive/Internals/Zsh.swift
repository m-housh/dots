import CliMiddleware
import Dependencies
import FileClient
import Foundation
import LoggingDependency

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension CliMiddleware.ZshContext {
  
  func run() async throws {
    try await Zsh(context: self).run()
  }
}

fileprivate struct Zsh {
  @Dependency(\.globals.dryRun) var dryRun
  @Dependency(\.fileClient) var fileClient
  @Dependency(\.logger) var logger
  
  let context: CliMiddleware.ZshContext
  
  func install() async throws {
    logger.info("Installing zsh configuration.")
    try await fileClient.install(
      source: \.zshDirectory,
      destination: \.zshConfigDestination,
      dryRun: dryRun
    )
    try await fileClient.install(
      source: \.zshEnvSource,
      destination: \.zshEnvDestination,
      dryRun: dryRun,
      ensureConfigDirectory: false
    )
    if !dryRun {
      logger.info("You will need to reload your shell environment for changes to take effect.")
    }
  }
  
  func uninstall() async throws {
    logger.info("Uninstalling zsh configuration.")
    try await fileClient.uninstall(destination: \.zshEnvDestination, dryRun: dryRun)
    try await fileClient.uninstall(destination: \.zshConfigDestination, dryRun: dryRun)
    if !dryRun {
      logger.info("Done uninstalling zsh configuration, you will need to reload your shell.")
    }
  }
  
  func run() async throws {
    switch context.context {
    case .install:
      try await self.install()
    case .uninstall:
      try await self.uninstall()
    }
  }
  
  func linkZshConfig() async throws {
    try await fileClient.createDirectory(at: fileClient.configDirectory())
    try await fileClient.createSymlink(
      source: fileClient.zshDirectory,
      destination: fileClient.zshConfigDestination
    )
  }
}

fileprivate extension FileClient {
  var zshDirectory: URL {
    dotfilesDirectory()
      .appendingPathComponent("zsh")
      .appendingPathComponent("config")
  }
  
  var zshConfigDestination: URL {
    configDirectory().appendingPathComponent("zsh")
  }
  
  var zshEnvDestination: URL {
    homeDirectory().appendingPathComponent(".zshenv")
  }
  
  var zshEnvSource: URL {
    zshDirectory.appendingPathComponent(".zshenv")
  }
}
