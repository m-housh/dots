import Dependencies
import Foundation
import XCTestDynamicOverlay

/// Implements the logic for the `dots` command line tool.
///
/// Each command and it's sub-commands are implemented in the ``CliMiddlewareLive`` module.  While this
/// represents the interface.
///
public struct CliMiddleware {
  
  public var brew: (BrewContext) async throws -> Void
  public var zsh: (ZshContext) async throws -> Void
  
  public init(
    brew: @escaping (BrewContext) async throws -> Void,
    zsh: @escaping (ZshContext) async throws -> Void
  ) {
    self.brew = brew
    self.zsh = zsh
  }
  
  public struct GlobalContext {
    public let dryRun: Bool
    
    public init(dryRun: Bool) {
      self.dryRun = dryRun
    }
  }
  
  public struct BrewContext {
    public let routes: [Route]
    
    public init(
      routes: [Route]
    ) {
      self.routes = routes
    }
    
    public enum Route: String, CaseIterable {
      case all
      case appStore
      case brews
      case casks
    }
  }
  
  public struct ZshContext {
    
    public let context: Context
    
    public init(
      context: Context
    ) {
      self.context = context
    }
    
    public enum Context {
      case install
      case uninstall
    }
  }
}

extension CliMiddleware.GlobalContext: TestDependencyKey {
  public static let testValue: CliMiddleware.GlobalContext = .init(dryRun: true)
}

extension CliMiddleware: TestDependencyKey {
  
  public static let noop = Self.init(
    brew: unimplemented("\(Self.self).brew"),
    zsh: unimplemented("\(Self.self).zsh")
  )
  
  public static let testValue = CliMiddleware.noop
}

extension DependencyValues {
  
  public var cliMiddleware: CliMiddleware {
    get { self[CliMiddleware.self] }
    set { self[CliMiddleware.self] = newValue }
  }
  
  public var globals: CliMiddleware.GlobalContext {
    get { self[CliMiddleware.GlobalContext.self] }
    set { self[CliMiddleware.GlobalContext.self] = newValue }
  }
}
