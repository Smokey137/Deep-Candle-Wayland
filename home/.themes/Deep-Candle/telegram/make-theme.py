#!/usr/bin/env python3
"""Makes deep-candle.tdesktop-theme, Telegram Desktop in Deep Candle.

Starts from Telegram's own night theme (night-colors.tdesktop-theme, from tdesktop's sources) and
moves every color onto Deep Candle: the blue-grey grounds and greys onto the candle's plum-browns by
lightness, the blues onto its magenta and lavender, greens onto its teal, reds onto its red. Then the
surfaces that carry the look are set by hand (PINNED), with the same colors PCManFM-Qt and
qBittorrent use: chat list = side pane, chat = file list, current chat marked as the current place is.

colors.palette (lib_ui, the version Telegram 7.3.3 was built from) lists every key Telegram knows;
keys the night theme doesn't set are filled in here too, so nothing falls back to the day colors.

Run it, then open the theme with Telegram and press Apply:  Telegram deep-candle.tdesktop-theme
"""
import colorsys
import os
import re
import struct
import zipfile
import zlib

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "deep-candle.tdesktop-theme")
CHAT_BG = "#180E13"   # behind the messages, PCManFM-Qt's file list

# night's lightness -> the candle's grounds and texts
NEUTRAL = [(0.00, "#050304"), (0.09, "#0D0809"), (0.13, "#140C10"), (0.16, "#180E13"),
           (0.19, "#1E1218"), (0.22, "#26171F"), (0.26, "#2B1A23"), (0.31, "#3A2430"),
           (0.38, "#4A3040"), (0.46, "#6A5650"), (0.53, "#8A7470"), (0.62, "#9D887D"),
           (0.75, "#B8A390"), (0.88, "#D2BEA5"), (0.96, "#DCC8AE"), (1.00, "#FFF2E6")]
# night's blues, by lightness -> the candle's magenta and lavender
ACCENT = [(0.00, "#0D050F"), (0.12, "#1E0E22"), (0.22, "#2E1235"), (0.30, "#45194F"),
          (0.36, "#62207A"), (0.44, "#A31FC0"), (0.54, "#C50ED2"), (0.66, "#CB4BD4"),
          (0.76, "#BB90DF"), (0.88, "#DCC4F0"), (1.00, "#F8EEFC")]

