export PATH="$HOME/.local/bin:$PATH"

# Hyprland: the Wayland session on tty1 right after logging in there (ending it logs out).
# ~/.local/bin/hyprland-session starts it. The other ttys stay plain text logins, for repairs.
# (zsh reads this file; bash reads ~/.bash_profile.)
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = /dev/tty1 ]; then
  exec "$HOME/.local/bin/hyprland-session"
fi
