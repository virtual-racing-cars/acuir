## ACUIR Changelog
*Requires minimum CSP version 0.2.10 (3459)*
*Ctrl+Shift+F5 to toggle UI*
### 0.9.1.1

Features:
- Larger font size for sliders

Fixes:
- Setups list now reacts properly to changes made in the setup directory.
- Attempt at fixing overlapped sliders

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