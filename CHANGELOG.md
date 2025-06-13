# ACUIR Changelog

## 0.9.0.9

Features:
- Added V0 Settings->Audio page
- Added V0 Settings-View page
- New Search functionality for Settings->Controls

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