import ArgumentParser
import CliMiddleware
import Dependencies
import Foundation

struct GlobalOptions: ParsableArguments {
  @Flag(
    name: .long,
    help: "Perform an action as a dry-run, not removing or installing anything."
  )
  var dryRun: Bool = false
  
  @Flag(
    name: .long,
    help: "Increase logging output level."
  )
  var verbose: Bool = false
}

extension CliMiddleware.GlobalContext {
  static func live(_ globalOptions: GlobalOptions) -> Self {
    .init(dryRun: globalOptions.dryRun)
  }
}
