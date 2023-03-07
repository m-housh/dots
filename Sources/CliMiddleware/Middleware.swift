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
  public var espanso: (EspansoContext) async throws -> Void
  public var git: (GitContext) async throws -> Void
  public var install: (InstallContext) async throws -> Void
  public var iterm: (ItermContext) async throws -> Void
  public var nvim: (NeoVimContext) async throws -> Void
  public var scripts: (ScriptsContext) async throws -> Void
  public var tmux: (TmuxContext) async throws -> Void
  public var vim: (VimContext) async throws -> Void
  public var zsh: (ZshContext) async throws -> Void
  
  public init(
    brew: @escaping (BrewContext) async throws -> Void,
    espanso: @escaping (EspansoContext) async throws -> Void,
    git: @escaping (GitContext) async throws -> Void,
    install: @escaping (InstallContext) async throws -> Void,
    iterm: @escaping (ItermContext) async throws -> Void,
    nvim: @escaping (NeoVimContext) async throws -> Void,
    scripts: @escaping (ScriptsContext) async throws -> Void,
    tmux: @escaping (TmuxContext) async throws -> Void,
    vim: @escaping (VimContext) async throws -> Void,
    zsh: @escaping (ZshContext) async throws -> Void
  ) {
    self.brew = brew
    self.espanso = espanso
    self.git = git
    self.install = install
    self.iterm = iterm
    self.nvim = nvim
    self.scripts = scripts
    self.tmux = tmux
    self.vim = vim
    self.zsh = zsh
  }
  
  public struct BrewContext {
    public let appDir: String
    public let routes: [Route]
    
    public init(
      appDir: String,
      routes: [Route]
    ) {
      self.appDir = appDir
      self.routes = routes
    }
    
    public enum Route: String, CaseIterable {
      case all
      case appStore
      case brews
      case casks
    }
  }
  
  public enum EspansoContext {
    case config(InstallationContext)
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
  
  public enum GitContext {
    case add(files: [String]?)
    case config(InstallationContext)
    case status
    case commit(message: String)
    case commitAllAndPush(message: String)
    case pull
    case push
  }
  
  public struct InstallContext {
    
    public let appDir: String
    public let type: InstallationType
    
    public init(
      appDir: String,
      type: InstallationType
    ) {
      self.appDir = appDir
      self.type = type
    }
    
    public enum InstallationType: String, CaseIterable {
      case full
      case minimal
    }
  }
  
  public enum ItermContext {
    case config(InstallationContext)
  }
  
  public enum NeoVimContext {
    case config(InstallationContext)
  }
  
  public enum ScriptsContext {
    case config(InstallationContext)
  }
  
  public enum TmuxContext {
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
    espanso: unimplemented("\(Self.self).espanso"),
    git: unimplemented("\(Self.self).git"),
    install: unimplemented("\(Self.self).install"),
    iterm: unimplemented("\(Self.self).iterm"),
    nvim: unimplemented("\(Self.self).nvim"),
    scripts: unimplemented("\(Self.self).scripts"),
    tmux: unimplemented("\(Self.self).tmux"),
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
