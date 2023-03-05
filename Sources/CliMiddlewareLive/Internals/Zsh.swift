import CliMiddleware
import Dependencies
import FileClient
import Foundation
import LoggingDependency

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct Zsh {
  @Dependency(\.globals.dryRun) var dryRun
  @Dependency(\.fileClient) var fileClient
  @Dependency(\.logger) var logger
  
  let context: CliMiddleware.ZshContext
  
  func install() async throws {
    let configString = fileClient.zshConfigDestination.absoluteString
      .replacingOccurrences(of: "file://", with: "")
    
    let destination = fileClient.zshEnvDestination
    
    let destinationString = destination.absoluteString
      .replacingOccurrences(of: "file://", with: "")
    
    logger.info("Linking zsh configuration to: \(configString)")
    logger.info("Linking .zshenv file to: \(destinationString)")
    
    if !dryRun {
      try await linkZshConfig()
      try await fileClient.createSymlink(
        source: fileClient.zshEnvSource,
        destination: destination
      )
    }
    logger.info("Done installing zsh configuration files.")
  }
  
  func uninstall() async throws {
    logger.info("Uninstalling zsh configuration from: \(fileClient.zshConfigDestination.absoluteString)")
    if !dryRun {
      logger.debug("Moving configuration to the trash.")
      try await fileClient.moveToTrash(fileClient.zshConfigDestination)
      logger.debug("Moving .zshenv to the trash.")
      try await fileClient.moveToTrash(fileClient.zshEnvDestination)
    }
    logger.info("Done uninstalling zsh configuration, you will need to reload your shell.")
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
