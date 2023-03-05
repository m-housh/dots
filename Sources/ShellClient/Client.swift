import Dependencies
import Foundation
import XCTestDynamicOverlay
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct ShellClient {
  public var foregroundShell: ([String]) throws -> Void
  public var backgroundShell: ([String]) throws -> String
  
  public func foregroundShell(_ arguments: String...) throws {
    try self.foregroundShell(arguments)
  }
  
  @discardableResult
  public func backgroundShell(_ arguments: String...) throws -> String {
    try self.backgroundShell(arguments)
  }
}

extension ShellClient: TestDependencyKey {
  
  public static let noop = Self.init(
    foregroundShell: unimplemented(),
    backgroundShell: unimplemented(placeholder: "")
  )
  
  public static let testValue: ShellClient = .noop
}

extension DependencyValues {
  public var shellClient: ShellClient {
    get { self[ShellClient.self] }
    set { self[ShellClient.self] = newValue }
  }
}
