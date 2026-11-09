■ DEEP CANDLE on Hyprland · quick guide
  q = close     ↑ ↓ or the wheel = scroll     Super + R = open / close

■ THE BAR, left to right
  ┌────────────────────┬────────────────────┬──────────────────────────┐
  │ desktops 1 2 3     │ date · clock       │ music                    │
  │ cpu · heat         │ planet of the hour │ sound · mic              │
  │ memory · disk      │ weather            │ brightness               │
  │ network speed      │                    │ network · battery · ⏻    │
  └────────────────────┴────────────────────┴──────────────────────────┘
  Click sound or mic: on / off (right click: pick the output / input; the wheel: louder,
  quieter). Click network: the Wi-Fi menu. Click ⏻: the power menu.

■ HOW WINDOWS SIT
  New windows share the screen. They never cover each other.
   one window       two windows      three windows
  ┌───────────┐   ┌─────┬─────┐    ┌─────┬─────┐
  │   kitty   │   │kitty│Brave│    │kitty│Brave│
  │           │   │     │     │    │     ├─────┤
  │           │   │     │     │    │     │ new │
  └───────────┘   └─────┴─────┘    └─────┴─────┘
  Small tools (settings, calculator) sit on top, in the middle.

■ APPS WITH THEIR OWN DESKTOP        they open there, and you go with them
  desktop   app                 key: go to it, or open it
  1 and 2   Brave ............. Super + W   (on 1: the one on 2)
  3         calibre ........... Super + L
  4         Claude ............ Super + C
  7         Dino .............. Super + I
  8         Discord ........... Super + D
  9         YouTube ........... Super + Y
  9         Spotify ........... Super + S
  The bar shows only the desktops in use (and the one you are on).

■ KEYS YOU USE MOST                  all keys: at the bottom
  tap Super ................ apps
  Super + Enter ............ terminal
  Super + Shift + Enter .... drop-down terminal: show / hide (on every desktop)
  Super + F  /  E .......... files  /  editor
  Super + X ................ power menu: log out, restart, shut down

  Super + ← → ↑ ↓ .......... go to the window on that side
  Super + Shift + arrow .... move the window that way
  Super + Alt + arrow ...... make the window bigger / smaller
  Super + Space ............ full screen on / off
  Super + T ................ tile: master big on the left, the rest on the right
  Super + Shift + T ........ tile: master big on top, the rest below
  Super + M ................ this window becomes the master
  Super + Q ................ close the window
  Alt + Tab ................ the next window
  Alt + Space .............. menu for this window: float it, send it to a desktop ...

  Super + 1 … 9 ............ go to desktop 1 … 9
  Super + Shift + 1 … 9 .... take the window to desktop 1 … 9
  Super + P ................ music: play / pause
  PrtSc .................... screenshot: pick an area
  Super + PrtSc ............ screenshot menu

■ MOUSE
  Alt + drag a window ...... move it
  Alt + right-drag ......... resize it

■ WHERE THE SETTINGS ARE
  keys, rules, autostart ... ~/.config/hypr/hyprland.lua   (one file; read again when saved)
  bar ...................... ~/.config/waybar/
  launcher and menus ....... ~/.config/fuzzel/fuzzel.ini
  the theme's colours ...... ~/.config/polybar-mine/colors.ini
  small scripts ............ ~/.local/bin/
  this page ................ ~/.config/hypr/readme.txt
  Old copies sit next to a changed file: name.bak-DATE

■ SOMETHING WRONG?
  keys or bar stuck ........ Super + Shift + R   (settings read again, a fresh bar)
  an app is frozen ......... Super + Shift + Q   (force-close it)
  log out .................. Ctrl + Alt + Delete (asks first)
  a mistake in the settings  a red box names the line;  hyprctl configerrors
  what went wrong .......... ~/.local/share/hyprland/session.log
  the bar's errors ......... $XDG_RUNTIME_DIR/waybar.log
  no keys at all ........... Ctrl + Alt + F2: a text login, to repair hyprland.lua
