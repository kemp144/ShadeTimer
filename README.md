# ShadeTimer

ShadeTimer is a native macOS menu bar utility for gently dimming the screen after a timer with a Mac App Store-friendly design.

## What It Does

- Menu bar-first `MenuBarExtra` experience
- Quick presets for 5, 10, 15, 30, and 60 minutes
- Menu bar popover with a preset picker, custom minutes, and a dedicated Start Timer action
- Inline custom timer entry inside the popover
- Smooth overlay-based dimming for one display or all displays
- Optional gradual dimming that ramps all the way until the timer expires
- Manual restore with fade-out
- Minimal in-app settings for dim level, current dim level, fade duration, and menu bar countdown
- App Sandbox plus a privacy manifest for locally stored preferences

## Project Layout

- `ShadeTimerCore` contains the reusable models, managers, and controller logic
- `ShadeTimer` contains the menu bar app shell and SwiftUI views
- `ShadeTimerTests` covers timer, preferences, and display-target selection logic

## Build

```bash
xcodegen generate
xcodebuild -project ShadeTimer.xcodeproj -scheme ShadeTimer -destination 'platform=macOS' -derivedDataPath /tmp/ShadeTimerDerivedData build
```

## Tests

`xcodebuild test` is blocked in this sandboxed environment by `testmanagerd`, so the logic tests were verified directly with `xctest`:

```bash
env DYLD_FRAMEWORK_PATH=/tmp/ShadeTimerDerivedData/Build/Products/Debug \
  /Applications/Xcode.app/Contents/Developer/usr/bin/xctest \
  /tmp/ShadeTimerDerivedData/Build/Products/Debug/ShadeTimerTests.xctest
```
