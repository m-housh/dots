import ArgumentParser
import Foundation

@main
struct Builder: ParsableCommand {
  
  static let configuration = CommandConfiguration(
    abstract: "Command line tool that manages building and bottling the `dots` application.",
    subcommands: [
      Build.self,
      Bottle.self
    ],
    defaultSubcommand: Build.self
  )
}
