import ArgumentParser
import Dependencies
import Foundation
import LoggingDependency
import ShellClient

extension Builder {
  
  struct Build: ParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "build",
      abstract: "Build the `dots` application."
    )
    
    func run() throws {
      @Dependency(\.shellClient) var shellClient: ShellClient
      @Dependency(\.logger) var logger: Logger
      
      func withVersion(in file: String, as version: String, _ closure: () throws -> ()) throws {
        logger.info("Updating version.")
        let fileURL = URL(fileURLWithPath: file)
        let originalFileContents = try String(contentsOf: fileURL, encoding: .utf8)
        // set version
        try originalFileContents
          .replacingOccurrences(of: "nil", with: "\"\(version)\"")
          .write(to: fileURL, atomically: true, encoding: .utf8)
        defer {
          // undo set version
          try! originalFileContents
            .write(to: fileURL, atomically: true, encoding: .utf8)
        }
        // run closure
        try closure()
      }
      
      try withVersion(in: "Sources/dots/Version.swift", as: shellClient.currentVersion()) {
        try shellClient.foregroundShell(
          "swift", "build",
          "--disable-sandbox",
          "--configuration", "release",
          "-Xswiftc", "-cross-module-optimization"
        )
      }
    }
  }
}
