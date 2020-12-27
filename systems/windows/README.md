# alacritty.yml

Use Link Shell Extension to symlink `alacritty.yml` to
`C:\Users\andre\AppData\Roaming\alacritty\alacritty.yml`

# andred.ahk

Use Link Shell Extension to symlink `andred.ahk` to `D:\` and then
create a shortcut to that in `Win+R shell:startup`.

# tarsnap.conf / tarsnap-backup.sh

`ln -s /home/andre/.dotfiles/systems/windows/tarsnap.conf /etc/`

Add the following crontab entry

`0 5 * * 1 /home/andre/.dotfiles/systems/windows/tarsnap-backup.sh`
