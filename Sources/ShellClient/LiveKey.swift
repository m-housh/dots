import Dependencies
import Foundation
import LoggingDependency
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension ShellClient: DependencyKey {
 
  public static var liveValue: ShellClient {
    @Dependency(\.logger) var logger
    
    return .init(
      foregroundShell: { arguments in
        logger.debug("Running in foreground shell.")
        logger.debug("$ \(arguments.joined(separator: " "))")
        
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = arguments
        task.launch()
        task.waitUntilExit()
        
        guard task.terminationStatus == 0 else {
          throw ShellError(terminationStatus: task.terminationStatus)
        }
      },
      backgroundShell: { arguments in
        logger.debug("Running background shell.")
        logger.debug("$ \(arguments.joined(separator: " "))")
        
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = arguments
        // grab stdout
        let output = Pipe()
        task.standardOutput = output
        // ignore stderr
        let error = Pipe()
        task.standardError = error
        task.launch()
        task.waitUntilExit()
        
        guard task.terminationStatus == 0 else {
          throw ShellError(terminationStatus: task.terminationStatus)
        }
        
        return String(decoding: output.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
          .trimmingCharacters(in: .whitespacesAndNewlines)
        
      }
    )
  }
  
}

struct ShellError: Swift.Error {
  var terminationStatus: Int32
}
