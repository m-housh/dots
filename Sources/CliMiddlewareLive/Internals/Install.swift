import CliMiddleware
import Dependencies
import Foundation

extension CliMiddleware.InstallContext {
  
  func run() async throws {
    @Dependency(\.cliMiddleware) var cliMiddleware
    
    switch self {
    case .full:
      // run minimal items first.
      try await cliMiddleware.install(.minimal)
      try await cliMiddleware.brew(.init(routes: [.casks, .appStore]))
      try await cliMiddleware.iterm(.config(.install))
      try await cliMiddleware.scripts(.config(.install))
    case .minimal:
      try await cliMiddleware.brew(.init(routes: [.brews]))
      try await cliMiddleware.git(.config(.install))
      try await cliMiddleware.vim(.config(.install))
      try await cliMiddleware.zsh(.init(context: .install))
    }
  }
  
}
