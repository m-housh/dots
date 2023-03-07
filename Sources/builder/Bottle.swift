import ArgumentParser
import Dependencies
import Foundation
import LoggingDependency
import ShellClient

extension Builder {
  struct Bottle: ParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "bottle",
      abstract: "Bottles the `dots` application."
    )
    
    func run() throws {
      
      @Dependency(\.logger) var logger: Logger
      @Dependency(\.shellClient) var shellClient: ShellClient
      
      let tap = "m-housh/formula"
      let formula = "dots"
      let fullFormula = "\(tap)/\(formula)"
      let version = try shellClient.currentVersion()
      let rootUrl = "https://github.com/m-housh/dots/releases/download/\(version)"
      
      logger.info("Tapping: \(tap)")
      
      // Uninstall first, if we've already installed dots on this machine.
      do {
        try shellClient.foregroundShell(
          brew, "uninstall", fullFormula
        )
      }
      
      // tap
      try shellClient.foregroundShell(
        brew, "tap", "\(tap)"
      )
      
      // install
      logger.info("Installing: \(fullFormula)")
      try shellClient.foregroundShell(
        brew, "install", "--build-bottle", fullFormula
      )
      
      // bottle
      logger.info("Bottling: \(fullFormula)")
      try shellClient.foregroundShell(
        brew, "bottle", "--root-url", rootUrl, fullFormula
      )
      
    }
  }
}

fileprivate let brew = "brew"

