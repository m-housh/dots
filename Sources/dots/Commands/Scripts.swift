import ArgumentParser
import CliMiddleware
import Dependencies
import Foundation

extension Dots {
  struct Scripts: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Perform script tasks.",
      subcommands: [
        InstallScripts.self,
        UninstallScripts.self
      ],
      defaultSubcommand: InstallScripts.self
    )
    
    struct InstallScripts: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        abstract: "Install the scripts directory."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      func run() async throws {
        try await CliContext(globals: globals, run: {
          @Dependency(\.cliMiddleware.scripts) var scripts
          try await scripts(.config(.install))
        })
        .run()
      }
    }
    
    struct UninstallScripts: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        abstract: "Uninstall the scripts directory."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      func run() async throws {
        try await CliContext(globals: globals, run: {
          @Dependency(\.cliMiddleware.scripts) var scripts
          try await scripts(.config(.uninstall))
        })
        .run()
      }
    }
  }
}
