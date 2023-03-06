import ArgumentParser

@main
struct Dots: AsyncParsableCommand  {
  static var configuration = CommandConfiguration(
    abstract: "Commands for installing / uninstalling dotfile configuration.",
    version: VERSION ?? "0.0.0",
    subcommands: [
      Brew.self,
      Git.Commit.self,
      Git.self,
      Install.self,
      Iterm.self,
      Scripts.self,
      Git.Status.self,
      Git.Pull.self,
      Git.Push.self,
      Vim.self,
      Zsh.self
    ]
  )
}
