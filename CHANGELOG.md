
---
## October 27, 2024 - Release 1.0.1

### New Features:
- Added a setting for hiding the title bar on desktop platforms. This is
  especially useful for Linux/Wayland.
- Changed the accept button on the Settings screen from a back arrow to a
  check-mark.

### Updates:
- Updated the Android build to work with Android 15.
- Several libraries used in the build have been updated.

---
## November 26, 2023 - Release 1.0.0

### New Features:
- rpCalc has been rewritten in Dart using the Flutter framework. It
  now has a cleaner-looking interface. A single code base can run on
  Linux, Windows, Android and on the web.

---
## April 8, 2018 - Release 0.8.2

### Updates:
- Added a desktop file to the Linux version to provide menu entries.
- Built the Windows version with an updated version of the GUI
  library.

---
## February 4, 2017 - Release 0.8.1 (Linux only)

### Bug Fixes:
- Replaced outdated dependency checks in the Linux installer - it now
  runs checks for Qt5 libraries.
- Fixed a timing issue in the Linux installer so that byte-compiled
  files do not have old timestamps.

---
## January 15, 2017 - Release 0.8.0

### New Features:
- rpCalc has been ported from the Qt4 to the Qt5 library.

---
## December 6, 2015 - Release 0.7.1

### Updates:
- Clarified some dependency checker error messages in the Linux
  installer.
- Added some MSVC runtime DLL files to the Windows installers to avoid
  problems on PCs that do not already have them.

### Bug Fixes:
- Fixed problems responding to some keyboard presses when the shift
  key is used on Windows.

---
## January 26, 2014 - Release 0.7.0

### Updates:
- rpCalc has been ported from Python 2 to Python 3. This porting
  includes some code cleanup.
- The Windows binaries are built using more recent Python, Qt and PyQt
  libraries.
- There is an additional Windows installer for users without
  administrator rights and for portable installations.
- Added an installer option to add a config file to the program\'s
  directory for portable installations. If that file is present, no
  config files will be written to users\' directories.

---
## October 14, 2008 - Release 0.6.0

### New Features:
- A new base conversion dialog was added. It shows values in
  hexadecimal, octal and binary bases. Push buttons or keyboard
  prefixes can be used to allow entry of a value in one of these
  bases.
- A colon (\":\") can optionally be used as a prefix when typing
  commands. This is useful in hexadecimal entry mode for commands
  starting with letters \"A\" through \"F\".
- New options have been added for alternate base conversions. The
  number of bits and whether to use two\'s complement for negative
  numbers can be set.
- A display option was added to separate thousands with spaces in the
  main \"LCD\".
- An engineering notation display option was added that only shows
  exponents that are divisible by three.

### Updates:
- Keyboard number and function entry continue to work when the Extra
  Data window has focus.
- The ReadMe file has been updated.

---
## October 3, 2006 - Release 0.5.0

### New Features:
- rpCalc was ported to the Qt4 library. This involved a significant
  rewrite of the code. The previous versions used Qt3.x on Linux and
  Qt2.3 on Windows. Benefits include updated widgets and removal of
  the non-commercial license exception in Windows.

### Updates:
- On Windows, the rpCalc.ini file has been moved from the installation
  directory to a location under the \"Documents and Settings\" folder.
  This avoids problems on multi-user systems and for users with
  limited access rights.

---
## March 12, 2004 - Release 0.4.3

### New Features:
- The size and position of the main and extra windows are now saved at
  exit.
- An install program has been added for windows.

### Bug Fixes:
- Fixed Linux install script problems with certain versions of Python.

---
## November 17, 2003 - Release 0.4.2

### New Features:
- Allow the use of commas in addition to periods as decimal points to
  accommodate European keyboards.

### Updates:
- An install script was added for Linux and Unix systems.
- The windows build now uses Python version 2.3 and PyQt version 3.8.

---
## July 14, 2003 - Release 0.4.1

### New Features:
- Added an option to remove the LCD display highlight. This is useful
  for smaller displays

### Bug Fixes:
- Fixed a problem with the option to display the extra data view on
  startup.

---
## April 30, 2003 - Release 0.4.0

### New Features:
- The main display can optionally be expanded to show lines for the Y,
  Z, & T registers.
- The three separate views for extra data (registers, history &
  memory) have been replaced with a single tabbed view.

### Updates:
- Icon files are now provided with the distributed files.

### Bug Fixes:
- Crashes caused by some calculation overflows have been fixed.

---
## February 27, 2003 - Release 0.3.0

### New Features:
- The typing of multiple-letter command names has been made easier.
  The return key is no longer needed to finish a command, and hitting
  the tab key auto-completes a partial command.
- Since it is no longer needed for entering commands, the return key
  is now equivalent to the enter key.
- New keys have been added for setting display and angle options.
  \"PLCS\" prompts for the number of decimal places, \"SCI\" toggles
  between fixed and scientific display, and \"DEG\" toggles between
  degree and radian settings. There is also a new status indicator in
  the lower right corner for these options.
- A new \"SHOW\" key temporarily toggles to a scientific display
  showing 12 significant figures. The display goes back to normal
  after the next command or if the \"SHOW\" command is repeated.

---
## May 28, 2002 - Release 0.2.2a

### Bug Fixes:
- A fix of the Windows binary only. Fixes major problems by upgrading
  the library version to PyQt 3.2.4.

---
## May 16, 2002 - Release 0.2.2

### Updates:
- rpCalc has been ported to Qt 3. It now works with both Qt 2.x and
  3.x using the same source code.
- The help/readme file has been rewritten and now includes section
  links.
- The binaries for windows have been updated to Python 2.2 and PyQt
  3.2 (but are still using Qt 2.3 Non-commercial).

---
## March 19, 2002 - Website Update

- This website now looks a little better.  Hopefully, it's more
  user-friendly, too.

---
## September 8, 2001 - Release 0.2.1

### Bug Fixes:
- Fixed a problem with extra views not always updating properly.
- Fixed copying to the clipboard from the history view.

---
## August 30, 2001 - Release 0.2.0

### New Features:
- Extra views listing registers, calculation history and memory values
  were added.
- A popup menu was added to the display.

### Updates:
- Improved error handling.

---
## August 20, 2001 - Release 0.1.2

### Updates:
- The name was changed to rpCalc to avoid conflicts.
- For MS Windows users, the binary files were upgraded to PyQt Version
  2.5.

### Bug Fixes:
- Problems with saving changed options were fixed.

---
## August 10, 2001 - Release 0.1.1

### New Features:
- Added a button to the OPT dialog to view the ReadMe file.

### Updates:
- The rpcalc.ini file on windows was moved to the program directory.

---
## July 2, 2001 - Release 0.1.0

- Initial release.
