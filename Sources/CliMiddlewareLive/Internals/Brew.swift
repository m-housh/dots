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
      // keep appstore last, encase it does not succeed (currently no apple-id allowed in vm's)
      routes = [.brews, .casks, .appStore]
    }
    
    for route in routes {
      if !dryRun {
        logger.info("Tapping brew.")
        try shellClient.tap(taps: Tap.allCases)
        switch route {
        case .brews:
          logger.info("Install brews.")
          try shellClient.install(brews: Brews.allCases)
        case .casks:
          logger.info("Install casks.")
          try shellClient.install(casks: Cask.allCases, appDir: context.appDir)
        case .appStore:
          logger.info("Install app store dependencies.")
          let apps = App.allCases.map(\.id)
          try? shellClient.install(apps: apps)
        case .all:
          logger.debug("In all case and should not be.")
          logger.debug("\(#file): \(#line)")
          break
        }
      } else {
        logger.info("Dry run called, not intalling any homebrew dependencies.")
        logger.info("Would tap:")
        logger.info("\t\(Tap.allCases.map(\.rawValue).joined(separator: "\n\t"))")
        switch route {
        case .brews:
          logger.info("Would install brews:")
          logger.info("\t\(Brews.allCases.map(\.rawValue).joined(separator: "\n\t"))")
        case .casks:
          logger.info("Would install casks:")
          logger.info("\t\(Cask.allCases.map(\.rawValue).joined(separator: "\n\t"))")
        case .appStore:
          logger.info("Would install App Store Apps:")
          logger.info("\t\(App.all.map({ "\($1): \($0)" }).joined(separator: "\n\t"))")
        case .all:
          logger.debug("In all case and should not be.")
          logger.debug("\(#file): \(#line)")
          break
        }
        return
      }
    }
    logger.info("Done installing homebrew dependencies.")
  }
}

internal enum Tap: String, CaseIterable {
  case cask = "homebrew/cask"
  case fonts = "homebrew/cask-fonts"
  case espanso = "federico-terzi/espanso"
  case mhoush = "m-housh/formula"
}

internal enum Brews: String, CaseIterable {
  case dots
  case fd
  case figlet
  case gh
  case git
  case httpie
  case jq
  case mas
  case neovim
  case pure
  case ripgrep
  case swiftFormat = "swift-format"
  case swiftZet = "swift-zet"
  case tmux
  case vim
  case zsh
  case zshCompletions = "zsh-completions"
}

internal enum Cask: String, CaseIterable {
  case docker
  case espanso
  case chrome = "google-chrome"
  case iterm2
  case onyx
  case nerdFont = "font-inconsolata-nerd-font"
}

fileprivate let brew = "/opt/homebrew/bin/brew"

internal enum App: String, CaseIterable {
  case Xcode
  case pwSafe
  case Developer
  case HomeAssistant = "Home Assistant"
  
  var id: Int {
    switch self {
    case .Xcode:
      return 497799835
    case .pwSafe:
      return 520993579
    case .Developer:
      return 640199958
    case .HomeAssistant:
      return 1099568401
    }
  }
  
  static let all: [(Int, String)] = allCases.map({ ($0.id, $0.rawValue) })
}


internal extension ShellClient {
  
  func tap(taps: [Tap]) throws {
    let arguments = [
      brew,
      "tap"
    ]
    
    // taps have to be done one at a time.
    for tap in taps {
      try foregroundShell(arguments + [tap.rawValue])
    }
    
  }
  
  func install(brews: [Brews]) throws {
    let arguments = [
      brew,
      "install",
    ] + brews.map(\.rawValue)
    try foregroundShell(arguments)
  }
  
  func install(casks: [Cask], appDir: String) throws {
    let arguments = [
      brew,
      "install",
      "--cask",
      "--appdir",
      appDir,
    ] + casks.map(\.rawValue)
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
