import Dependencies
import CliMiddleware
import FileClient
import Foundation
import LoggingDependency
import ShellClient

struct Brew {
  @Dependency(\.fileClient) var fileClient
  @Dependency(\.globals.dryRun) var dryRun
  @Dependency(\.logger) var logger
  @Dependency(\.shellClient) var shellClient
  
  let context: CliMiddleware.BrewContext
  
  func run() async throws {
    logger.info("Installing homebrew dependencies.")
    for brewfile in try context.routes.brewfiles() {
      logger.info("Installing dependencies from brewfile: \(brewfile.absoluteString)")
      if !dryRun {
        try shellClient.tap(taps: taps)
        try shellClient.install(brews: brews)
//        try shellClient.install(brewfile: brewfile)
        logger.debug("Done installing dependencies from brewfile: \(brewfile.absoluteString)")
      }
    }
    logger.info("Done installing homebrew dependencies.")
  }
}

fileprivate let taps = [
  "homebrew/cask",
  "homebrew/cask-fonts",
  "federico-terzi/espanso",
  "m-housh/formula"
]

fileprivate let brews = [
  "dots",
  "espanso",
  "fd",
  "figlet",
  "gh",
  "git",
  "httpie",
  "jq",
  "mas",
  "pure",
  "ripgrep",
  "swift-format",
  "swift-zet",
  "tmux",
  "vim",
  "zsh",
  "zsh-completions"
]

fileprivate let brew = "/opt/homebrew/bin/brew"

extension ShellClient {
  
  func tap(taps: [String]) throws {
    var arguments = [
      brew,
      "tap"
    ] + taps
    
    try foregroundShell(arguments)
  }
  
  func install(brews: [String]) throws {
    var arguments = [
      brew,
      "install",
    ] + brews
    try foregroundShell(arguments)
  }
  
  func install(brewfile: URL) throws {
    try foregroundShell(
      "/opt/homebrew/bin/brew",
      "bundle",
      "--no-lock",
      "--cleanup",
      "--debug",
      "--file",
      brewfile.absoluteString
    )
  }
}

fileprivate extension FileClient {
  var brewFileDirectory: URL {
    dotfilesDirectory()
      .appendingPathComponent("macOS")
      .appendingPathComponent(".config")
      .appendingPathComponent("macOS")
  }
}

fileprivate extension CliMiddleware.BrewContext.Route {
  
  static func allBrews() throws -> [URL] {
    let brews: [Self] = [.appStore, .brews, .casks]
    return try brews.map { try $0.brewfile() }
  }
  
  func brewfile() throws -> URL {
    @Dependency(\.fileClient) var fileClient
    switch self {
    case .all:
      // should never happen.
      throw BrewfileError()
    case .appStore:
      return fileClient.brewFileDirectory.appendingPathComponent("AppStore.Brewfile")
    case .brews:
      return fileClient.brewFileDirectory.appendingPathComponent("Brewfile")
    case .casks:
      return fileClient.brewFileDirectory.appendingPathComponent("Casks.Brewfile")
    }
  }
}

fileprivate extension Array where Element == CliMiddleware.BrewContext.Route {
 
  func brewfiles() throws -> [URL] {
    
    if self.count == 1 && self.first == .all {
      return try CliMiddleware.BrewContext.Route.allBrews()
    }
    
    var urls = [URL]()
    for route in self {
      if route != .all {
        let url = try route.brewfile()
        urls.append(url)
      }
    }
    return urls
  }
}

struct BrewfileError: Error { }
