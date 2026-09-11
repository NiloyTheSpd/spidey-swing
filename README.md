# Spidey Swing 🕷️

Miles Morales web-swinging through your Omarchy top bar. A third-party
Quickshell bar widget: pendulum swing + travel drift, click for a somersault.

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

## Art credit

`assets/miles-swing.png` — Miles Morales swinging PNG via pngall.com,
free for **personal use**. Keep this repo local; check the license before
publishing the art anywhere public.
