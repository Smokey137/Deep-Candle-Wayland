# Deep Candle Hyprland — notes for AI agents

The desktop part of the owner's Deep Candle (github.com/Smokey137/Deep-Candle, a separate
private repo, X only), on Wayland with Hyprland. `README.md` explains every part. Until
2026-11-09 this repo was a river + rhine port; that is gone, on the owner's word.

- **Scope, set by the owner: only four things.** The window manager and its keys (Hyprland),
  the bar (waybar), the launcher and menus (fuzzel), the wallpaper (swaybg). Plus the fonts and
  scripts those four need. **No apps and no app settings**: no terminal, shell, GTK or Qt
  theme, notification daemon, file manager, editor ... Never add them, nor packages for them
  outside `packages.txt`'s `[optional]`. A key that starts an app is a key, not an app setting.
  Ask before adding anything outside the four.
- `home/` maps to `~`; `fonts/`, `wallpaper/` as `./install` says. `./install` keeps `.bak-`
  files and has `--dry-run`.
- **`home/.config/hypr/hyprland.lua` is the window manager**: Hyprland's Lua config (0.57 reads
  nothing else). What Deep Candle's bspwm scripts do (`win`, `desktops`, `goto`,
  `app-desktops`) is Lua functions there, not shell scripts. When Deep Candle's `sxhkdrc` or
  `bspwmrc` changes, port the change into this one file.
  - Hyprland's API changes with every release. Check each name against its manual
    (wiki.hypr.land, or the repo github.com/hyprwm/hyprland-wiki) and, when in doubt, the
    source (`src/config/lua/bindings/` in github.com/hyprwm/Hyprland) at the installed version.
    Don't write it from memory.
  - It is Lua 5.5: a `for` loop's variable can't be assigned to.
  - A key's function runs inside Hyprland: nothing slow in it (no `io.popen`, no waiting).
    Start programs with `hl.exec_cmd` / `hl.dsp.exec_cmd`.
  - A dispatcher that fails at "error" level puts a notice on the screen. Send a layout message
    only to a desktop in that layout (`ws.tiled_layout`).
  - Every key goes through `key(KEYS, WORDS, WHAT)`: WORDS is its line in the Super+/ list and
    the quick guide. Keep sxhkdrc's order and parts.
- **Not yet run on a real Hyprland** (README, "Not tried yet"). When the owner reports what
  works and what doesn't, fix it and shorten that list.
- The bar scripts are copies of Deep Candle's. They print polybar's tags;
  `home/.local/bin/bar-markup` turns them into waybar's. Keep using it rather than rewriting the
  scripts. `~/.config/polybar-mine/colors.ini` keeps that name: `palette` and the scripts read it.
  A fix to a shared script may belong in Deep Candle too: say so to the owner.
- Menus are fuzzel's (`--dmenu`), never rofi's. fuzzel does lists only, no text panels.
- **Privacy**: no home city, hostname, Wi-Fi names, e-mail addresses. The weather city is the
  example one, London.
- **Private, not public**: `fonts/mass-driver/` is a paid font, `wallpaper/` isn't ours to
  share. Neither may be in a public repo. (On 2026-11-09 this repo was public with both in it:
  the owner was told.)
- **Commits** carry the owner's GitHub noreply address, never their real e-mail.
- **Talking to the owner**: short, plain sentences and small ASCII pictures; English is likely not
  their first language. One idea at a time.
