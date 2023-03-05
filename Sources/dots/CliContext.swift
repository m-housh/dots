import ArgumentParser
import Dependencies
import Foundation

struct CliContext {
  let globals: GlobalOptions
  let _run: () async throws -> Void
  
  init(globals: GlobalOptions, run: @escaping () async throws -> Void) {
    self.globals = globals
    self._run = run
  }
  
  func run() async throws {
    try await withDependencies {
      if globals.verbose {
        $0.logger.logLevel = .debug
      }
      $0.globals = .live(globals)
    } operation: {
      try await _run()
    }
  }
}
