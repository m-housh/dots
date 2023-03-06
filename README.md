# dots

A command-line application to manage my dotfiles.

## Installation

You can install the application with `brew`.

First you must use brew to clone the custom tap.

```bash
brew tap m-housh/formula
```

Then you can install the application using the following command.

```bash
brew install dots
```

## Usage

See the documentation / command reference by issuing the following command.

```bash
dots --help
```

The installation commands expect the dotfiles to be located at
`~/.dotfiles`.  You can install the dotfiles by cloning the repository.

```bash
git clone https://github.com/m-housh/dotfiles.git ~/.dotfiles
```

If setting up a new machine, then you can run one of the following commands.

> Note: This expects homebrew to be setup, if it is not then it is best
> to install from the `~/.dotfiles` using the `make bootstrap` or `make bootstrap-minimal`
> commands in that repository.

### Minimal install

This installs the homebrew formulas, and links the configuration files for git, tmux, vim, and zsh.  It also
links the custom scripts directory.

```bash
dots install --minimal
```

### Full installation

This installs everything in the minimal, plus applications managed by `brew cask` as well
as applications from the App Store.  It will also link configuration files for setting up
`espanso`, `iterm2`, `neo-vim`. This will require you to be logged in to the App Store or 
it will fail.

```bash
dots install --full
```

## Managing Dotfile

You can also manage the dotfile after installation with the `git` subcommands.
These are convenient wrappers around normal git commands and will work even if you
are not located in the `~/.dotfiles` directory.

### Status

Show the git status.

```bash
dots git status
```
### Add a file(s)

```bash
dots git add file1.txt file2.txt
```

Or calling without any files is the same as `git add --all`.
```bash
dots git add
```

### Commit files
```bash
dots git commit "My commit message"
```

### Push
```bash
dots git push
```

### Pull
```bash
dots git pull
```

## Uninstalling configuration

All of the sub-commands, except for `brew` have an `uninstall` command
which will remove any symlinks for configuration files, but it will not
remove them from the `~/.dotfiles` directory.
