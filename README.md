# Mug

A coffee mug in the macOS menu bar. Click it to switch between:

- **Filled mug**: your Mac stays awake. No idle sleep, no display sleep, no screen saver.
- **Empty mug**: your Mac sleeps and shows the screen saver as normal.

Right-click it for *Open at Login* and *Quit*. Your last choice is remembered.
Closing the lid still sleeps the Mac.

## Build

```sh
./build.sh
open ~/Applications/Mug.app
```

`MUG_SELFTEST=1 ~/Applications/Mug.app/Contents/MacOS/Mug` checks the toggle end to end.
