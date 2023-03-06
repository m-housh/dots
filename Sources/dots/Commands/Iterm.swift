import ArgumentParser
import CliMiddleware
import Dependencies
import Foundation

extension Dots {
  struct Iterm: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Perform iterm tasks.",
      subcommands: [
        InstallScripts.self,
        UninstallScripts.self
      ],
      defaultSubcommand: InstallScripts.self
    )
    
    struct InstallScripts: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        commandName: "install",
        abstract: "Install the iterm configuration."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      func run() async throws {
        try await CliContext(globals: globals, run: {
          @Dependency(\.cliMiddleware.iterm) var iterm
          try await iterm(.config(.install))
        })
        .run()
      }
    }
    
    struct UninstallScripts: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        commandName: "uninstall",
        abstract: "Uninstall the iterm configuration."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      func run() async throws {
        try await CliContext(globals: globals, run: {
          @Dependency(\.cliMiddleware.iterm) var iterm
          try await iterm(.config(.uninstall))
        })
        .run()
      }
    }
  }
}
