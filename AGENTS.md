# Deep Candle Wayland — notes for AI agents

The Wayland layer of the owner's desktop, Deep Candle (github.com/Smokey137/Deep-Candle, a
separate private repo). This repo holds only what Wayland changes: river + rhine instead of
X + bspwm, waybar instead of polybar, and a few scripts with a Wayland version. `README.md`
explains every part.

- `home/` maps to `~`. `./install` copies it over an installed Deep Candle (keeps `.bak-` files).
- The look and every other script live in Deep Candle, not here. Change them there: both
  desktops then get the change. Copy a Deep Candle script into `home/` only when it must differ
  on Wayland, and say so in its first lines.
- The bar scripts print polybar's tags; `home/.local/bin/bar-markup` turns them into waybar's.
  Keep using it rather than forking the scripts.
- rhine reads `home/.config/river/config.rh`. A `#` anywhere on a line starts a comment, so no
  `#` inside a command. A `*` in a rule matches one or more letters, never none.
- **Privacy**: as in Deep Candle: no home city, hostname, Wi-Fi names, e-mail addresses.
- **Commits** carry the owner's GitHub noreply address, never their real e-mail.
- **Talking to the owner**: short, plain sentences and small ASCII pictures; English is likely not
  their first language. One idea at a time.
