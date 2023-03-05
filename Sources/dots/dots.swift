import ArgumentParser

@main
struct Dots: AsyncParsableCommand  {
  static var configuration = CommandConfiguration(
    abstract: "Commands for installing / uninstalling dotfile configuration.",
    version: VERSION ?? "0.0.0",
    subcommands: [
      Brew.self,
      Zsh.self
    ]
  )
}
