import Dependencies
import Foundation
import LoggingDependency
import Logging
import ShellClient

try run()

LoggingSystem.bootstrap(StreamLogHandler.standardOutput(label:))

func run() throws {
  @Dependency(\.logger) var logger: Logger
  @Dependency(\.shellClient) var shellClient: ShellClient
  
  let tap = "m-housh/formula"
  let formula = "dots"
  
  logger.info("Tapping: \(tap)")
  
   // Uninstall if we've already installed dots on this machine.
  do {
    try shellClient.foregroundShell(
      "brew", "uninstall", "\(tap)/\(formula)"
    )
  }

  try shellClient.foregroundShell(
    "brew", "tap", "\(tap)"
  )

  logger.info("Installing: \(tap)/\(formula)")
  try shellClient.foregroundShell(
    "brew", "install", "--build-bottle", "\(tap)/\(formula)"
  )

  logger.info("Bottling...")
  try shellClient.foregroundShell(
    "brew", "bottle", "\(tap)/\(formula)"
  )

}
