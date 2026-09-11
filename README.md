# Spidey Swing 🕷️

Miles Morales web-swinging through your Omarchy top bar — a hand-drawn
6-frame SVG swing cycle in the cursor's chibi style. Sharp at any DPI,
including 4K. Click for a somersault.

## The cycle

`assets/frames/` holds one SVG per beat, cycled every 160ms:

| Frame | Beat |
|-------|------|
| `frame0` | Web-shoot (crouch, firing the line) |
| `frame1` | Launch (pushing off, stretched diagonal) |
| `frame2` | Swing (horizontal, riding the line) |
| `frame3` | Apex (tucked, both hands on) |
| `frame4` | Dive (released, headfirst + speed lines) |
| `frame5` | Land (superhero crouch, fist down) |

On top of the frames: a ±8° pendulum sway, travel drift across a 190px
slot (auto-mirrored so Miles faces his direction), and a click-triggered
360° flip.

## Install

Already lives at `~/.config/omarchy/plugins/thespd.spidey/`. To place it:

```bash
omarchy-shell shell rescanPlugins
omarchy bar put thespd.spidey --section left
```

Plugin code hot-reloads on save. If a change doesn't appear,
`omarchy restart shell`.

## Controls

- **Idle**: swings ±12° on a 2.8s loop while drifting across its slot,
  auto-mirroring at each end so Miles always faces travel direction.
- **Click**: 360° somersault (600ms). Clicks work through the bar host's
  registered click-target contract (`triggerPress`), not a raw `MouseArea`.

## Art

All frames are original vector art drawn for this widget — no screenshots.
Palette matches the Miles cursor + theme (`#1a1c24` suit, `#ff0000`
webbing, `#ffffff` eyes, `#79adff` venom sparks).
