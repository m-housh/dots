import ArgumentParser
import CliMiddleware
import Dependencies
import Foundation

extension Dots {
  
  struct Vim: AsyncParsableCommand {
    static let configuration: CommandConfiguration = .init(
      abstract: "Perform vim actions.",
      subcommands: [
        InstallConfig.self,
        UninstallConfig.self
      ],
      defaultSubcommand: InstallConfig.self
    )
    
    struct InstallConfig: AsyncParsableCommand {
      static let configuration: CommandConfiguration = .init(
        abstract: "Install the vim configuration."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      func run() async throws {
        try await CliContext(globals: globals, run: {
          @Dependency(\.cliMiddleware.vim) var vim
          try await vim(.config(.install))
        })
        .run()
      }
      
    }
    
    struct UninstallConfig: AsyncParsableCommand {
      static let configuration: CommandConfiguration = .init(
        abstract: "Uninstall the vim configuration."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      func run() async throws {
        try await CliContext(globals: globals, run: {
          @Dependency(\.cliMiddleware.vim) var vim
          try await vim(.config(.uninstall))
        })
        .run()
      }
      
    }
  }
}
