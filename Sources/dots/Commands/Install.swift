import ArgumentParser
import CliMiddleware
import Dependencies
import Foundation

extension Dots {
  
  struct Install: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "install",
      abstract: "Install dependencies, this is useful when setting up a new machine."
    )
    
    @OptionGroup var globals: GlobalOptions
    
    @Flag(help: "What dependencies to install.")
    var context: CliMiddleware.InstallContext = .minimal
    
    func run() async throws {
      try await CliContext(globals: globals) {
        @Dependency(\.cliMiddleware.install) var install
        try await install(context)
      }
      .run()
    }
    
  }
}

extension CliMiddleware.InstallContext: EnumerableFlag { }
