import Dependencies
import Foundation
import XCTestDynamicOverlay
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct ShellClient {
  /// Run shell commands in a foreground shell.
  public var foregroundShell: ([String]) throws -> Void
  
  /// Run shell commands in a background shell, returning the output as `Data`.
  public var backgroundShellData: ([String]) throws -> Data
  
  /// Run shell commands in a foreground shell.
  public func foregroundShell(_ arguments: String...) throws {
    try self.foregroundShell(arguments)
  }
  
  /// Run shell commands in a background shell, returning the output as `Data`.
  @discardableResult
  public func backgroundShellData(_ arguments: String...) throws -> Data {
    try self.backgroundShellData(arguments)
  }
  
  /// Run shell commands in a background shell and attempt to decode the output `Data`.
  ///
  @discardableResult
  public func backgroundShell<V: Decodable>(
    as decodable: V.Type,
    _ arguments: [String]
  ) throws -> V {
    let decoder = JSONDecoder()
    let output = try self.backgroundShellData(arguments)
    return try decoder.decode(V.self, from: output)
  }
  
  /// Run shell commands in a background shell and attempt to decode the output `Data`.
  ///
  @discardableResult
  public func backgroundShell<V: Decodable>(
    as decodable: V.Type,
    _ arguments: String...
  ) throws -> V {
    try backgroundShell(as: V.self, arguments)
  }
  
  /// Run shell commands in a background shell and decode the output as a string that
  /// trims any new-lines and white spaces.
  ///
  @discardableResult
  public func backgroundShell(_ arguments: String...) throws -> String {
    let output = try backgroundShellData(arguments)
    return String(decoding: output, as: UTF8.self)
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

extension ShellClient: TestDependencyKey {
  
  public static let noop = Self.init(
    foregroundShell: unimplemented(),
    backgroundShellData: unimplemented(placeholder: Data())
  )
  
  public static let testValue: ShellClient = .noop
}

extension DependencyValues {
  public var shellClient: ShellClient {
    get { self[ShellClient.self] }
    set { self[ShellClient.self] = newValue }
  }
}
