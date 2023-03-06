import ArgumentParser
import CliMiddleware
import Dependencies
import Foundation

extension Dots {
  struct Espanso: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Perform espanso tasks.",
      subcommands: [
        InstallScripts.self,
        UninstallScripts.self
      ],
      defaultSubcommand: InstallScripts.self
    )
    
    struct InstallScripts: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        commandName: "install",
        abstract: "Install the espanso configuration."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      func run() async throws {
        try await CliContext(globals: globals, run: {
          @Dependency(\.cliMiddleware.espanso) var espanso
          try await espanso(.config(.install))
        })
        .run()
      }
    }
    
    struct UninstallScripts: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        commandName: "uninstall",
        abstract: "Uninstall the espanso configuration."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      func run() async throws {
        try await CliContext(globals: globals, run: {
          @Dependency(\.cliMiddleware.espanso) var espanso
          try await espanso(.config(.uninstall))
        })
        .run()
      }
    }
  }
}
