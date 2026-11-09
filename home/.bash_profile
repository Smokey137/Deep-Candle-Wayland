# bash's login file: your ~/.bashrc, as usual, then the same as ~/.zprofile does for zsh
[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
export PATH="$HOME/.local/bin:$PATH"

# Hyprland: the Wayland session on tty1 right after logging in there (ending it logs out).
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = /dev/tty1 ]; then
  exec "$HOME/.local/bin/hyprland-session"
fi
