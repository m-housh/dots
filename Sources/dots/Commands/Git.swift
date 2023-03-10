import ArgumentParser
import CliMiddleware
import Dependencies
import Foundation

extension Dots {
  
  struct Git: AsyncParsableCommand {
    static let configuration: CommandConfiguration = .init(
      abstract: "Perform git actions.",
      subcommands: [
        Add.self,
        Commit.self,
        CommitAllAndPush.self,
        InstallConfig.self,
        Status.self,
        Pull.self,
        Push.self,
        UninstallConfig.self
      ],
      defaultSubcommand: InstallConfig.self
    )
    
    struct Add: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        abstract: "Add a file to the git repository, or all the files if not supplied."
      )
      
      @Argument(
        help: "Files to start tracking in git."
      )
      var files: [String] = []
      
      func run() async throws {
        try await CliContext {
          @Dependency(\.cliMiddleware.git) var git
          let files = self.files.count == 0
            ? nil
            : self.files
          
          try await git(.add(files: files))
        }
        .run()
      }
    }
    
    struct Commit: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        abstract: "Commit the dotfiles."
      )
      
      @Argument
      var message: String
      
      func run() async throws {
        try await CliContext {
          @Dependency(\.cliMiddleware.git) var git
          try await git(.commit(message: message))
        }
        .run()
      }
    }
    
    struct CommitAllAndPush: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        commandName: "commit-all",
        abstract: "Commit and push the dotfiles."
      )
      
      @Argument
      var message: String
      
      func run() async throws {
        try await CliContext {
          @Dependency(\.cliMiddleware.git) var git
          try await git(.commitAllAndPush(message: message))
        }
        .run()
      }
    }
    
    struct InstallConfig: AsyncParsableCommand {
      static let configuration: CommandConfiguration = .init(
        commandName: "install",
        abstract: "Install the git configuration."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      func run() async throws {
        try await CliContext(globals: globals, run: {
          @Dependency(\.cliMiddleware.git) var git
          try await git(.config(.install))
        })
        .run()
      }
      
    }
    
    struct Status: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        commandName: "status",
        abstract: "Print the git status of the dotfiles."
      )
      
      func run() async throws {
        try await CliContext {
          @Dependency(\.cliMiddleware.git) var git
          try await git(.status)
        }
        .run()
      }
    }
    
    struct Pull: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        commandName: "pull",
        abstract: "Pull dotfiles repository."
      )
      
      func run() async throws {
        try await CliContext {
          @Dependency(\.cliMiddleware.git) var git
          try await git(.pull)
        }
        .run()
      }
    }
    
    struct Push: AsyncParsableCommand {
      static let configuration = CommandConfiguration(
        commandName: "push",
        abstract: "Push dotfiles repository."
      )
      
      func run() async throws {
        try await CliContext {
          @Dependency(\.cliMiddleware.git) var git
          try await git(.push)
        }
        .run()
      }
    }
    
    struct UninstallConfig: AsyncParsableCommand {
      static let configuration: CommandConfiguration = .init(
        commandName: "uninstall",
        abstract: "Uninstall the git configuration."
      )
      
      @OptionGroup var globals: GlobalOptions
      
      func run() async throws {
        try await CliContext(globals: globals, run: {
          @Dependency(\.cliMiddleware.git) var git
          try await git(.config(.uninstall))
        })
        .run()
      }
      
    }
  }
}
