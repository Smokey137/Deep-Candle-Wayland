-- hyprland.lua: the Deep Candle session on Hyprland (Wayland). Ported on 2026-11-09 from Deep
-- Candle's bspwm of that day (wm/bspwm: bspwmrc, sxhkdrc and scripts/), for Hyprland 0.57.
-- (0.57 reads only this Lua file: hyprland.conf is gone.)
--
-- Hyprland reads this file again each time it is saved; Super+Shift+R does it by hand.
-- A mistake in it: a red box on the screen names the line. `hyprctl configerrors` lists them.
--
--   bspwm + sxhkd + scripts/   -->   this one file: Hyprland does the windows and the keys, and
--                                    what the scripts did (win, desktops, goto, app-desktops) is
--                                    Lua here. No xdotool, no bspc.
--
-- What bspwm had and this has not: README.md, "Not ported".

local HOME = os.getenv("HOME") or ""
local BIN = HOME .. "/.local/bin/"            -- this repo's scripts
local RUN = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
local BORDER = 2

local function run(cmd) return hl.dsp.exec_cmd(cmd) end

---------------------------------------------------------------------------------------------
-- Environment: Wayland for every toolkit that can do it; X apps still work through Xwayland
---------------------------------------------------------------------------------------------

hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland,x11")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")    -- Java windows stay grey without it
hl.env("XCURSOR_SIZE", "24")

---------------------------------------------------------------------------------------------
-- Screens: every screen at its own best size. A second screen, or a fixed place for one:
-- one more hl.monitor line (hyprctl monitors names them)
---------------------------------------------------------------------------------------------

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

---------------------------------------------------------------------------------------------
-- Look: bspwm's borders (2 px, the Deep Candle browns) and gaps (8 px), picom's round corners,
-- shadows and short fade. Nothing else moves: no blur, no slide, no wobble.
---------------------------------------------------------------------------------------------

hl.config({
    general = {
        border_size = BORDER,
        gaps_in     = 4,                      -- a side: two windows next to each other make 8
        gaps_out    = 8,
        col = {
            active_border   = "rgb(7A5820)",
            inactive_border = "rgb(2C2323)",
        },
        layout            = "dwindle",        -- bspwm's way: split in two, again and again
        no_focus_fallback = true,             -- Super+arrow with no window that side: step() below
        resize_on_border  = false,
    },
    decoration = {
        rounding    = 8,
        dim_special = 0,                      -- the drop-down terminal doesn't darken the rest
        blur   = { enabled = false },
        shadow = { enabled = true, range = 14, render_power = 3, color = "rgba(00000059)" },
    },
    animations = { enabled = true },
})

-- only the fade (windows and menus coming and going, 0.15 s, as picom's)
hl.animation({ leaf = "global", enabled = false })
hl.animation({ leaf = "fade", enabled = true, speed = 1.5, bezier = "default" })

---------------------------------------------------------------------------------------------
-- Mouse and keyboard, as in bspwm: a click gives a window the keys (the click still reaches
-- it), the wheel works on the window under the pointer, the pointer is never moved for you
---------------------------------------------------------------------------------------------

hl.config({
    input = {
        follow_mouse = 2,
        float_switch_override_focus = 0,
        special_fallthrough = true,           -- windows under the drop-down terminal take clicks
        -- kb_layout = "us",                  -- your keyboard, e.g. "us", "cz", or "us,cz"
    },
    cursor = { no_warps = true },
})

---------------------------------------------------------------------------------------------
-- Tiling
---------------------------------------------------------------------------------------------

hl.config({
    dwindle = {
        preserve_split = true,                -- a split stays as it is until Super+Ctrl+R turns it
        force_split    = 2,                   -- a new window: on the right, or below
    },
    master = {
        mfact      = 0.6,                     -- the master takes 60 %
        new_status = "slave",                 -- a new window joins the column / row
    },
    binds = {
        workspace_back_and_forth = 1,         -- Super+N when on desktop N: back where you were
    },
    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
        background_color         = "rgb(0D0809)",   -- under the wallpaper, before swaybg has it up
        focus_on_activate        = true,      -- an app that asks for the focus gets it
    },
    ecosystem = {
        no_update_news  = true,
        no_donation_nag = true,
    },
})

