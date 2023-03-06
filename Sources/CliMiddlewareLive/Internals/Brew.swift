import Dependencies
import CliMiddleware
import FileClient
import Foundation
import LoggingDependency
import ShellClient

struct Brew {
  @Dependency(\.globals.dryRun) var dryRun
  @Dependency(\.logger) var logger
  @Dependency(\.shellClient) var shellClient
  
  let context: CliMiddleware.BrewContext
  
  func run() async throws {
    logger.info("Installing homebrew dependencies.")
    var routes = context.routes
    if context.routes.contains(.all) {
      routes = [.appStore, .brews, .casks]
    }
    
    for route in routes {
      if !dryRun {
        logger.info("Tapping brew.")
        try shellClient.tap(taps: taps)
        if route == .brews {
          logger.info("Install brews.")
          try shellClient.install(brews: brews)
        } else if route == .casks {
          logger.info("Install casks.")
          try shellClient.install(casks: casks, appDir: context.appDir)
        } else if route == .appStore {
          logger.info("Install app store dependencies.")
          let apps = appStore.map(\.0)
          try shellClient.install(apps: apps)
        }
      } else {
        logger.info("Dry run called, not intalling any homebrew dependencies.")
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

fileprivate let casks = [
  "docker",
  "espanso",
  "google-chrome",
  "iterm2",
  "onyx",
  "rectangle",
  "font-inconsolata-nerd-font"
]

fileprivate let brew = "/opt/homebrew/bin/brew"

fileprivate let appStore = [
  (497799835, "Xcode"),
  (520993579, "pwSafe"),
  (640199958, "Developer"),
  (1099568401, "Home Assistant")
]

extension ShellClient {
  
  func tap(taps: [String]) throws {
    let arguments = [
      brew,
      "tap"
    ]
    
    for tap in taps {
      try foregroundShell(arguments + [tap])
    }
    
  }
  
  func install(brews: [String]) throws {
    let arguments = [
      brew,
      "install",
    ] + brews
    try foregroundShell(arguments)
  }
  
  func install(casks: [String], appDir: String) throws {
    let arguments = [
      brew,
      "install",
      "--cask",
      "--appdir",
      appDir,
    ] + casks
    try foregroundShell(arguments)
  }
  
  func install(apps: [Int]) throws {
    for app in apps {
      let arguments = [
        "/opt/homebrew/bin/mas",
        "install",
        "\(app)"
      ]
      try foregroundShell(arguments)
    }
  }

}
