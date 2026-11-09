# Deep Candle Hyprland

The desktop part of [Deep Candle](https://github.com/Smokey137/Deep-Candle), on Wayland with
Hyprland. Four things, nothing else:

```
 Deep Candle (X)                    here (Wayland)
 ───────────────                    ──────────────
 bspwm + sxhkd + its scripts ──▶    Hyprland     the window manager and its keys: one file
 polybar                     ──▶    waybar       the bar: same pieces, same colours
 rofi                        ──▶    fuzzel       the launcher and the menus
 feh + the picture           ──▶    swaybg + the picture
```

No apps and no app settings: no terminal config, no shell, no GTK or Qt theme, no
notifications. Your apps keep their own settings. The keys start the same apps as in Deep
Candle (Brave, Geany, PCManFM-Qt ...); a key for an app you don't have does nothing.

Made on 9 Nov 2026 from Deep Candle of that day, for Hyprland 0.57 (the newest then: 0.57.2).
It took the place of this repo's river + rhine version.

**Not yet run on a real Hyprland.** It was written from Hyprland's own manual and source, and
its settings file was run against a stand-in for Hyprland that knows Hyprland's real names. That
finds typing mistakes. It cannot show how the real thing behaves. Read "Not tried yet" before
the first login.

## What's in it

```
 home/        -> ~                          Hyprland's settings, the bar, the launcher, their scripts
 fonts/       -> ~/.local/share/fonts/      the bar's: Mass Driver IO (text), Iosevka Nerd Font (icons)
 wallpaper/   -> ~/Pictures/Wallpapers/     and ~/.wallpaper points to it
```

| part | files under `home/` |
|---|---|
| start | `.zprofile` (zsh) or `.bash_profile` (bash): on tty1, `.local/bin/hyprland-session` |
| window manager | `.config/hypr/hyprland.lua`: the look, rules, keys, mouse, what starts. `.config/hypr/readme.txt`: the quick guide's page |
| bar | `.config/waybar/config.jsonc`, `style.css`; `.local/bin/bar`, `bar-markup`; the scripts of its pieces (`ram`, `disk`, `netspeed`, `hours`, `planhour`, `weather`, `music`, `volume`, `mic`, `netbar`); `.config/polybar-mine/colors.ini`, the palette they read (`palette`) |
| launcher, menus | `.config/fuzzel/fuzzel.ini`; `.local/bin/launcher`, `powermenu`, `winmenu`, `sound`, `network`, `keys` |
| what the keys run | `.local/bin/term`, `guide`, `screenshot`, `brightness`, `volume`, `music`, `osd` |
| sound | `.local/bin/sound-server`: starts PipeWire where there is no systemd to do it (Artix) |

Mass Driver is a paid font, and the wallpaper is not ours to share: neither may be public.

## Install (Arch or Artix)

1. Programs: `packages.txt`, section `[pacman]`. `[optional]` lists extras (a terminal, Wi-Fi
   menu, notices ...); none is needed to start, but with no terminal Super+Enter does nothing.
2. Hyprland must be **0.57 or later**: `pacman -Q hyprland`. Older than 0.55 cannot read
   `hyprland.lua` at all.
3. This repo: `cd ~/Deep-Candle-Hyprland && ./install`. Every file it changes is kept first as
   `<file>.bak-YYYYMMDD`; `--dry-run` shows what would change.
4. Once, for the brightness keys: `sudo usermod -aG video $USER`.
5. Log out, log in on tty1.

In a virtual machine Hyprland needs 3D: virt-manager: Video Virtio with 3D on, Display Spice
with OpenGL on. Hyprland's manual: without it, it will not work.

## How the session starts

```
 tty1 "login:"
   ▼
 your shell reads ~/.zprofile or ~/.bash_profile ── on tty1 ──▶ ~/.local/bin/hyprland-session
   ▼
 hyprland-session: a D-Bus session bus if there is none (Artix), then
   start-hyprland                         → ~/.local/share/hyprland/session.log
   ▼
 Hyprland reads ~/.config/hypr/hyprland.lua, then starts: sound-server (PipeWire, where
   systemd doesn't), swaybg (the wallpaper), the bar
```

Hyprland is by Vaxry (github.com/hyprwm/Hyprland). It is the compositor and the window manager
in one program; `hyprctl` talks to it from a terminal. Log out (power menu, or
Ctrl+Alt+Delete): Hyprland ends, and you are back at `login:`.

## One file

`~/.config/hypr/hyprland.lua` is everything bspwm's `bspwmrc`, `sxhkdrc` and `scripts/` were.
It is a Lua program, read from top to bottom:

```
 environment → screens → the look → mouse → tiling → rules → what the keys do → the keys
                                                                    → what starts
```

Hyprland reads it again each time you save it. A mistake in it: a red box on the screen names
the line.

## Keys

Super+/ lists them all. Super+R opens the quick guide. They are Deep Candle's keys of
2026-11-09; these differ:

| key | bspwm | Hyprland |
|---|---|---|
| Super+T, Super+Shift+T | puts the windows in a master layout once | the desktop **stays** in the master layout: a new window joins the column. The same key again: plain tiling |
| Super+M | this window becomes the master; the old one goes first in the column | this window and the master swap places |
| Super+B | all windows the same size | the two halves of this split the same size (master layout: 60 / 40 again) |
| Super+Ctrl+R | rotate this split | the same (master layout: master left ⇄ top) |
| Alt+Tab | a list while Alt is held, most recent first | the next window on this desktop |
| Super+Num 5 | monocle | maximize: the whole desktop, gaps and bar kept |
| Super+Shift+Enter | a kitty kept hidden | a terminal on a desktop of its own, shown over the one you are on |
| Super+Enter | kitty | `$TERMINAL` if you set it, else kitty, else foot (`~/.local/bin/term`) |
| Super+Shift+R | restart bspwm | read the settings again, a fresh bar |
| Ctrl+Alt+Space | the apps menu | the launcher |
| Super+N, Super+V | notes, clipboard history | no key: not ported |
| tap Super | the launcher (ksuperkey) | the launcher (Hyprland's own) |

Desktops: Hyprland makes a desktop when you go to it and drops it when it is empty and you
leave. So the bar shows the desktops with windows and the one you are on, as in Deep Candle.

Apps with their own desktop, as in Deep Candle:

```
 1 2 3 4 5 6 7 8 9
 │ │ │ │     │ │ └ YouTube, Spotify   Super+Y, Super+S
 │ │ │ │     │ └ Discord              Super+D
 │ │ │ │     └ Dino                   Super+I
 │ │ │ └ Claude                       Super+C
 │ │ └ calibre (the library)          Super+L
 └─┴ Brave                            Super+W   (the first window on 1, a second one on 2)
```

The key goes to the app. Pressed again: the app's next window. Not open: the app starts, on its
desktop, and you go with it.

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
| apps | tap Super, Alt+F1, Ctrl+Alt+Space | `launcher` |
| this window: float, fullscreen, maximize, on every desktop, send to a desktop, close | Alt+Space | `winmenu` |
| power: suspend, logout, reboot, shutdown | Super+X, the bar's ⏻ | `powermenu` (loginctl: systemd's or elogind's) |
| sound output / input | right click on the bar's speaker / mic | `sound` (pactl) |
| Wi-Fi | click on the bar's network piece | `network` (needs NetworkManager: optional) |
| the key list | Super+/ | `keys` |
| screenshot | PrtSc, Ctrl+PrtSc, Super+PrtSc | `screenshot` (grim, slurp; swappy if there) |

No key floats a window (as in Deep Candle): the window menu does.

## Not ported

They need X, bspwm or rofi's panels, or they are apps:

- the desktop's clicks: the main menu (right click), the list of all windows (middle click),
  Alt+wheel for the next desktop
- super-peek (hold Super), Alt+Tab's list
- the calendar, the hours and the forecast popups (text panels)
- clip (clipboard history), night (night light), notes, the music card, the wallpaper picker,
  the colour picker
- a second screen with desktop 6 on it: one `hl.monitor` and one `hl.workspace_rule` line with
  that screen's name do it (`hyprctl monitors` names it)
- from the window menu: always on top / on bottom, hide, border on / off
- border-colour (the border's colours are two lines in `hyprland.lua`, under "Look")
- picom's see-through apps: an app's look is not part of this repo

## Not tried yet

Nothing here has run on a real Hyprland. These are the places most likely to be wrong, in the
order to look at them:

1. **It starts at all.** On Artix (runit, no systemd) Hyprland needs a seat: elogind or seatd
   running. Not checked: whether Artix's own Hyprland is 0.57 yet.
2. **The classes of the apps with their own desktop.** `hyprctl clients` shows each window's
   class. Brave's web apps are told apart by `brave-<id>-Default`, which Brave gives only as a
   Wayland window. Under Xwayland they all say `Brave-browser`, and Super+Y / S / D / C would
   start a new one each time. Dino and calibre: `im.dino.Dino` or `dino`, `calibre-gui`. A
   different class: change it in `hyprland.lua`, at `APPS`.
3. **Tap Super.** If the launcher also opens after Super+Q and the like, delete the two
   `Super_L` / `Super_R` lines.
4. **Super+T, Super+M.** They change a desktop's layout while Hyprland runs. If nothing
   happens, say so.
5. **The numpad keys** are bound by key number (`code:83` ...). `wev` shows a key's number.
6. **The keyboard layout** is Hyprland's default, `us`. Another: `kb_layout` in `hyprland.lua`,
   under "Mouse and keyboard".

## When it goes wrong

| check | command |
|---|---|
| mistakes in `hyprland.lua` | a red box on the screen; `hyprctl configerrors` |
| what Hyprland said at start | `tail -n 40 ~/.local/share/hyprland/session.log` |
| Hyprland's own log | `hyprctl rollinglog`, or `$XDG_RUNTIME_DIR/hypr/*/hyprland.log` |
| the bar's errors | `cat $XDG_RUNTIME_DIR/waybar.log` |
| black screen in a VM | 3D on (virt-manager: Video Virtio + 3D, Display Spice + OpenGL) |
| a key does nothing | `hyprctl binds` lists what is bound; `wev` shows what a key is called |
| a window's class | `hyprctl clients` |
| no keys at all | Ctrl+Alt+F2: a text login. Repair `~/.config/hypr/hyprland.lua` there, or put back `hyprland.lua.bak-DATE` |
