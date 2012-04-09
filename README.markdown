# Andre's dotfiles

Initially copied from [Zach Holman](http://github.com/holman/dotfiles), but 
substantially stripped down for my particular tastes. This used to also 
utilize oh-my-zsh, but I've found that I'd rather manage my entire 
configuration by myself, so this no longer requires that.

## Usage

Same steps as Holman's:

- `git clone git://github.com/apazzolini/dotfiles ~/.dotfiles`
- `cd ~/.dotfiles`
- `rake install`
- `chsh -s /bin/zsh` (make sure this path exists on your machine or you're gonna have a bad time)

The install rake task will symlink the appropriate files in `.dotfiles` to your
home directory. Everything is configured and tweaked within `~/.dotfiles`,
though.

The main file you'll want to change right off the bat is `zsh/zshrc.symlink`,
which sets up a few paths that'll be different on your particular machine.

## Items of note <Section blatantly ripped off>

There's a few special files in the hierarchy.

- **bin/**: Anything in `bin/` will get added to your `$PATH` and be made
  available everywhere.
- **topic/\*.zsh**: Any files ending in `.zsh` get loaded into your
  environment.
- **topic/\*.symlink**: Any files ending in `*.symlink` get symlinked into
  your `$HOME`. This is so you can keep all of those versioned in your dotfiles
  but still keep those autoloaded files in your home directory. These get
  symlinked in when you run `rake install`.
- **topic/\*.completion.sh**: Any files ending in `completion.sh` get loaded
  last so that they get loaded after we set up zsh autocomplete functions.

## Credit

Thanks to [Zach Holman](http://github.com/holman/dotfiles). Seriously, go check
out his repository and theory on dotfiles. I agree with all of it, and would
never have created this without seeing his first.
