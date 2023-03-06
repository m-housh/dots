import ArgumentParser
import CliMiddleware
import Dependencies
import Foundation

extension Dots {
  struct Nvim: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Perform neo-vim tasks.",
      subcommands: [
        InstallScripts.self,
        UninstallScripts.self
      ],
      defaultSubcommand: InstallScripts.self
    )
    
    struct InstallScripts: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        commandName: "install",
        abstract: "Install the neo-vim configuration."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      func run() async throws {
        try await CliContext(globals: globals, run: {
          @Dependency(\.cliMiddleware.nvim) var nvim
          try await nvim(.config(.install))
        })
        .run()
      }
    }
    
    struct UninstallScripts: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        commandName: "uninstall",
        abstract: "Uninstall the neo-vim configuration."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      func run() async throws {
        try await CliContext(globals: globals, run: {
          @Dependency(\.cliMiddleware.nvim) var nvim
          try await nvim(.config(.uninstall))
        })
        .run()
      }
    }
  }
}
