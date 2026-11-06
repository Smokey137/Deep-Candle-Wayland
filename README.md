# Deep Candle Wayland

[Deep Candle](https://github.com/Smokey137/Deep-Candle) on Wayland: **river** and **rhine**
instead of X and bspwm, **waybar** instead of polybar. The same theme, the same bar pieces, the
same rofi menus, almost the same keys.

```
 Deep-Candle           the theme, fonts, rofi, dunst, kitty, the bar's scripts   (X: bspwm)
   └─ this repo        on top: the Wayland parts                               (river + rhine)
```

This repo holds only what Wayland changes. Deep Candle stays the one source of the look and
the scripts, so a change there reaches both.

Made on 6 Nov 2026 for rhine 0.5.0 and river 0.5.0, on Artix (runit). Not yet used as a daily
desktop: read "Not ported" before you move to it.

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
   dbus-update-activation-environment, gnome-keyring, swaybg (the wallpaper),
   xfce-polkit, dunst, ~/.local/bin/bar (waybar), mpd, pcmanfm-qt, keepassxc
```

Log out (power menu → logout, or Ctrl+Alt+Delete): rhine ends, river ends, you are back at
`login:`. rhine stops what it started.

- `dbus-run-session` gives the session its D-Bus bus. Artix has no systemd to give one.
- The other ttys stay plain text logins, for repairs.

## Install (on a fresh Artix)

1. Programs: Deep Candle's list (its `packages.txt`, section `[pacman]`), then this repo's:
   `sudo pacman -S --needed $(grep -v -e '^#' -e '^$' packages.txt)`
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
3. zsh as your login shell (`~/.zprofile` is zsh's): `chsh -s /bin/zsh`.
4. Deep Candle, then this, each from its own folder:
   ```
   cd ~/Deep-Candle          && dbus-run-session ./install bspwm
   cd ~/Deep-Candle-Wayland  && ./install
   ```
   - `dbus-run-session`: Deep Candle's install loads the GTK theme through dconf, which needs
     a D-Bus bus (an SSH login has none).
   - `bspwm`'s own files come along (`~/.config/bspwm`, `~/.xinitrc`). Nothing starts them.
   - Every file this repo changes is kept first as `<file>.bak-YYYYMMDD`. `--dry-run` shows
     what would change.
5. Log out, log in on tty1.

The Wi-Fi menu and the bar's network piece use NetworkManager (`nmcli`), as on Archcraft.
On Artix: `networkmanager` and `networkmanager-runit`, and no iwd or dhcpcd service beside it.

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
| screenshots | flameshot | grim + slurp, then swappy to mark it up (`~/.local/bin/screenshot`) |
| colour picker | xcolor | slurp + grim (`~/.local/bin/ob-colorpicker`) |
| main screen | xrandr | `/sys/class/drm` (`~/.local/bin/screen-main`): the rofi popups use it |
| power menu | systemctl, bspc | loginctl (elogind), `rhinectl rhine exit` |
| GTK theme | xfsettingsd | dconf (Deep Candle's `./install` loads `dconf/desktop-interface.ini`) |
| notices | dunst | dunst (it does Wayland) |
| menus | rofi | rofi (2.0 does Wayland) |
| compositor | picom | none: river draws; kitty is still see-through by itself |

## Files

| file | what |
|---|---|
| `home/.zprofile` | on tty1: `rhine-session` |
| `home/.local/bin/rhine-session` | the environment, D-Bus, river with rhine |
| `home/.config/river/config.rh` | rhine: borders, rules, keys, mouse, what starts |
| `home/.config/waybar/config.jsonc` | the bar's pieces and their clicks |
| `home/.config/waybar/style.css` | the bar's look (colours from `colors.ini`) |
| `home/.local/bin/bar` | starts waybar (again) |
| `home/.local/bin/bar-markup` | polybar tags → waybar markup |
| `home/.local/bin/keys` | Super+/: the key list |
| `home/.local/bin/screen-main` | the main screen's name, without X |
| `home/.local/bin/powermenu` | the power menu, for elogind and rhine |
| `home/.local/bin/screenshot` | screenshots with grim, slurp, swappy |
| `home/.local/bin/ob-colorpicker` | the colour picker |

Deep Candle's `./install` puts its files first; this repo's `./install` puts these over them,
so they replace the X versions of the same names.

## Not ported

These need X, or bspwm, and have no Wayland version yet:

- the **window menu** (Alt+Space) and the **window list** (Alt+Shift+Space)
- **super-peek** (hold Super), **alt-tab**'s list, the **desktop menu** and its right-click
- **clip**, the clipboard history (xclip, clipnotify): `wl-paste --watch` can replace them
- **night**, the night light (X gamma ramps): river can do it through `wlsunset`
- **notes-window**, **music-card** (they place themselves with X)
- **screens**, a second screen plugged in (srandrd): `kanshi` does this on Wayland
- **border-colour**, **chain-notice**, key chains (Super+Alt+M / R), ksuperkey's Super tap
- hide, shade, border on / off, sticky, always below, "same sizes" (Super+B), the corner and numpad snaps:
  rhine has no such commands yet
- the wallpaper picker (`wallpaper`) still calls feh; `~/.wallpaper` is shown by swaybg at login

## When it goes wrong

| check | command |
|---|---|
| river's and rhine's errors | `tail -n 40 ~/.local/share/river/session.log` |
| the bar's errors | `cat $XDG_RUNTIME_DIR/waybar.log` |
| black screen in a VM | 3D on (virt-manager: Video Virtio + 3D, Display Spice + OpenGL), or start it with `WLR_RENDERER=pixman` |
| a key does nothing | the log names a line it could not read; `rhinectl rhine <command>` tries one by hand |
| the bar has no workspaces | waybar must be started by rhine (the bar, Super+Shift+R): only rhine's children know its socket |

## See also

Deep Candle's own pages (its `docs/`): `bspwm.md`, `keys.md`, `bar.md`, `menus.md`,
`screenshot.md`, `theme.md`, `how-it-fits-together.md`.
