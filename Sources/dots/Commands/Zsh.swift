import ArgumentParser
import CliMiddleware
import Dependencies
import Foundation
import LoggingDependency

extension Dots {
  struct Zsh: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Manage zsh configuration.",
      subcommands: [
        Install.self,
        Uninstall.self
      ],
      defaultSubcommand: Install.self
    )
    
    
    struct Install: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        abstract: "Install zsh configuration files."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      func run() async throws {
        try await CliContext(globals: globals) {
          @Dependency(\.cliMiddleware.zsh) var zsh
          @Dependency(\.logger) var logger: Logger
          
          try await zsh(.init(context: .install))
          logger.info("Done.")
        }
        .run()
      }
    }
    
    struct Uninstall: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        abstract: "Uninstall zsh configuration files."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      func run() async throws {
        try await CliContext(globals: globals) {
          @Dependency(\.cliMiddleware.zsh) var zsh
          @Dependency(\.logger) var logger: Logger
          
          try await zsh(.init(context: .uninstall))
          logger.info("Done.")
        }
        .run()
      }
    }
  }
}
