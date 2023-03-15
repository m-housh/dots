import ArgumentParser

@main
struct Dots: AsyncParsableCommand  {
  static var configuration = CommandConfiguration(
    abstract: "Commands for installing / uninstalling dotfile configuration.",
    version: VERSION,
    subcommands: [
      Brew.self,
      Espanso.self,
      Git.Commit.self,
      Git.self,
      Install.self,
      Iterm.self,
      Nvim.self,
      Scripts.self,
      Tmux.self,
      Git.Status.self,
      Git.Pull.self,
      Git.Push.self,
      Vim.self,
      Zsh.self
    ]
  )
}
