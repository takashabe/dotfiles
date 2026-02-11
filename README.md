# dotfiles

## Setup

```
git clone https://github.com/takashabe/dotfiles
dotfiles/setup.sh
```

## Niri (Arch Linux)

```
sudo pacman -S niri waybar fcitx5-im fcitx5-mozc
# greetd
sudo mkdir -p /etc/greetd
sudo ln -sf $HOME/dotfiles/etc/greetd/config.toml /etc/greetd/config.toml
```

HyprlandはTTYから手動起動できます。niri起動時は`~/.config/niri/config.kdl`を参照します。
