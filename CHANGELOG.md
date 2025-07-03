## ACUIR Changelog
*Requires minimum CSP version 0.2.11 (3465)*
### 0.9.3.7 (unreleased)

Features:
- Added basic onboarding
- V0 rewrite of Setup Exchange frontend
- CSP Data Logger integration (settings pending)
- New help window, instead of the tooltip popup in Car Setup
- Visualization for gamepad deadzone, steering speed, and steer position based on gamma in Controls->Gamepad Tweaks
- New Driving Controls tab in Settings->Controls. Allows for axis to be bound for gamepad and wheels.
- Continued working on fleshing out the binding system. POV buttons should now be bindable, however, I am not sure why AC doesn't register them to be used in game.
- Gamepad tweaks got a bit more fleshed out as well, can now see the deadzone on the graph.

Fixes:
- Cleaned up gear max speeds window, as well as put it in a container
- Fixed quick pit bindings potentially not working
- Fixed crash for Extended Controls
- General backend work
- Fixed background elements highlighting when a modal popup is active
- Smaller fonts in general
- Consistent fonts sizes throughout the app
- App control tabs now show proper name, instead of app dir name
- Text input improvements
- Fixed background elements highlighting when a modal popup is active

### 0.9.2.8

Features:
- New right click context menu for Setup I/O
- New combo box for changing specate camera
- Updated player card design

Fixes:
- Fixed scroll in Car Setup
- Readded Load Setup button to Setup I/O
- Fixed time table Show Disconnected toggle

### 0.9.2.7

Features:
- New entry point window for when using other UI's, to easily activate ACUIR
- Updated car status, will get around to adding graphs similar to CSP UI later
- New "checkbox" UI element
- New window style
 - Has spacing for headers/footers
 - Will lead to the overall "widgets" idea and everything being customizable/moveable
- New sort by alphabetical option for Setup I/O
- New options to only show best or last lap in Telemetry tab

Fixes:
- Fixed the rogue .sp files being saved in AC root
- Fixed keybinding logic in general
- Fixed some timings showing 2 decimals instead of 3
- Fixed imperials unit values being shown instead of metric units when useImperialUnits is false
- Fixed some general UI spacings

Known Issues:
- Modifiers show incorrect values online sometimes, needs further investigation
- Color flickering on track map when crossing the finish line
- Joining online session, mid session, will show incorrect "Wait-Time" period if joined in that time

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