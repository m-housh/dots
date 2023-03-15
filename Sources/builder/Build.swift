import ArgumentParser
import Dependencies
import Foundation
import ShellClient

extension Builder {
  
  struct Build: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "build",
      abstract: "Build the `dots` application."
    )
    
    func run() async throws {
      @Dependency(\.shellClient) var shellClient: ShellClient
      @Dependency(\.logger) var logger: Logger

      try shellClient.foreground([
        "swift", "build",
        "--disable-sandbox",
        "--configuration", "release",
        "-Xswiftc", "-cross-module-optimization"
      ])
    }
  }
}
