# AHKv2-Gdip
This repository contains the GDI+ library (Gdip_All.ahk) compatible with the current [AutoHotKey v2](https://autohotkey.com/v2/).

Support for AHK v1 is dropped (find the original `Gdip_All.ahk` library if you need it).  

See the [commit history](https://github.com/buliasz/AHKv2-Gdip/commits/master) to see the changes made and [changelog](https://github.com/buliasz/AHKv2-Gdip/blob/master/CHANGE.log).

# Examples
See the appropriate Examples folder for usage examples

# Usage
All of the Gdip_*() functions use the same syntax as before, so no changes should be required, with one exception:  

The `Gdip_BitmapFromBRA()` function requires you to read the .bra file witih `FileObj.RawRead()` instead of the `FileRead` command. See the Tutorial.11 file in the Examples folder

# History
- @tic Created the original [Gdip.ahk](https://github.com/tariqporter/Gdip/) library.
- @Rseding91 Updated it to make it compatible with unicode and x64 AHK versions and renamed the file `Gdip_All.ahk`.
- @mmikeww Repository updates @Rseding91's `Gdip_All.ahk` to fix bugs and make it compatible with AHK v2.
- @buliasz Fork of mmikeww repository: updates for the current version of AHK v2 (dropping AHK v1 backward compatibility).