---------------------------------------------------------------------------------------------
-- Rules (bspwmrc's). A window is known by its class: `hyprctl clients` shows it.
---------------------------------------------------------------------------------------------

-- small tools and settings float, in the middle
local FLOATERS = {
    "nitrogen", "lxappearance", [[org\.pulseaudio\.pavucontrol]], "pavucontrol", "qt5ct", "qt6ct",
    "xfce4-appearance-settings", "xfce4-settings-manager", "xfce4-power-manager-settings",
    "blueman-manager", "nm-connection-editor", ".*qalculate.*", "yad", "zenity", "viewnior", "feh",
}
hl.window_rule({
    name   = "small-tools-float",
    match  = { class = "(?i)(" .. table.concat(FLOATERS, "|") .. ")" },
    float  = true,
    center = true,
})

-- Ctrl+Alt+M: ncmpcpp, at its own size
hl.window_rule({ name = "music-player", match = { class = "music" }, float = true, center = true })

-- Super+R: the quick guide
hl.window_rule({
    name   = "quick-guide",
    match  = { class = "readme" },
    float  = true,
    size   = { 900, "monitor_h*0.8" },
    center = true,
})

-- Super+Shift+Enter: the drop-down terminal, at the top middle, 70 % wide, 45 % high, under the
-- bar. It lives on a desktop of its own that is shown over the one you are on.
hl.window_rule({
    name      = "drop-down-terminal",
    match     = { class = "dropdown" },
    float     = true,
    workspace = "special:dropdown",
    size      = { "monitor_w*0.7", "monitor_h*0.45" },
    move      = { "monitor_w*0.15", 32 },
})

-- Apps with a desktop of their own. A new window of one opens there, and you go with it.
--   1, 2  Brave: the first main window on 1, a second one on 2; any more open where you are
--   3 calibre (the library)   4 Claude   7 Dino   8 Discord   9 YouTube or Spotify
-- Claude, Discord, YouTube and Spotify are Brave web apps: on Wayland their class holds the
-- app's id (brave-<id>-Default). Another app: one more line here, and a key below.
local function web_app(id)
    return {
        class = ".*" .. id .. ".*",
        match = function(c) return c:find(id, 1, true) ~= nil end,
        start = "brave --profile-directory=Default --app-id=" .. id,
    }
end

local APPS = {
    brave = {
        match = function(c) return c:lower() == "brave-browser" end,
        start = "brave",
    },
    calibre = {
        class = "calibre-gui", desktop = 3,
        match = function(c) return c == "calibre-gui" end,
        start = "calibre --detach",
    },
    dino = {
        class = [[(?i)(im\.dino\.)?dino]], desktop = 7,
        match = function(c) c = c:lower() return c == "dino" or c == "im.dino.dino" end,
        start = "dino",
    },
    claude  = web_app("fmpnliohjhemenmnlpbfagaolkdacoja"),
    discord = web_app("magkoliahgffibhgfkmoealggombgknl"),
    youtube = web_app("agimnkijcaahngcdmfeangaknmldooml"),
    spotify = web_app("pjibgclleladliembfgfagdaldikeohf"),
}
APPS.claude.desktop, APPS.discord.desktop = 4, 8
APPS.youtube.desktop, APPS.spotify.desktop = 9, 9

for name, app in pairs(APPS) do
    if app.desktop then
        hl.window_rule({
            name      = "desktop-of-" .. name,
            match     = { class = app.class },
            workspace = tostring(app.desktop),
        })
    end
end

-- an app's tiled windows on the numbered desktops, in desktop order (left to right on each)
local function windows_of(app)
    local found = {}
    for _, w in ipairs(hl.get_windows()) do
        local ws = w.workspace
        if app.match(w.class or "") and not w.floating and ws and ws.id and not ws.special then
            found[#found + 1] = w
        end
    end
    table.sort(found, function(a, b)
        if a.workspace.id ~= b.workspace.id then return a.workspace.id < b.workspace.id end
        if a.at.x ~= b.at.x then return a.at.x < b.at.x end
        if a.at.y ~= b.at.y then return a.at.y < b.at.y end
        return a.address < b.address
    end)
    return found
end

-- Brave: which desktop a new main window goes to depends on where the others are, so it is
-- looked at when the window opens. (Its pop-ups float: they stay where you are.)
hl.on("window.open", function(w)
    if not w or w.floating or not APPS.brave.match(w.class or "") then return end
    local taken = {}
    for _, other in ipairs(windows_of(APPS.brave)) do
        if other ~= w then taken[other.workspace.id] = true end
    end
    for _, desktop in ipairs({ 1, 2 }) do
        if not taken[desktop] then
            if not (w.workspace and w.workspace.id == desktop) then
                hl.dispatch(hl.dsp.window.move({ window = w, workspace = desktop }))
            end
            return
        end
    end
end)

---------------------------------------------------------------------------------------------
-- What the keys do (bspwm's scripts/win, desktops and goto)
---------------------------------------------------------------------------------------------

local function tiled_on(ws)
    local found = {}
    for _, w in ipairs(hl.get_workspace_windows(ws)) do
        if not w.floating then found[#found + 1] = w end
    end
    return found
end

-- the next (way = 1) or previous (way = -1) desktop on this screen that has windows, wrapping
-- round; you land on its window nearest the side you came in from (the leftmost, going right)
local function step(way)
    local here = hl.get_active_workspace()
    if not (here and here.id) then return end
    local near, far
    for _, ws in ipairs(hl.get_workspaces()) do
        local other = ws.id and not ws.special and ws.id ~= here.id
        if other and ws.windows > 0 and ws.monitor == here.monitor then
            local ahead = (ws.id - here.id) * way > 0
            if ahead and (not near or (ws.id - near.id) * way < 0) then near = ws end
            if not ahead and (not far or (ws.id - far.id) * way < 0) then far = ws end
        end
    end
    local target = near or far
    if not target then return end
    hl.dispatch(hl.dsp.focus({ workspace = target.id }))
    local pick
    for _, w in ipairs(tiled_on(target)) do
        if not pick
            or (way > 0 and w.at.x < pick.at.x)
            or (way < 0 and w.at.x + w.size.x > pick.at.x + pick.size.x) then
            pick = w
        end
    end
    if pick then hl.dispatch(hl.dsp.focus({ window = pick })) end
end

-- Super+arrow: the window on that side gets the focus. Left / right with none that way: step()
local function focus(side, way)
    return function()
        local w = hl.get_active_window()
        if w then
            local done = hl.dispatch(hl.dsp.focus({ direction = side }))
            -- (the drop-down terminal is not on a numbered desktop: no stepping from it)
            if (done and done.ok) or (w.workspace and w.workspace.special) then return end
        end
        if way then step(way) end
    end
end

-- Super+Shift+arrow: this window swaps places with the one on that side. Left / right with none
-- there (it is at the edge already, or it floats): to the desktop before / after (1 to 9, round
-- and round), and you go along
local function carry(side, way)
    return function()
        local w = hl.get_active_window()
        if not w or (w.fullscreen or 0) > 0 then return end
        if not w.floating then
            local done = hl.dispatch(hl.dsp.window.swap({ direction = side }))
            if done and done.ok then return end
        end
        local here = w.workspace
        if way and here and here.id and not here.special then
            hl.dispatch(hl.dsp.window.move({ workspace = (here.id - 1 + way) % 9 + 1 }))
        end
    end
end

-- the part of a screen windows may use: all of it but the bar. (Hyprland's names: "mode" is the
-- screen's size as windows see it, "reserved" what the bar takes.)
local function work_area(m)
    local r = m.reserved
    return m.position.x + r.left, m.position.y + r.top,
        m.mode.width - r.left - r.right, m.mode.height - r.top - r.bottom
end

-- Super+numpad, the numpad as the screen. A tiled window: 4 6 8 2 swap it with its neighbour on
-- that side. A floating one: that half of the screen, no gaps. 5: the whole desktop, on / off.
local HALF = {                                -- x, y, width, height, as parts of the screen
    left = { 0, 0, .5, 1 }, right = { .5, 0, .5, 1 }, up = { 0, 0, 1, .5 }, down = { 0, .5, 1, .5 },
}
local function snap(side)
    return function()
        local w = hl.get_active_window()
        if not w then return end
        if side == "whole" then
            hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized" }))
        elseif not w.floating then
            hl.dispatch(hl.dsp.window.swap({ direction = side }))
        elseif w.monitor then
            local x, y, width, height = work_area(w.monitor)
            local cell = HALF[side]
            hl.dispatch(hl.dsp.window.resize({
                x = math.floor(cell[3] * width) - 2 * BORDER,
                y = math.floor(cell[4] * height) - 2 * BORDER,
            }))
            hl.dispatch(hl.dsp.window.move({
                x = math.floor(x + cell[1] * width) + BORDER,
                y = math.floor(y + cell[2] * height) + BORDER,
            }))
        end
    end
end

-- The master layout, as in dwm: one window big (the master), the others in a column on the right
-- (Super+T) or a row below (Super+Shift+T). Hyprland keeps it: a new window joins the column.
-- The same key again: back to plain tiling. A desktop's layout is a rule made here, so it lasts
-- until this file is read again.
local master_side = {}                        -- desktop number -> "left" or "top"

local function set_layout(ws, side)
    if side then
        hl.workspace_rule({
            workspace = tostring(ws.id), layout = "master", layout_opts = { orientation = side },
        })
    else
        hl.workspace_rule({ workspace = tostring(ws.id), layout = "dwindle" })
    end
    master_side[ws.id] = side
end

local function tile(side)
    return function()
        local ws = hl.get_active_workspace()
        if not (ws and ws.id) then return end
        if ws.tiled_layout == "master" and master_side[ws.id] == side then
            set_layout(ws, nil)
        else
            set_layout(ws, side)
        end
    end
end

-- Super+M: this window becomes the master (no master layout yet: the left one first)
local function master()
    local w, ws = hl.get_active_window(), hl.get_active_workspace()
    if not (w and ws and ws.id) or w.floating then return end
    if ws.tiled_layout ~= "master" then
        set_layout(ws, "left")
        hl.exec_scheduled_prop_refresh_immediately()   -- the layout is there before the next line
    end
    hl.dispatch(hl.dsp.layout("swapwithmaster master ignoremaster"))
end

-- Super+Ctrl+R: side by side <-> one above the other (in the master layout: left <-> top)
local function rotate()
    local ws = hl.get_active_workspace()
    if not (ws and ws.id and hl.get_active_window()) then return end
    if ws.tiled_layout == "master" then
        set_layout(ws, master_side[ws.id] == "top" and "left" or "top")
    elseif ws.tiled_layout == "dwindle" then
        hl.dispatch(hl.dsp.layout("rotatesplit"))
    end
end

-- Super+B: the two halves of this split the same size again (in the master layout: 60 / 40)
local function even()
    local w, ws = hl.get_active_window(), hl.get_active_workspace()
    if not (w and ws) or w.floating then return end
    if ws.tiled_layout == "master" then
        hl.dispatch(hl.dsp.layout("mfact exact 0.6"))
    elseif ws.tiled_layout == "dwindle" and #tiled_on(ws) > 1 then
        hl.dispatch(hl.dsp.layout("splitratio 1 exact"))
    end
end

-- Super+W, Y, S, D, C, I, L: the app is open: go to its window (its desktop comes with it);
-- already there: its next window, round and round. Not open: start it, and the rules above put
-- it on its desktop. Brave: on desktop 1, its window on another desktop (2), or a new one;
-- anywhere else, its first one (on 1).
local function go_to(name)
    local app = APPS[name]
    return function()
        local wins = windows_of(app)
        if #wins == 0 then
            hl.exec_cmd(app.start)
            return
        end
        local here, now = hl.get_active_workspace(), hl.get_active_window()
        local pick = wins[1]
        if name == "brave" then
            if here and here.id == 1 then
                pick = nil
                for _, w in ipairs(wins) do
                    if w.workspace.id ~= 1 then pick = w break end
                end
                if not pick then
                    hl.exec_cmd("brave --new-window")
                    return
                end
            end
        elseif now then
            for i, w in ipairs(wins) do
                if w == now then pick = wins[i % #wins + 1] break end
            end
        end
        hl.dispatch(hl.dsp.focus({ window = pick }))
    end
end

-- Super+Shift+Enter: none yet: start one (its rule shows it); else show / hide it
local function dropdown()
    if #hl.get_windows({ class = "dropdown" }) == 0 then
        hl.exec_cmd(BIN .. "term -c dropdown")
    else
        hl.dispatch(hl.dsp.workspace.toggle_special("dropdown"))
    end
end

-- Super+R: the quick guide; again: close it
local function guide()
    local open = hl.get_windows({ class = "readme" })
    if #open == 0 then
        hl.exec_cmd(BIN .. "guide")
        return
    end
    for _, w in ipairs(open) do hl.dispatch(hl.dsp.window.close({ window = w })) end
end

-- Alt+Space: what to do with this window, in a menu (~/.local/bin/winmenu)
local function window_menu()
    local w = hl.get_active_window()
    if not w then return end
    hl.exec_cmd(string.format("%swinmenu %s %d %d %d", BIN, w.address,
        w.floating and 1 or 0, w.fullscreen or 0, w.pinned and 1 or 0))
end

-- Ctrl+PrtSc: this window's place and size go to the screenshot script
local function shoot_window()
    local w = hl.get_active_window()
    if not w then
        hl.exec_cmd(BIN .. "screenshot area")
        return
    end
    hl.exec_cmd(string.format("%sscreenshot win '%d,%d %dx%d'", BIN, w.at.x, w.at.y, w.size.x, w.size.y))
end

---------------------------------------------------------------------------------------------
-- Keys (sxhkdrc's, in its order). key(KEYS, WORDS, WHAT): WORDS is the key's line in the Super+/
-- list and in the quick guide (Super+R); hyprctl binds shows it too.
---------------------------------------------------------------------------------------------

local SHOWN = {
    SUPER = "Super", SHIFT = "Shift", CTRL = "Ctrl", ALT = "Alt",
    Return = "Enter", space = "Space", slash = "/", Print = "PrtSc",
    left = "←", right = "→", up = "↑", down = "↓",
    ["code:80"] = "Num 8", ["code:83"] = "Num 4", ["code:84"] = "Num 5", ["code:85"] = "Num 6",
    ["code:88"] = "Num 2",
    XF86MonBrightnessUp = "brightness-up key", XF86MonBrightnessDown = "brightness-down key",
    XF86AudioRaiseVolume = "volume-up key", XF86AudioLowerVolume = "volume-down key",
    XF86AudioMute = "mute key", XF86AudioMicMute = "mic-mute key", XF86AudioStop = "stop key",
    XF86AudioPlay = "play key", XF86AudioPrev = "previous key", XF86AudioNext = "next key",
}

local list = {}                               -- the key list: "## part" or "keys<TAB>words"

local function shown(keys)
    local parts = {}
    for raw in keys:gmatch("[^+]+") do
        local name = raw:match("^%s*(.-)%s*$")
        parts[#parts + 1] = SHOWN[name] or (#name == 1 and name:upper()) or name
    end
    return table.concat(parts, "+")
end

local function part(name) list[#list + 1] = "## " .. name end
local function say(keys, words) list[#list + 1] = keys .. "\t" .. words end

local function key(keys, words, what, flags)
    flags = flags or {}
    if words then
        flags.description = words
        say(shown(keys), words)
    end
    hl.bind(keys, what, flags)
end

part("Menus")
key("SUPER + slash", "this list of keys", run(BIN .. "keys"))
key("SUPER + R", "quick guide to this desktop (again: close it)", guide)
key("ALT + space", "menu for this window", window_menu)
key("CTRL + ALT + space", "app launcher", run(BIN .. "launcher"))

part("Windows and desktops")
key("ALT + Tab", "switch window: the next one on this desktop", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)
key("ALT + SHIFT + Tab", "switch window, the other way round", function()
    hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)
key("SUPER + Tab", "the window used last, on any desktop", hl.dsp.focus({ last = true }))
key("SUPER + left", "jump to the window left (none there: the previous desktop)", focus("left", -1))
key("SUPER + right", "jump to the window right (none there: the next desktop)", focus("right", 1))
key("SUPER + up", "jump to the window above", focus("up"))
key("SUPER + down", "jump to the window below", focus("down"))
key("SUPER + SHIFT + left", "move window left (at the edge: to the previous desktop)", carry("left", -1))
key("SUPER + SHIFT + right", "move window right (at the edge: to the next desktop)", carry("right", 1))
key("SUPER + SHIFT + up", "move window up", carry("up"))
key("SUPER + SHIFT + down", "move window down", carry("down"))
key("SUPER + CTRL + R", "rotate: side by side / one above the other", rotate)
for n = 1, 9 do
    key("SUPER + " .. n, nil, hl.dsp.focus({ workspace = n }))
end
say("Super+1 … 9", "desktop 1 … 9 (press it again: back where you were)")
key("SUPER + P", "music: play / pause", run(BIN .. "music toggle"))
key("SUPER + B", "this split: both halves the same size again", even)
key("SUPER + T", "tile: master big on the left, the others in a column (again: off)", tile("left"))
key("SUPER + SHIFT + T", "tile: master big on top, the others in a row below (again: off)", tile("top"))
key("SUPER + M", "this window becomes the master", master)

part("Session")
key("SUPER + SHIFT + R", "read the settings again, a fresh bar (windows stay)", function()
    hl.exec_cmd(BIN .. "bar")
    hl.dispatch(hl.dsp.reload_config())
end)
key("CTRL + ALT + Delete", "log out (asks first)", run(BIN .. "powermenu logout"))

part("Window actions")
for n = 1, 9 do
    key("SUPER + SHIFT + " .. n, nil, hl.dsp.window.move({ workspace = n }))
end
say("Super+Shift+1 … 9", "take window to desktop 1 … 9")
-- the line between two windows follows the arrow, whichever of them has the focus; a floating
-- window: its right / bottom edge
local function edge(x, y) return hl.dsp.window.resize({ x = x, y = y, relative = true }) end
key("SUPER + ALT + left", "resize: move the edge left", edge(-20, 0), { repeating = true })
key("SUPER + ALT + right", "resize: move the edge right", edge(20, 0), { repeating = true })
key("SUPER + ALT + up", "resize: move the edge up", edge(0, -20), { repeating = true })
key("SUPER + ALT + down", "resize: move the edge down", edge(0, 20), { repeating = true })
-- the numpad's keys by their numbers (code:NN), so they work with NumLock on or off
key("SUPER + code:88", "snap window: bottom", snap("down"))
key("SUPER + code:83", "snap window: left half", snap("left"))
key("SUPER + code:84", "snap window: the whole desktop, on / off", snap("whole"))
key("SUPER + code:85", "snap window: right half", snap("right"))
key("SUPER + code:80", "snap window: top", snap("up"))
key("SUPER + Q", "close window", hl.dsp.window.close())
key("ALT + F4", "close window", hl.dsp.window.close())
key("SUPER + SHIFT + Q", "force-close a frozen app", hl.dsp.window.kill())
key("SUPER + space", "fullscreen on / off", hl.dsp.window.fullscreen())

part("Screenshots, brightness, volume, music")
key("Print", "screenshot: pick an area", run(BIN .. "screenshot area"))
key("CTRL + Print", "screenshot of this window", shoot_window)
key("SUPER + Print", "screenshot menu", run(BIN .. "screenshot"))
key("XF86MonBrightnessUp", "brightness up", run(BIN .. "brightness up"), { repeating = true })
key("XF86MonBrightnessDown", "brightness down", run(BIN .. "brightness down"), { repeating = true })
key("XF86AudioRaiseVolume", "volume up", run(BIN .. "volume up"), { repeating = true })
key("XF86AudioLowerVolume", "volume down", run(BIN .. "volume down"), { repeating = true })
key("XF86AudioMute", "sound on / off", run(BIN .. "volume mute"))
key("XF86AudioMicMute", "microphone on / off", run(BIN .. "volume mic"))
key("XF86AudioStop", "music stop", run(BIN .. "music stop"))
key("XF86AudioPlay", "music play / pause", run(BIN .. "music toggle"))
key("XF86AudioPrev", "music previous", run(BIN .. "music prev"))
key("XF86AudioNext", "music next", run(BIN .. "music next"))

part("Applications")
key("SUPER + Return", "terminal", run(BIN .. "term"))
key("SUPER + F", "files (pcmanfm-qt)", run("pcmanfm-qt"))
key("SUPER + W", "Brave: go to it, or open it (on desktop 1: the Brave on 2)", go_to("brave"))
key("SUPER + Y", "YouTube: go to it, or open it", go_to("youtube"))
key("SUPER + S", "Spotify: go to it, or open it", go_to("spotify"))
key("SUPER + D", "Discord: go to it, or open it", go_to("discord"))
key("SUPER + C", "Claude: go to it, or open it", go_to("claude"))
key("SUPER + I", "Dino: go to it, or open it", go_to("dino"))
key("SUPER + L", "calibre: go to it, or open it", go_to("calibre"))
key("SUPER + SHIFT + Return", "drop-down terminal: show / hide", dropdown)
key("SUPER + E", "editor (Geany)", run("geany"))
key("ALT + F1", "app launcher (or just tap Super)", run(BIN .. "launcher"))
key("SUPER + X", "power menu", run(BIN .. "powermenu"))
key("CTRL + ALT + M", "music player (ncmpcpp)", run(BIN .. "term -c music ncmpcpp"))

-- a tap on Super alone (pressed and let go, no other key in between): the launcher
hl.bind("Super_L", run(BIN .. "launcher"), { release = true })
hl.bind("Super_R", run(BIN .. "launcher"), { release = true })

---------------------------------------------------------------------------------------------
-- The mouse, as in bspwm: Alt+drag moves a window, Alt+right-drag resizes it
---------------------------------------------------------------------------------------------

part("Mouse")
hl.bind("ALT + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("ALT + mouse:273", hl.dsp.window.resize(), { mouse = true })
say("Alt+drag", "move a window")
say("Alt+right-drag", "resize a window")

---------------------------------------------------------------------------------------------
-- Started with the session: only the desktop itself (the sound server the bar's sound pieces
-- need, the wallpaper, the bar). Apps you want at login: one more hl.exec_cmd line each.
---------------------------------------------------------------------------------------------

hl.on("hyprland.start", function()
    hl.exec_cmd(BIN .. "sound-server")
    hl.exec_cmd('swaybg -m fill -i "$HOME/.wallpaper"')
    hl.exec_cmd(BIN .. "bar")
end)

---------------------------------------------------------------------------------------------
-- The key list, for ~/.local/bin/keys (Super+/) and ~/.local/bin/guide (Super+R): written out
-- each time this file is read, so it is never out of date
---------------------------------------------------------------------------------------------

local out = io.open(RUN .. "/deep-candle-keys", "w")
if out then
    out:write(table.concat(list, "\n"), "\n")
    out:close()
end
