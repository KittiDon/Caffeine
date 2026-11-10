# Caffeine

A coffee mug in the macOS menu bar. Click it to switch between:

- **Steaming hot cup (on)**: your Mac stays awake. No idle sleep, no display sleep, no screen saver.
- **Empty mug (off)**: your Mac sleeps and shows the screen saver as normal.

Hover it, or right-click it, to see whether it's on or off. The right-click menu also has *Open at Login* and *Quit*. Your last choice is remembered.
Closing the lid still sleeps the Mac.

## Build

```sh
./build.sh
open ~/Applications/Caffeine.app
```

`CAFFEINE_SELFTEST=1 ~/Applications/Caffeine.app/Contents/MacOS/Caffeine` checks the toggle end to end.
