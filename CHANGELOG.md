## ACUIR Changelog
*Requires minimum CSP version 0.2.10 (3459)*
*Ctrl+Shift+F5 to toggle UI*
### 0.9.1.9

Features:
- App toggle binding can now be bound in Settings->Controls-ACUIR->App

Fixes:
- Times now show 3 decimals, instead of 2
- Larger font size for sliders
- Better layout for View Settings
- Setups list now reacts properly to changes made in the setup directory
- Fixing a setup slider overlap edge case
- Fixed calling of unused theme color indexes
- Added a toast popup for any lua errors
- Errors will disable Auto-Start feature for ACUIR, allowing normal operation of other UIs
- Keyboard bindings can now do more than 1 modifier

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