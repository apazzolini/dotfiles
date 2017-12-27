# Andre's dotfiles

My personal dotfiles.

## Usage

- Clone the repository into `~/.dotfiles`
- Run the `init.sh` script to link various files into the home directory
- Ensure zsh is installed and then `chsh -s /bin/zsh`

## Items of note

- `bin/`: The `bin` directory is added to your `PATH` variable
- `**/*.zsh`: Any files ending in `.zsh` get loaded into your environment
- `**/*.completion.sh`: Any files ending in `completion.sh` get loaded after zsh autocomplete