PINNED = {
    # the window
    "windowBg": "#140C10", "windowFg": "#DCC8AE",
    "windowBgOver": "#1E1218", "windowBgRipple": "#26171F",
    "windowFgOver": "#F4E5D5", "windowSubTextFg": "#8A7470", "windowSubTextFgOver": "#9D887D",
    "windowBoldFg": "#F4E5D5", "windowBoldFgOver": "#FFF2E6",
    "windowBgActive": "#A31FC0", "windowFgActive": "#FFF2E6", "windowActiveTextFg": "#CB4BD4",
    "windowShadowFgFallback": "#140C10",
    "activeButtonBg": "#A31FC0", "activeButtonBgOver": "#B02ACD", "activeButtonBgRipple": "#8C1AA6",
    "activeButtonFg": "#FFF2E6", "activeButtonSecondaryFg": "#F0D2F5", "activeLineFg": "#A31FC0",
    "lightButtonBgOver": "#26171F", "lightButtonBgRipple": "#2B1A23", "lightButtonFg": "#CB4BD4",
    "menuBgOver": "#26171F", "menuBgRipple": "#2B1A23",
    "titleBg": "#140C10", "titleBgActive": "#140C10", "titleFg": "#8A7470", "titleFgActive": "#DCC8AE",
    "titleButtonBgOver": "#26171F", "titleButtonBgActive": "#140C10", "titleButtonBgActiveOver": "#26171F",
    "titleButtonCloseBgActive": "#140C10",
    # the chat list is the side pane: the current chat marked as the current place is, plum with
    # its name in the clock's gold (polybar's YELLOW); ticks and counts keep the magenta of status
    "dialogsBg": "#140C10", "dialogsBgOver": "#1E1218", "dialogsBgActive": "#2B1A23",
    "dialogsRippleBg": "#26171F", "dialogsRippleBgActive": "#3A2430",
    "dialogsNameFg": "#DCC8AE", "dialogsNameFgOver": "#F4E5D5", "dialogsNameFgActive": "#F7B922",
    "dialogsTextFg": "#8A7470", "dialogsTextFgOver": "#9D887D", "dialogsTextFgActive": "#B8A390",
    "dialogsTextFgServiceActive": "#DCC8AE",
    "dialogsDateFg": "#8A7470", "dialogsDateFgOver": "#9D887D", "dialogsDateFgActive": "#9D887D",
    "dialogsChatIconFgActive": "#F7B922", "dialogsSentIconFgActive": "#CB4BD4",
    "dialogsSendingIconFgActive": "#CB4BD499",
    "dialogsVerifiedIconBgActive": "#F7B922", "dialogsVerifiedIconFgActive": "#2B1A23",
    "dialogsUnreadBg": "#A31FC0", "dialogsUnreadBgOver": "#A31FC0", "dialogsUnreadBgActive": "#A31FC0",
    "dialogsUnreadFg": "#FFF2E6", "dialogsUnreadFgOver": "#FFF2E6", "dialogsUnreadFgActive": "#FFF2E6",
    "dialogsUnreadBgMuted": "#4A3040", "dialogsUnreadBgMutedOver": "#4A3040",
    "dialogsUnreadBgMutedActive": "#4A3040",
    "dialogsOnlineBadgeFg": "#5DB8A6", "dialogsOnlineBadgeFgActive": "#2B1A23",
    # the folders column: the same mark
    "sideBarBg": "#0D0809", "sideBarBgActive": "#2B1A23", "sideBarBgRipple": "#26171F",
    "sideBarTextFg": "#8A7470", "sideBarTextFgActive": "#F7B922",
    "sideBarIconFg": "#8A7470", "sideBarIconFgActive": "#F7B922",
    "sideBarBadgeBg": "#A31FC0", "sideBarBadgeBgMuted": "#4A3040", "sideBarBadgeFg": "#FFF2E6",
    # the chat is the file list; theirs on the button color, yours in plum
    "topBarBg": "#140C10", "historyPinnedBg": "#140C10", "historyComposeAreaBg": "#140C10",
    "historyComposeIconFg": "#8A7470", "historyComposeIconFgOver": "#CB4BD4",
    "historySendIconFg": "#CB4BD4", "historySendIconFgOver": "#E09BEA",
    "msgInBg": "#26171F", "msgInBgSelected": "#3A2430",
    "msgOutBg": "#3F1745", "msgOutBgSelected": "#57205F",
    "msgInShadow": "#05030400", "msgInShadowSelected": "#05030400",
    "msgOutShadow": "#05030400", "msgOutShadowSelected": "#05030400",
    "historyTextInFg": "#DCC8AE", "historyTextOutFg": "#F4E5D5",
    "historyTextInFgSelected": "#FFF2E6", "historyTextOutFgSelected": "#FFF2E6",
    "historyLinkInFg": "#BB90DF", "historyLinkOutFg": "#E0B8F0",
    "msgInServiceFg": "#CB4BD4", "msgOutServiceFg": "#E09BEA",
    "msgInDateFg": "#8A7470", "msgOutDateFg": "#B78FBF",
    "historyOutIconFg": "#E09BEA",
    "msgInReplyBarColor": "#CB4BD4", "msgOutReplyBarColor": "#E09BEA",
    "msgServiceBg": "#26171FD0", "msgServiceBgSelected": "#3A2430", "msgServiceFg": "#DCC8AE",
    # find in chat: the candle's yellow and orange
    "searchedTextMatchBg": "#D2D52A", "searchedTextMatchFg": "#0D0809",
    "searchedTextCurrentMatchBg": "#FF8A3D", "searchedTextCurrentMatchFg": "#0D0809",
}

# keep as Telegram has them: people's name and picture colors stay told apart, and the colored
# badges, gradients and chart lines are pictures more than ground
KEEP = re.compile(r"[Pp]eer\d|^settingsIconBg|^premium|^statisticsChartLine|^credits|^stickerPanPremium"
                  r"|^photoEditor|^mapPoint|^groupCallForceMuted|^groupCallLive|^rank(Admin|Owner)")

ENTRY = re.compile(r"^([A-Za-z0-9_]+):\s*([^;]+);", re.M)


