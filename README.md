# Deep Candle Wayland

The desktop part of [Deep Candle](https://github.com/Smokey137/Deep-Candle), on Wayland.
Four things, nothing else:

```
 Deep Candle (X)                 here (Wayland)
 ───────────────                 ──────────────
 bspwm + sxhkd           ──▶     rhine on river      the window manager and its keys
 polybar                 ──▶     waybar              the bar: same pieces, same colours
 rofi                    ──▶     fuzzel              the launcher and the menus
 feh + the picture       ──▶     swaybg + the picture
```

No apps and no app settings: no terminal config, no shell, no GTK or Qt theme, no
notifications. Your apps keep their own settings. Super+Return opens `$TERMINAL` (foot, unless
you set another).

Made on 6 Nov 2026 from Deep Candle of that day, for rhine 0.5.0, river 0.5.0 and fuzzel
1.12, on Artix (runit). Not yet used as a daily desktop: read "Not ported" first.

## What's in it

```
 home/        -> ~                          rhine, the bar, the launcher, their scripts
 fonts/       -> ~/.local/share/fonts/      the bar's: Mass Driver IO (text), Iosevka Nerd Font (icons)
 wallpaper/   -> ~/Pictures/Wallpapers/     and ~/.wallpaper points to it
```

| part | files under `home/` |
|---|---|
| start | `.zprofile` (zsh) or `.bash_profile` (bash): on tty1, `.local/bin/rhine-session` |
| window manager | `.config/river/config.rh`: borders, rules, keys, mouse, what starts |
| bar | `.config/waybar/config.jsonc`, `style.css`; `.local/bin/bar`, `bar-markup`; the scripts of its pieces (`ram`, `disk`, `netspeed`, `hours`, `planhour`, `weather`, `music`, `volume`, `mic`, `netbar`); `.config/polybar-mine/colors.ini`, the palette they read (`palette`) |
| launcher, menus | `.config/fuzzel/fuzzel.ini`; `.local/bin/launcher`, `runner`, `powermenu`, `sound`, `network`, `keys` |
| what the keys run | `.local/bin/screenshot`, `ob-colorpicker`, `brightness`, `volume`, `music`, `osd` |
| sound | `.local/bin/sound-server`: starts PipeWire, wireplumber and pipewire-pulse (Artix has no systemd to do it) |

Mass Driver is a paid font: it must not go public with this repo.

## Install (on a fresh Artix)

1. Programs: `packages.txt`, section `[pacman]`. `[optional]` lists extras (Wi-Fi menu,
   notices, mpd); none is needed to start.
2. Build rhine (it is not packaged). As yourself, not root:
   ```
   git clone https://codeberg.org/Sivecano/rhine.git
   cd rhine
   git checkout "$(git describe --tags --abbrev=0)"
   zig build -Ddbus=false -fno-sys=river-protocols -Doptimize=ReleaseSafe
   sudo cp -r zig-out/. /usr/local/
   ```
   The newest release tag, not `main`: `main` changes the config words now and then.
3. This repo: `cd ~/Deep-Candle-Wayland && ./install`. Every file it changes is kept first as
   `<file>.bak-YYYYMMDD`; `--dry-run` shows what would change.
4. Once, for the brightness keys: `sudo usermod -aG video $USER`.
5. Log out, log in on tty1.

## How the session starts

```
 tty1 "login:"
   ▼
 your shell reads ~/.zprofile or ~/.bash_profile ── on tty1 ──▶ ~/.local/bin/rhine-session
   ▼
 rhine-session: the Wayland environment, TERMINAL, then
   dbus-run-session river -c rhine        → ~/.local/share/river/session.log
   ▼
 rhine reads ~/.config/river/config.rh, then starts: sound-server (PipeWire), swaybg (the
   wallpaper), the bar
```

`river` is the compositor (by Isaac Freund); `rhine` is the window manager on it (by
Sivecano, codeberg.org/Sivecano/rhine). Log out (power menu, or Ctrl+Alt+Delete): rhine ends,
river ends, you are back at `login:`.

## Keys

`~/.config/river/config.rh`, block `keybinds`. Super+/ lists them all. rhine reads the file
again every time you save it. Most are bspwm's; what is different:

| key | bspwm | rhine |
|---|---|---|
| Super+Space | the desktop menu | the launcher (fuzzel) |
| Super+Return, Ctrl+Alt+T | kitty | `$TERMINAL` |
| Super+Shift+R | restart bspwm | a fresh bar (rhine needs no restart) |
| Alt+Tab | a list, most recent first | the next window on this workspace |
| Super+Tab | the window used last | the workspace used before |
| Ctrl+Alt+←/→ | next / previous desktop | next / previous workspace that has windows |
| Super+Ctrl+arrows | move the edge between windows | resize the window (its right / bottom edge) |
| Super+Alt+arrows | nudge a floating window | the same; a tiled one swaps places |
| Alt+F6 | maximize | fullscreen |
| Alt+F11 | always on top | a floating window stays above the others |
| Super+Shift+Q | force-close | ask the app to end (SIGTERM) |
| Super+= / Super+- | add / remove a desktop | not needed: workspaces come and go by themselves |
| app keys (Super+F, W, E, Ctrl+Alt+V, R, H, M ...) | apps | gone: add yours in config.rh |

Workspaces: rhine counts from 0, the keys and the bar from 1 (waybar shows rhine's "id", the
number + 1). Empty workspaces you are not on disappear.

## The bar

polybar's pieces, in the same order, one pill per group:

```
 [ 1 2 3 ] [ cpu temp ram disk net ]   [ date time planet weather ]   [ music ] [ vol mic light net bat ] tray [ ⏻ ]
```

- The pieces run the same scripts as on X. They print polybar's colour tags;
  `bar-markup` turns those into waybar's, line by line.
- Clicks: volume (click mute, wheel, right click: outputs), mic (the same, inputs), music
  (click play/pause, wheel skips), network (the Wi-Fi menu), weather (right click: fetch now),
  netspeed (numbers or arrows), power (the power menu).
- The date, time, planet and weather only show: their X popups were text panels, and fuzzel
  does menus only.
- The weather city: `HOME_LAT`, `HOME_LON`, `HOME_NAME` at the top of `~/.local/bin/weather`
  (London as given).

## The launcher and menus

fuzzel (by Daniel Eklöf, codeberg.org/dnkl/fuzzel), in Deep Candle's colours
(`~/.config/fuzzel/fuzzel.ini`, from rofi's `warm.rasi`):

| what | key / click | script |
|---|---|---|
| apps | Super+Space, Alt+F1 | `launcher` |
| run a command (apps and everything in PATH) | Super+R | `runner` |
| power: suspend, logout, reboot, shutdown | Super+X, the bar's ⏻ | `powermenu` (loginctl, elogind) |
| sound output / input | right click on the bar's speaker / mic | `sound` (pactl) |
| Wi-Fi | click on the bar's network piece | `network` (needs NetworkManager: optional) |
| the key list | Super+/ | `keys` |
| screenshot | Super+S, Print keys | `screenshot` (grim, slurp; swappy if there) |

## Not ported

They need X, bspwm or rofi's panels, or they are apps:

- the desktop menu, the window menu and list, super-peek, alt-tab's list
- the calendar, the hours and the forecast popups (text panels)
- clip (clipboard history), night (night light), notes, the music card, the wallpaper picker
- a second screen (screens, srandrd): `kanshi` does it on Wayland
- border-colour, key chains (Super+Alt+M / R), ksuperkey's Super tap
- hide, shade, border on / off, sticky, always below, "same sizes", corner and numpad snaps:
  rhine has no such commands yet

## When it goes wrong

| check | command |
|---|---|
| river's and rhine's errors | `tail -n 40 ~/.local/share/river/session.log` |
| the bar's errors | `cat $XDG_RUNTIME_DIR/waybar.log` |
| black screen in a VM | 3D on (virt-manager: Video Virtio + 3D, Display Spice + OpenGL), or start it with `WLR_RENDERER=pixman` |
| a key does nothing | the log names a line it could not read; `rhinectl rhine <command>` tries one by hand |
| the bar has no workspaces | waybar must be started by rhine (login, or Super+Shift+R): only rhine's children know its socket |
