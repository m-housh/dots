import Dependencies
import FileClient
import Foundation
import ShellClient
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif


extension FileClient {
  func ensureConfigDirectory() async throws {
    try await createDirectory(at: configDirectory())
  }
  
  func install(
    source: URL,
    destination: URL,
    dryRun: Bool,
    ensureConfigDirectory: Bool = true
  ) async throws {
    @Dependency(\.logger) var logger: Logger
    
    let prefix = dryRun ? "Would have linked" : "Linked"
    if ensureConfigDirectory {
      logger.debug("Ensuring configuration directory exists.")
      try await self.ensureConfigDirectory()
    }
    if !dryRun {
      logger.debug("Creating symlink...")
      try await createSymlink(source: source, destination: destination)
    } else {
      logger.debug("Dry run called.")
    }
    logger.info("\(prefix): \(source.absoluteString) -> \(destination.absoluteString)")
  }
  
  func install(
    source: KeyPath<Self, URL>,
    destination: KeyPath<Self, URL>,
    dryRun: Bool,
    ensureConfigDirectory: Bool = true
  ) async throws {
    try await self.install(
      source: self[keyPath: source],
      destination: self[keyPath: destination],
      dryRun: dryRun,
      ensureConfigDirectory: ensureConfigDirectory
    )
  }
  
  func uninstall(
    destination: URL,
    dryRun: Bool
  ) async throws {
    @Dependency(\.logger) var logger: Logger
    
    let prefix = dryRun ? "Would have moved" : "Moved"
    if !dryRun {
      logger.debug("Moving to the trash...")
      try await moveToTrash(destination)
    } else {
      logger.debug("Dry run called.")
    }
    logger.info("\(prefix): \(destination.absoluteString) to the trash.")
  }
  
  func uninstall(
    destination: KeyPath<Self, URL>,
    dryRun: Bool
  ) async throws {
    try await self.uninstall(
      destination: self[keyPath: destination],
      dryRun: dryRun
    )
  }
}
