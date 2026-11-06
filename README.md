# Deep Candle Wayland

[Deep Candle](https://github.com/Smokey137/Deep-Candle), the warm dark desktop, on Wayland:
**river** and **rhine** instead of X and bspwm, **waybar** instead of polybar. The same theme,
fonts, wallpaper, bar pieces, rofi menus and scripts; almost the same keys.

This repo stands alone: it needs nothing from Deep Candle. It has everything of Deep Candle's
desktop and look, but not the settings of single apps (see "What's in it").

Made on 6 Nov 2026 from Deep Candle of that day, for rhine 0.5.0 and river 0.5.0, on Artix
(runit). Not yet used as a daily desktop: read "Not ported" before you move to it.

## What's in it

```
 home/        -> ~        the session, the bar, the look, the shell, the scripts
 fonts/       -> ~/.local/share/fonts/      Iosevka and JetBrains Mono Nerd Fonts, Mass Driver
 wallpaper/   -> ~/Pictures/Wallpapers/     and ~/.wallpaper points to it
 dconf/       -> GTK's theme names          (GTK reads them there on Wayland)
 system/etc/environment                     Qt's colours (copy it by hand, with sudo)
```

| part | files under `home/` |
|---|---|
| the session | `.zprofile`, `.local/bin/rhine-session`, `.config/river/config.rh` |
| the bar | `.config/waybar/`, `.local/bin/bar`, `bar-markup` and the bar's scripts |
| GTK | `.themes/Deep-Candle/`, `.config/gtk-3.0/`, `.config/gtk-4.0/`, `.gtkrc-2.0`, `.local/share/gtksourceview-4/` |
| Qt | `.config/qt5ct/`, `.config/qt6ct/` |
| fonts, cursor | `.config/fontconfig/`, `.icons/default/index.theme` |
| terminal, shell | `.config/kitty/`, `.zshrc`, `.oh-my-zsh/custom/themes/archcraft.zsh-theme` |
| menus, notices | `.config/rofi/`, `.config/dunst/`, `.local/share/deep-candle/osd/` |
| screenshots | `.config/swappy/config` |
| the palette | `.config/polybar-mine/colors.ini`: the colours every bar script reads (`palette`); the name stays so the scripts need no change |
| scripts | `.local/bin/`: the bar's pieces, menus, sound, music, network, weather, the hours, notes, wallpaper, power, screenshots |

**Left out, on purpose** (single apps' settings): Brave and its tabs helper, Violentmonkey,
qBittorrent, calibre, Geany, Neovim, sioyek, zathura, Atril, nsxiv, PCManFM-Qt, Thunar, qps,
mpd, ncmpcpp, which app opens which file (`mimeapps.list`). Also the X-only parts: polybar's
modules, picom, bspwm, Openbox, xfsettingsd, `.Xresources`, flameshot, and the X-only scripts
(see "Not ported"). They stay in Deep Candle.

## Two programs instead of one

On X, bspwm did everything about windows. On Wayland it is split in two:

```
 river   the compositor: draws the screen, owns the keyboard and the mouse
   │     (by Isaac Freund; packaged: pacman -S river)
   │
   └── rhine   the window manager: places the windows, runs the keys
               (by Sivecano, codeberg.org/Sivecano/rhine; built from source)
```

They talk through a Wayland protocol. If rhine ever dies, another window manager for river can
take its place; river stays.

## How the session starts

```
 tty1 "login:"
   ▼
 zsh reads ~/.zprofile ── on tty1 ──▶ exec ~/.local/bin/rhine-session
   ▼
 rhine-session: Wayland environment, then
   dbus-run-session river -c rhine        → ~/.local/share/river/session.log
   ▼
 rhine reads ~/.config/river/config.rh, then runs its "startup" lines:
   dbus-update-activation-environment, swaybg (the wallpaper), dunst,
   ~/.local/bin/bar (waybar). Nothing else: add your apps there if you want them.
```

Log out (power menu → logout, or Ctrl+Alt+Delete): rhine ends, river ends, you are back at
`login:`. rhine stops what it started.

- `dbus-run-session` gives the session its D-Bus bus. Artix has no systemd to give one.
- The other ttys stay plain text logins, for repairs.

## Install (on a fresh Artix)

1. Programs: `packages.txt`, section `[pacman]`: only what the configs and scripts run.
   `[optional]` lists the extras (network piece, Qt apps, mpd, ...); none is needed to start.
2. Build rhine (it is not packaged). As yourself, not root:
   ```
   git clone https://codeberg.org/Sivecano/rhine.git
   cd rhine
   git checkout "$(git describe --tags --abbrev=0)"
   zig build -Ddbus=false -fno-sys=river-protocols -Doptimize=ReleaseSafe
   sudo cp -r zig-out/. /usr/local/
   ```
   - `-Ddbus=false`: rhine then needs no notification daemon at start.
   - The newest release tag, not `main`: `main` changes the config words now and then.
3. zsh and its prompt (before step 4: git won't clone into a folder that's there):
   ```
   chsh -s /bin/zsh
   git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
   ```
4. This repo:
   ```
   cd ~/Deep-Candle-Wayland && dbus-run-session ./install
   ```
   - `dbus-run-session`: the GTK theme's names go in through dconf, which needs a D-Bus bus
     (an SSH login has none). From inside the session, plain `./install` is enough.
   - Every file it changes is kept first as `<file>.bak-YYYYMMDD`. `--dry-run` shows what
     would change.
5. Once, with sudo: `sudo cp system/etc/environment /etc/environment` (Qt's colours) and
   `sudo usermod -aG video $USER` (the brightness keys).
6. Log out, log in on tty1.

## Keys

`~/.config/river/config.rh`, block `keybinds`. Super+/ shows them all (`~/.local/bin/keys`
reads the `#:` line over each key). rhine reads the file again every time you save it.

Most keys are bspwm's. What is different:

| key | bspwm | rhine |
|---|---|---|
| Super+Space | the desktop menu | the app launcher (the menu is an X program) |
| Super+Shift+R | restart bspwm | a fresh bar (rhine needs no restart) |
| Alt+Tab | a list, most recent first | the next window on this workspace |
| Super+Tab | the window used last | the workspace used before |
| Ctrl+Alt+←/→ | next / previous desktop | next / previous workspace that has windows |
| Super+1…9 | desktop 1-9; again: back | workspace 1-9 |
| Super+Ctrl+arrows | move the edge between windows | resize the window (its right / bottom edge) |
| Super+Alt+arrows | nudge a floating window | the same; a tiled one swaps places |
| Alt+F6 | maximize | fullscreen |
| Alt+F11 | always on top | a floating window stays above the others (rhine's "pin") |
| Super+Shift+Q | force-close | ask the app to end (SIGTERM) |
| Super+= / Super+- | add / remove a desktop | not needed: workspaces come and go by themselves |
| Super+V | clipboard history | — (not ported) |
| Super+N | notes window | — (Super+Alt+Shift+N still adds a line) |
| Ctrl+Alt+M | ncmpcpp with album art | ncmpcpp, plain (its settings are left out) |
| — | Change Wallpaper (desktop menu) | Super+Alt+W |

Workspaces: rhine counts from 0, the keys and the bar from 1. Super+1 is rhine's workspace 0;
waybar shows its "id", which is the number + 1. Empty workspaces you are not on disappear.

## The bar

`~/.config/waybar/config.jsonc` and `style.css`. `~/.local/bin/bar` starts it (again). Each
group is one pill; the pieces are polybar's, in the same order:

```
 [ 1 2 3 ] [ cpu temp ram disk net ]   [ date time planet weather notes ]   [ music ] [ vol mic light net bat ] tray [ ⏻ ]
```

| polybar module | waybar | notes |
|---|---|---|
| desktops | `hyprland/workspaces` | rhine speaks enough of Hyprland's language for it |
| cpu, temperature | `cpu`, `temperature` | waybar's own |
| memory, filesystem | `custom/ram`, `custom/disk` | the same scripts |
| netspeed, planet, weather, music, volume, mic, network | `custom/…` | the same scripts, through `bar-markup` |
| date | `clock#date`, `clock#time` | two pieces, so each keeps its own clicks |
| notes | `custom/notes` | a click adds a line (the window is X) |
| backlight, battery, systray | `backlight`, `battery`, `tray` | waybar's own |
| sysmenu | `custom/power` | the power menu |
| clip, night | — | not ported |

**bar-markup**: the bar scripts print polybar's tags (`%{F#9B59D0}`, `%{T3}`). waybar wants
Pango markup. `~/.local/bin/bar-markup` turns one into the other, line by line, so the very same
scripts serve both bars.

## The other pieces

| piece | on X | here |
|---|---|---|
| wallpaper | feh | swaybg, from `~/.wallpaper` |
| screenshots | flameshot | grim + slurp, then swappy to mark it up; without swappy (Artix has none) kept and copied as is (`~/.local/bin/screenshot`) |
| colour picker | xcolor | slurp + grim (`~/.local/bin/ob-colorpicker`) |
| main screen | xrandr | `/sys/class/drm` (`~/.local/bin/screen-main`): the rofi popups use it |
| power menu | systemctl, bspc | loginctl (elogind), `rhinectl rhine exit` |
| GTK theme | xfsettingsd | dconf (`./install` loads `dconf/desktop-interface.ini`) |
| wallpaper picker | feh | swaybg (`~/.local/bin/wallpaper`, Super+Alt+W) |
| notices | dunst | dunst (it does Wayland) |
| menus | rofi | rofi (2.0 does Wayland) |
| compositor | picom | none: river draws; kitty is still see-through by itself |

## Files made for Wayland

The rest of `home/` is Deep Candle's, as it was. These are new, or changed for Wayland:

| file | what |
|---|---|
| `home/.zprofile` | on tty1: `rhine-session` (Deep Candle's ran `startx`) |
| `home/.local/bin/rhine-session` | the environment, D-Bus, river with rhine |
| `home/.config/river/config.rh` | rhine: borders, rules, keys, mouse, what starts |
| `home/.config/waybar/config.jsonc` | the bar's pieces and their clicks |
| `home/.config/waybar/style.css` | the bar's look (colours from `colors.ini`) |
| `home/.local/bin/bar` | starts waybar (again); Deep Candle's started polybar |
| `home/.local/bin/bar-markup` | polybar tags → waybar markup |
| `home/.local/bin/keys` | Super+/: the key list |
| `home/.local/bin/screen-main` | the main screen's name, without X |
| `home/.local/bin/powermenu` | the power menu, for elogind and rhine |
| `home/.local/bin/screenshot` | screenshots with grim, slurp, swappy |
| `home/.local/bin/ob-colorpicker` | the colour picker |
| `home/.local/bin/wallpaper` | the picker: swaybg instead of feh (one line) |

**Keeping up with Deep Candle**: the shared files (the theme, the scripts) are copies. A change
made in Deep Candle reaches this repo only when you copy it here too.

## Not ported

These need X, or bspwm, and have no Wayland version yet. Their scripts are not in this repo:

- the **window menu** (Alt+Space) and the **window list** (Alt+Shift+Space)
- **super-peek** (hold Super), **alt-tab**'s list, the **desktop menu** and its right-click
- **clip**, the clipboard history (xclip, clipnotify): `wl-paste --watch` can replace them
- **night**, the night light (X gamma ramps): river can do it through `wlsunset`
- **notes-window**, **music-card** (they place themselves with X)
- **screens**, a second screen plugged in (srandrd): `kanshi` does this on Wayland
- **border-colour**, **chain-notice**, key chains (Super+Alt+M / R), ksuperkey's Super tap
- hide, shade, border on / off, sticky, always below, "same sizes" (Super+B), the corner and numpad snaps:
  rhine has no such commands yet

## When it goes wrong

| check | command |
|---|---|
| river's and rhine's errors | `tail -n 40 ~/.local/share/river/session.log` |
| the bar's errors | `cat $XDG_RUNTIME_DIR/waybar.log` |
| black screen in a VM | 3D on (virt-manager: Video Virtio + 3D, Display Spice + OpenGL), or start it with `WLR_RENDERER=pixman` |
| a key does nothing | the log names a line it could not read; `rhinectl rhine <command>` tries one by hand |
| the bar has no workspaces | waybar must be started by rhine (the bar, Super+Shift+R): only rhine's children know its socket |

## See also

Deep Candle's own pages (its `docs/`) explain the shared parts in full: `theme.md`,
`look-gtk-qt-fonts.md`, `bar.md`, `menus.md`, `sound.md`, `music.md`, `weather.md`,
`hours.md`, `terminal-and-shell.md`.
