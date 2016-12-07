# Jeff Ahern's Dotfiles

This is a collection of dotfiles and scripts I use to my liking and setting up the software development tools I use on a day-to-day basis. They should be cloned to your home directory so that the path is `~/dotfiles/`.  The included setup script creates symlinks from your home directory to the files which are located in `~/dotfiles/`.

The setup script is smart enough to back up your existing dotfiles into a `~/dotfiles_old/` directory if you already have any dotfiles of the same name as the dotfile symlinks being created in your home directory.

I also prefer `zsh` as my shell of choice. As such, the setup script will also clone the `oh-my-zsh` repository from my GitHub. It then checks to see if `zsh` is installed. If `zsh` is installed, and it is not already configured as the default shell, the setup script will execute a `chsh -s $(which zsh)` command. This changes the default shell to zsh, and takes effect as soon as a new zsh is spawned or on next login.

So, to recap, the install script will:

- back up any existing dotfiles in your home directory to `~/dotfiles_old/`
- create symlinks to the dotfiles in `~/dotfiles/` in your home directory
- clone the `oh-my-zsh` repository from my GitHub (for use with `zsh`)
- check to see if `zsh` is installed, if it isn't, try to install it
- if zsh is installed, run a `chsh -s` to set it as the default shell

## Features

- Git aliases
- zsh aliases
- Custom zsh theme: [Arizona](zsh/themes/arizona.zsh-theme)
- [Install script](setup.sh)

## Installation

```sh
$ git clone https://github.com/jdahern/dotfiles.git ~/dotfiles
$ cd ~/dotfiles
$ chmod +x setup.sh
$ ./setup.sh
```

## Remotely install using curl

Alternatively, you can install this into `~/dotfiles` remotely without Git using curl:

```sh
sh -c "`curl -fsSL https://raw.github.com/jdahern/dotfiles/master/remote-setup.sh`"
```

Or, using wget:

```sh
sh -c "`wget -O - --no-check-certificate https://raw.githubusercontent.com/jdahern/dotfiles/master/remote-setup.sh`"
```

## Customize

### Local Settings

The dotfiles can be easily extended to suit additional local
requirements by using the following files:

#### `~/.zsh.local`

If the `~/.zsh.local` file exists, it will be automatically sourced
after all the other [shell related files](shell), thus, allowing its
content to add to or overwrite the existing aliases, settings, PATH,
etc.

#### `~/.gitconfig.local`

If the `~/.gitconfig.local` file exists, it will be automatically
included after the configurations from [`~/.gitconfig`](git/gitconfig), thus, allowing
its content to overwrite or add to the existing `git` configurations.

**Note:** Use `~/.gitconfig.local` to store sensitive information such
as the `git` user credentials, e.g.:

```sh
[user]
  name = Jeff Ahern
  email = jeff@example.com
```

## Resources

This repo is based off of [Nick Plekhanov's Dotfiles](https://github.com/nicksp/dotfiles)

## License

The code is available under the [MIT license](LICENSE).
