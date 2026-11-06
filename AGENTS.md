# Deep Candle Wayland — notes for AI agents

The desktop part of the owner's Deep Candle (github.com/Smokey137/Deep-Candle, a separate
private repo, X only), on Wayland. `README.md` explains every part.

- **Scope, set by the owner: only four things.** The window manager and its keys (rhine on
  river), the bar (waybar), the launcher and menus (fuzzel), the wallpaper (swaybg). Plus the
  fonts and scripts those four need. **No apps and no app settings**: no terminal, shell, GTK or
  Qt theme, notification daemon, file manager, editor ... Never add them, nor packages for them
  outside `packages.txt`'s `[optional]`. Ask before adding anything outside the four.
- `home/` maps to `~`; `fonts/`, `wallpaper/` as `./install` says. `./install` keeps `.bak-`
  files and has `--dry-run`.
- The bar scripts are copies of Deep Candle's. They print polybar's tags;
  `home/.local/bin/bar-markup` turns them into waybar's. Keep using it rather than rewriting the
  scripts. `~/.config/polybar-mine/colors.ini` keeps that name: `palette` and the scripts read it.
  A fix to a shared script may belong in Deep Candle too: say so to the owner.
- Menus are fuzzel's (`--dmenu`), never rofi's. fuzzel does lists only, no text panels.
- rhine reads `home/.config/river/config.rh`. A `#` anywhere on a line starts a comment, so no
  `#` inside a command. A `*` in a rule matches one or more letters, never none.
- **Privacy**: no home city, hostname, Wi-Fi names, e-mail addresses. The weather city is the
  example one, London.
- **Private, not public**: `fonts/mass-driver/` is a paid font, `wallpaper/` isn't ours to
  share. Remove both before this repo could ever be made public.
- **Commits** carry the owner's GitHub noreply address, never their real e-mail.
- **Talking to the owner**: short, plain sentences and small ASCII pictures; English is likely not
  their first language. One idea at a time.
