import ArgumentParser
import CliMiddleware
import Dependencies
import Foundation

extension Dots {
  
  struct Git: AsyncParsableCommand {
    static let configuration: CommandConfiguration = .init(
      abstract: "Perform git actions.",
      subcommands: [
        InstallConfig.self,
        UninstallConfig.self
      ],
      defaultSubcommand: InstallConfig.self
    )
    
    struct InstallConfig: AsyncParsableCommand {
      static let configuration: CommandConfiguration = .init(
        abstract: "Install the git configuration."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      func run() async throws {
        try await CliContext(globals: globals, run: {
          @Dependency(\.cliMiddleware.git) var git
          try await git(.config(.install))
        })
        .run()
      }
      
    }
    
    struct UninstallConfig: AsyncParsableCommand {
      static let configuration: CommandConfiguration = .init(
        abstract: "Uninstall the git configuration."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      func run() async throws {
        try await CliContext(globals: globals, run: {
          @Dependency(\.cliMiddleware.git) var git
          try await git(.config(.uninstall))
        })
        .run()
      }
      
    }
  }
}
