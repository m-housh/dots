import ArgumentParser
import Dependencies
import Foundation

struct CliContext {
  let globals: GlobalOptions?
  let _run: () async throws -> Void
  
  init(globals: GlobalOptions? = nil, run: @escaping () async throws -> Void) {
    self.globals = globals
    self._run = run
  }
  
  func run() async throws {
    try await withDependencies {
      if let globals {
        $0.globals = .live(globals)
        if globals.verbose {
          $0.logger.logLevel = .debug
        }
      } else {
        $0.globals = .liveValue
      }
    } operation: {
      try await _run()
    }
  }
}