def parse(path):
    with open(path, encoding="utf-8") as f:
        return [(m.group(1), m.group(2).strip()) for m in ENTRY.finditer(f.read())]


def rgb(c):
    return tuple(int(c[i:i + 2], 16) for i in (1, 3, 5))


def hexed(r, g, b):
    return "#%02X%02X%02X" % (round(r), round(g), round(b))


def along(stops, x):
    """The color at x on a ramp of (position, color) stops."""
    x = min(max(x, stops[0][0]), stops[-1][0])
    for (x0, c0), (x1, c1) in zip(stops, stops[1:]):
        if x <= x1:
            t = (x - x0) / (x1 - x0) if x1 > x0 else 0
            return hexed(*(a + (b - a) * t for a, b in zip(rgb(c0), rgb(c1))))
    return stops[-1][1]


def candle(c):
    """One night color moved onto Deep Candle; any alpha is kept."""
    alpha = c[7:9].upper()
    r, g, b = (v / 255 for v in rgb(c))
    hue, light, sat = colorsys.rgb_to_hls(r, g, b)
    hue *= 360
    chroma = max(r, g, b) - min(r, g, b)
    if chroma < 0.22:
        out = along(NEUTRAL, light)
    elif 170 <= hue < 250:
        out = along(ACCENT, light)
    elif 70 <= hue < 170:   # greens -> teal, as the candle's #44A090
        out = hexed(*(v * 255 for v in colorsys.hls_to_rgb(168 / 360, light, sat * 0.85)))
    elif hue < 15 or hue >= 335:   # reds -> the candle's red
        out = hexed(*(v * 255 for v in colorsys.hls_to_rgb(7 / 360, light, sat)))
    else:   # oranges, yellows, violets and pinks are already of the candle
        out = c[:7].upper()
    return out + alpha


def background_png(color, path):
    """A one-pixel picture of color: the chat's ground."""
    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))
    png = (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", 1, 1, 8, 2, 0, 0, 0))
           + chunk(b"IDAT", zlib.compress(b"\x00" + bytes(rgb(color)))) + chunk(b"IEND", b""))
    with open(path, "wb") as f:
        f.write(png)


def main():
    palette = parse(os.path.join(HERE, "colors.palette"))
    known = {k for k, _ in palette}
    night = [(k, v) for k, v in parse(os.path.join(HERE, "night-colors.tdesktop-theme")) if k in known]
    unknown = sorted(set(PINNED) - known)
    if unknown:
        raise SystemExit("not in colors.palette: " + ", ".join(unknown))

    lines, done = [], set()

    def put(key, value):
        if key in PINNED:
            value = PINNED[key]
        elif value.startswith("#") and not KEEP.search(key):
            value = candle(value)
        lines.append(f"{key}: {value};")
        done.add(key)

    # Telegram copies a reference's color when it reads the line, so a key must come after the key
    # it names; one naming a key not written yet waits for it
    waiting = []
    night_keys = {k for k, _ in night}
    for key, value in night:
        if value.startswith("#") or value in done:
            put(key, value)
        else:
            waiting.append((key, value))
    for key, value in palette:   # what night doesn't set: its fallback key, or its color moved over
        if key in night_keys:
            continue
        if "|" in value:
            value = value.split("|")[1].strip()
        if value.startswith("#") or value in done:
            put(key, value)
        else:
            waiting.append((key, value))
    while waiting:
        ready = [(k, v) for k, v in waiting if v in done]
        if not ready:
            raise SystemExit("references to nothing: " + ", ".join(f"{k}: {v}" for k, v in waiting))
        for key, value in ready:
            put(key, value)
        waiting = [(k, v) for k, v in waiting if k not in done]

    colors = os.path.join(HERE, "colors.tdesktop-theme")
    with open(colors, "w", encoding="utf-8") as f:
        f.write("// Deep Candle for Telegram Desktop. Made by make-theme.py; edit PINNED there, not here.\n")
        f.write("\n".join(lines) + "\n")
    background = os.path.join(HERE, "background.png")
    background_png(CHAT_BG, background)
    with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED) as z:
        z.write(colors, "colors.tdesktop-theme")
        z.write(background, "background.png")
    print(f"{OUT}: {len(lines)} colors")


if __name__ == "__main__":
    main()
