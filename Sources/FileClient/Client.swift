import Dependencies
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import ShellClient
import XCTestDynamicOverlay

/// Represents interactions with the file system.
///
public struct FileClient {
  
  public var configDirectory: () -> URL
  public var createDirectory: (URL, Bool) async throws -> Void
  public var createSymlink: (URL, URL) async throws -> Void
  public var dotfilesDirectory: () -> URL
  public var homeDirectory: () -> URL
  public var exists: (URL) async throws -> Bool
  public var readFile: (URL) async throws -> Data
  public var moveToTrash: (URL) async throws -> Void
  public var writeFile: (Data, URL) async throws -> Void
  
  public init(
    configDirectory: @escaping () -> URL,
    createDirectory: @escaping (URL, Bool) async throws -> Void,
    createSymlink: @escaping (URL, URL) async throws -> Void,
    dotfilesDirectory: @escaping () -> URL,
    homeDirectory: @escaping () -> URL,
    exists: @escaping (URL) async throws -> Bool,
    readFile: @escaping (URL) async throws -> Data,
    moveToTrash: @escaping (URL) async throws -> Void,
    writeFile: @escaping (Data, URL) async throws -> Void
  ) {
    self.configDirectory = configDirectory
    self.createDirectory = createDirectory
    self.createSymlink = createSymlink
    self.dotfilesDirectory = dotfilesDirectory
    self.homeDirectory = homeDirectory
    self.exists = exists
    self.readFile = readFile
    self.moveToTrash = moveToTrash
    self.writeFile = writeFile
  }
  
  public func createDirectory(
    at url: URL,
    withIntermediates: Bool = true
  ) async throws {
    let exists = try await self.exists(url)
    if !exists {
      try await createDirectory(url, withIntermediates)
    }
  }
  
  public func createSymlink(
    source: URL,
    destination: URL,
    force: Bool = false
  ) async throws {
    @Dependency(\.logger) var logger: Logger
    let exists = try await exists(destination)
    if exists && !force {
      logger.info("Skipping already exists at: \(destination.absoluteString)")
      return
    }
    if exists && force {
      logger.debug("Removing existing item at: \(destination.absoluteString)")
      try await moveToTrash(destination)
    }
    try await self.createSymlink(source, destination)
  }
  
  public func read(file: URL) async throws -> Data {
    try await self.readFile(file)
  }
  
  public func write(data: Data, to file: URL) async throws {
    try await writeFile(data, file)
  }
}

extension FileClient: TestDependencyKey {
  public static let noop = Self.init(
    configDirectory: unimplemented(placeholder: URL(string: "/")!),
    createDirectory: unimplemented(),
    createSymlink: unimplemented(),
    dotfilesDirectory: unimplemented(placeholder: URL(string: "/")!),
    homeDirectory: unimplemented(),
    exists: unimplemented(placeholder: false),
    readFile: unimplemented(placeholder: Data()),
    moveToTrash: unimplemented(),
    writeFile: unimplemented()
  )
  
  public static let testValue: FileClient = .noop
  
}

extension DependencyValues {
  public var fileClient: FileClient {
    get { self[FileClient.self] }
    set { self[FileClient.self] = newValue }
  }
}
