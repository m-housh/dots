import ArgumentParser
import CliMiddleware
import Dependencies
import Foundation

extension Dots {
  struct Tmux: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Perform tmux tasks.",
      subcommands: [
        InstallScripts.self,
        UninstallScripts.self
      ],
      defaultSubcommand: InstallScripts.self
    )
    
    struct InstallScripts: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        commandName: "install",
        abstract: "Install the tmux configuration."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      func run() async throws {
        try await CliContext(globals: globals, run: {
          @Dependency(\.cliMiddleware.tmux) var tmux
          try await tmux(.config(.install))
        })
        .run()
      }
    }
    
    struct UninstallScripts: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        commandName: "uninstall",
        abstract: "Uninstall the tmux configuration."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      func run() async throws {
        try await CliContext(globals: globals, run: {
          @Dependency(\.cliMiddleware.tmux) var tmux
          try await tmux(.config(.uninstall))
        })
        .run()
      }
    }
  }
}
