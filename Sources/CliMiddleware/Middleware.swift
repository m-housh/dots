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
  public var git: (GitContext) async throws -> Void
  public var iterm: (ItermContext) async throws -> Void
  public var scripts: (ScriptsContext) async throws -> Void
  public var vim: (VimContext) async throws -> Void
  public var zsh: (ZshContext) async throws -> Void
  
  public init(
    brew: @escaping (BrewContext) async throws -> Void,
    git: @escaping (GitContext) async throws -> Void,
    iterm: @escaping (ItermContext) async throws -> Void,
    scripts: @escaping (ScriptsContext) async throws -> Void,
    vim: @escaping (VimContext) async throws -> Void,
    zsh: @escaping (ZshContext) async throws -> Void
  ) {
    self.brew = brew
    self.git = git
    self.iterm = iterm
    self.scripts = scripts
    self.vim = vim
    self.zsh = zsh
  }
  
  public struct GlobalContext {
    public let dryRun: Bool
    
    public init(dryRun: Bool) {
      self.dryRun = dryRun
    }
  }
  
  public enum InstallationContext {
    case install
    case uninstall
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
  
  public enum GitContext {
    case add(file: String?)
    case config(InstallationContext)
    case status
    case commit(message: String)
    case pull
    case push
  }
  
  public enum ItermContext {
    case config(InstallationContext)
  }
  
  public enum ScriptsContext {
    case config(InstallationContext)
  }
  
  public enum VimContext {
    case config(InstallationContext)
  }
  
  public struct ZshContext {
    
    public let context: InstallationContext
    
    public init(
      context: InstallationContext
    ) {
      self.context = context
    }
  }
}

extension CliMiddleware.GlobalContext: TestDependencyKey {
  public static let testValue: CliMiddleware.GlobalContext = .init(dryRun: true)
}

extension CliMiddleware: TestDependencyKey {
  
  public static let noop = Self.init(
    brew: unimplemented("\(Self.self).brew"),
    git: unimplemented("\(Self.self).git"),
    iterm: unimplemented("\(Self.self).iterm"),
    scripts: unimplemented("\(Self.self).scripts"),
    vim: unimplemented("\(Self.self).vim"),
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
