import ArgumentParser
import Foundation

/// This builds the project and creates bottles to upload that can be installed via homebrew.
///
@main
struct Builder: AsyncParsableCommand {
  
  static let configuration = CommandConfiguration(
    abstract: "Command line tool that manages building and bottling the `dots` application.",
    subcommands: [
      Build.self,
      Bottle.self
    ],
    defaultSubcommand: Build.self
  )
}
