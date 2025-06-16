## ACUIR Changelog
*Requires minimum CSP version 0.2.10 (3459)*
*Ctrl+Shift+F5 to toggle UI. You can now bind a custom bind for this*
### 0.9.2.3 (unreleased)

Features:
- New entry point window for when using other UI's, to easily activate ACUIR
- Updated car status, will get around to adding graphs similar to CSP UI later
- New "checkbox" UI element
- New window style
 - Has spacing for headers/footers
 - Will lead to the overall "widgets" idea and everything being customizable/moveable
- New sort by alphabetical option for Setup I/O

Fixes:
- Fixed rogue .sp file being saved in AC root
- Fixed keybinding logic in general
- Fixed some timings showing 2 decimals instead of 3
- Fixed fahrenheit/lbs value being shown for metric units
- Fixed some general spacings

### 0.9.2.2

Fixes:
- Removed lua debug from Telemetry page

### 0.9.2.1

Fixes:
- Fixed Telemetry module import
- Fixed coloring for Car Setup I/O text input

### 0.9.2.0

Features:
- New V0 Telemetry tab, should replicate the new CSP UI Telemetry for now.
- App toggle binding can now be bound in Settings->Controls-ACUIR->App

Fixes:
- __Fixed calling of unused theme color indexes__
- Added a toast popup for any lua errors
- Errors will disable Auto-Start feature for ACUIR, allowing normal operation of other UIs
- Keyboard bindings can now do more than 1 modifier
- Times now show 3 decimals, instead of 2
- Larger font size for sliders
- Better layout for View Settings
- Setups list now reacts properly to changes made in the setup directory
- Fixing a setup slider overlap edge case


## 0.9.1.0

Features:
- Added V0 Settings->Audio page
- Added V0 Settings-View page
- New V0 Search functionality for Settings->Controls

Fixes:
- Escape key no longer unpauses AC when a dialog popup is present.

## 0.9.0.8

Fixes:
- Improved the look of the setup slider background
- Removed unused modules imports
- All non-race sessions now grab the bestLapTimeMs from the StateSession table, rather than the StateCar table. Previously only Qualify sessions did so.
- Leaving the Settings menu will return you to the same Setup menu page you were on before entering Settings. Previously it just set you to the empty screen.
- Removed lua debug visibility in Settings
- JOY indexes not present in controls.ini no longer cause ACUIR to crash