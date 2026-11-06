export TERMINAL=kitty
export PATH="$HOME/.local/bin:$PATH"

# rhine: the Wayland session on tty1 right after logging in there (ending it logs out).
# ~/.local/bin/rhine-session sets it up and starts river with rhine. The other ttys stay
# plain text logins, for repairs.
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = /dev/tty1 ]; then
  exec "$HOME/.local/bin/rhine-session"
fi
