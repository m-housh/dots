import Dependencies
@_exported import CliMiddleware
@_exported import FileClient
@_exported import LoggingDependency
@_exported import ShellClient
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension CliMiddleware: DependencyKey {
  public static var liveValue: CliMiddleware {
    .init(
      brew: { try await $0.run() },
      espanso: { try await $0.run() },
      git: { try await $0.run() },
      install: { try await $0.run() },
      iterm: { try await $0.run() },
      nvim: { try await $0.run() },
      scripts: { try await $0.run() },
      tmux: { try await $0.run() },
      vim: { try await $0.run() },
      zsh: { try await $0.run() }
    )
  }
}
