# Spidey Swing 🕷️

Miles Morales web-swinging through your Omarchy top bar — a hand-drawn
6-frame SVG swing cycle in the cursor's chibi style. Sharp at any DPI,
including 4K. Click for a somersault.

## The cycle

`assets/frames/` holds one SVG per beat, with cinematic per-frame timing
(slow anticipation, snappy action, hangtime, held impact, rest):

| Frame | Beat | Hold |
|-------|------|------|
| `frame0` | Web-shoot (crouch, firing the line) | 420ms |
| `frame1` | Launch (pushing off, stretched diagonal) | 150ms |
| `frame2` | Swing (horizontal, riding the line) | 150ms |
| `frame3` | Apex (tucked, both hands on) | 320ms |
| `frame4` | Dive (released, headfirst + speed lines) | 130ms |
| `frame5` | Wall-run (sprinting down the building) | 170ms |
| `frame6` | Land (superhero crouch, fist down) | 480ms |
| `frame7` | Perch (gargoyle crouch, spider-sense tingling) | 520ms |

On top of the frames: a ±7° pendulum sway, slow travel drift across a
190px slot (auto-mirrored so Miles faces his direction), a 22s rooftop
skyline parallax behind him, and a click-triggered 360° flip.

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
