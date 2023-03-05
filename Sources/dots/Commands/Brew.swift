import ArgumentParser
import CliMiddleware
import Dependencies
import Foundation
import LoggingDependency

extension Dots {
  
  struct Brew: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
      abstract: "Manage homebrew dependency installation.",
      subcommands: [
        Install.self
      ],
      defaultSubcommand: Install.self
    )
    
    struct Install: AsyncParsableCommand {
      
      static let configuration = CommandConfiguration(
        abstract: "Install brew dependencies from the brewfiles."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      @Flag(help: "The homebrew dependencies to install from their brewfiles.")
      var routes: [CliMiddleware.BrewContext.Route] = [.all]
      
      func run() async throws {
        try await CliContext(globals: globals) {
          @Dependency(\.cliMiddleware.brew) var brew
          @Dependency(\.logger) var logger: Logger
          
          logger.debug("Routes: \(routes)")
          try await brew(.init(routes: routes))
          logger.info("Done.")
        }
        .run()
      }
    }
  }
}

extension CliMiddleware.BrewContext.Route: EnumerableFlag { }
