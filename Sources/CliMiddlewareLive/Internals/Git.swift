import CliMiddleware
import Dependencies
import FileClient
import Foundation
import LoggingDependency
import ShellClient

extension CliMiddleware.GitContext {
  func run() async throws {
    @Dependency(\.shellClient) var shellClient
    
    switch self {
    case let .add(files: files):
      var arguments = ["git", "add"]
      if let files {
        arguments += files
      } else {
        arguments.append("--all")
      }
      try shellClient.runInDotfilesDirectory(arguments)
    case let .config(config):
      try await config.handleGit()
    case .status:
      try shellClient.runInDotfilesDirectory("git", "status")
    case .commit(message: let message):
      try shellClient.runInDotfilesDirectory("git", "commit", "-a", "-m", message)
    case .pull:
      try shellClient.runInDotfilesDirectory("git", "pull")
    case .push:
      try shellClient.runInDotfilesDirectory("git", "push")
    }
  }
}

fileprivate extension CliMiddleware.InstallationContext {
  
  func handleGit() async throws {
    @Dependency(\.fileClient) var fileClient
    @Dependency(\.globals.dryRun) var dryRun
    @Dependency(\.logger) var logger
    
    switch self {
    case .install:
      logger.info("Installing git configuration.")
      try await fileClient.install(
        source: \.gitConfigDirectory,
        destination: \.gitConfigDestination,
        dryRun: dryRun
      )
    case .uninstall:
      logger.info("Uninstalling git configuration.")
      try await fileClient.uninstall(destination: \.gitConfigDestination, dryRun: dryRun)
    }
  }
 
}

fileprivate extension FileClient {
  
  var gitConfigDirectory: URL {
    dotfilesDirectory()
      .appendingPathComponent("git")
      .appendingPathComponent("git")
  }
  
  var gitConfigDestination: URL {
    configDirectory()
      .appendingPathComponent("git")
  }
}
