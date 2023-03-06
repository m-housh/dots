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
    var context: CliMiddleware.InstallContext.InstallationType = .minimal
    
    @Argument(help: "Customize the application directory.")
    var appDir: String = "/Applications"
    
    func run() async throws {
      try await CliContext(globals: globals) {
        @Dependency(\.cliMiddleware.install) var install
        try await install(.init(appDir: appDir, type: context))
      }
      .run()
    }
    
  }
}

extension CliMiddleware.InstallContext.InstallationType: EnumerableFlag { }
