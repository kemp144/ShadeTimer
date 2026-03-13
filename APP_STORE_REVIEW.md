# App Store Review Notes

## Submission Summary

ShadeTimer is a menu bar utility that dims the screen after a timer by showing non-interactive black overlay windows on top of the display.

## Public API / Safety Notes

- App Sandbox is enabled.
- The app uses public SwiftUI and AppKit APIs only.
- Screen dimming is implemented with borderless, mouse-ignoring overlay windows.
- The bundle includes a privacy manifest that declares `UserDefaults` access for local preference storage.
- The app does not use private APIs, Apple Events, Accessibility access, Screen Recording, or automation hacks.
- The App Store build does not initiate system sleep automatically.

## Reviewer Notes Template

You can paste this into App Store Connect review notes:

`ShadeTimer is a sandboxed menu bar utility. It dims the display by showing non-interactive translucent overlay windows using public AppKit APIs. The app stores only local preferences in UserDefaults, declares that access in its privacy manifest, does not request Accessibility, Screen Recording, or Apple Events permissions, and does not automate system sleep in the App Store build.`
