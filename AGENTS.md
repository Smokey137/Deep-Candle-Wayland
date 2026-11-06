# Deep Candle Wayland — notes for AI agents

The owner's desktop, Deep Candle, on Wayland: river + rhine instead of X + bspwm, waybar
instead of polybar. It stands alone. It was copied on 2026-11-06 from Deep Candle
(github.com/Smokey137/Deep-Candle, a separate private repo, X only): the theme, fonts,
wallpaper, shell and scripts, without single apps' settings. `README.md` explains every part.

- `home/` maps to `~`; `fonts/`, `wallpaper/`, `dconf/` as `./install` says. `./install` keeps
  `.bak-` files and has `--dry-run`.
- The shared files are copies of Deep Candle's. A fix to a shared script may belong in both repos:
  say so to the owner.
- Single apps' settings (Brave, qBittorrent, calibre, Geany, mpd, ...) stay out of this repo:
  the owner chose that.
- The bar scripts print polybar's tags; `home/.local/bin/bar-markup` turns them into waybar's.
  Keep using it rather than rewriting the scripts. `~/.config/polybar-mine/colors.ini` stays
  under that name: `palette` and the scripts read it.
- rhine reads `home/.config/river/config.rh`. A `#` anywhere on a line starts a comment, so no
  `#` inside a command. A `*` in a rule matches one or more letters, never none.
- **Privacy**: no home city, hostname, Wi-Fi names, e-mail addresses. The weather city is the
  example one, London.
- **Private, not public**: `fonts/mass-driver/` is a paid font, `wallpaper/` isn't ours to
  share. Remove both before this repo could ever be made public.
- **Commits** carry the owner's GitHub noreply address, never their real e-mail.
- **Talking to the owner**: short, plain sentences and small ASCII pictures; English is likely not
  their first language. One idea at a time.
