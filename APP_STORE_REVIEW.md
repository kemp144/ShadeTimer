# App Store Review Notes

This file is not current for the default branch build. Automatic sleep at timer end is enabled again, so the branch should not be treated as Mac App Store review-ready without revisiting that behavior.

## Submission Summary

ShadeTimer is a sandboxed menu bar utility that dims the screen after a timer by showing non-interactive black overlay windows on top of the display.

## Public API / Safety Notes

- App Sandbox is enabled.
- The app uses public SwiftUI and AppKit APIs only.
- Screen dimming is implemented with borderless, mouse-ignoring overlay windows.
- The bundle includes a privacy manifest that declares `UserDefaults` access for local preference storage.
- The app does not use private APIs, Apple Events, Accessibility access, Screen Recording, or automation hacks.
- The current build can request system sleep with the public `IOPMSleepSystem` API when the timer ends.
- The app is `LSUIElement` based, so it runs as a menu bar utility without a Dock icon.
- The app does not require an account, network connectivity, or any special permissions during review.

## Reviewer Steps

1. Launch the app and click the ShadeTimer icon in the macOS menu bar.
2. Pick a timer from `Choose Time`, then click `Start Timer`.
3. Wait for the countdown to finish and confirm the display dims with a dark overlay.
4. Click `Restore` from the same popover to remove the dim overlay.

## Reviewer Notes Template

You can paste this into App Store Connect review notes:

`This branch currently enables automatic sleep at timer end, so these notes should be rewritten before any Mac App Store submission.`
