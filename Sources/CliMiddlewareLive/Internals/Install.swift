import CliMiddleware
import Dependencies
import Foundation
import ShellClient

extension CliMiddleware.InstallContext {
  
  func run() async throws {
    @Dependency(\.cliMiddleware) var cliMiddleware
    @Dependency(\.shellClient) var shellClient
    
    switch self.type {
    case .full:
      // run minimal items first.
      try await cliMiddleware.install(.init(appDir: self.appDir, type: .minimal))
      try await cliMiddleware.brew(.init(appDir: self.appDir, routes: [.casks, .appStore]))
      try await cliMiddleware.espanso(.config(.install))
      try await cliMiddleware.iterm(.config(.install))
      try await cliMiddleware.nvim(.config(.install))
      try await cliMiddleware.scripts(.config(.install))
    case .minimal:
      try await cliMiddleware.brew(.init(appDir: self.appDir, routes: [.brews]))
      try shellClient.install(casks: [.iterm2], appDir: self.appDir)
      try await cliMiddleware.git(.config(.install))
      try await cliMiddleware.iterm(.config(.install))
      try await cliMiddleware.tmux(.config(.install))
      try await cliMiddleware.vim(.config(.install))
      try await cliMiddleware.zsh(.init(context: .install))
    }
  }
  
}
