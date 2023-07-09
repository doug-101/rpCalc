// main.dart, the main app entry point file.
// rpCalc, a calculator using reverse polish notation.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'gui/frame_view.dart';
import 'model/engine.dart';

/// [prefs] is the global shared_preferences instance.
late final SharedPreferences prefs;

/// This is initially false to avoid saving window geometry during setup.
bool allowSaveWindowGeo = false;

void main() async {
  LicenseRegistry.addLicense(
    () => Stream<LicenseEntry>.value(
      const LicenseEntryWithLineBreaks(
        <String>['rpCalc'],
        'rpCalc, Copyright (C) 2023 by Douglas W. Bell\n\n'
        'This program is free software; you can redistribute it and/or modify '
        'it under the terms of the GNU General Public License as published by '
        'the Free Software Foundation; either version 2 of the License, or '
        '(at your option) any later version.\n\n'
        'This program is distributed in the hope that it will be useful, but '
        'WITHOUT ANY WARRANTY; without even the implied warranty of '
        'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU '
        'General Public License for more details.\n\n'
        'You should have received a copy of the GNU General Public License '
        'along with this program; if not, write to the Free Software '
        'Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  '
        '02110-1301, USA.',
      ),
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    var size = Size(500.0, 800.0);
    double? offsetX, offsetY;
    if (prefs.getBool('save_window_geo') ?? true) {
      size = Size(
        prefs.getDouble('win_size_x') ?? 500.0,
        prefs.getDouble('win_size_y') ?? 900.0,
      );
      offsetX = prefs.getDouble('win_pos_x');
      offsetY = prefs.getDouble('win_pos_y');
    }
    // Setting the size twice (early and later) to work around linux problems.
    await windowManager.setSize(size);
    windowManager.waitUntilReadyToShow(null, () async {
      await windowManager.setTitle('rpCalc');
      await windowManager.setMinimumSize(Size(270.0, 600.0));
      await windowManager.setSize(size);
      if (offsetX != null && offsetY != null) {
        await windowManager.setPosition(Offset(offsetX, offsetY));
      }
      await windowManager.show();
      allowSaveWindowGeo = prefs.getBool('save_window_geo') ?? true;
    });
  }
  runApp(
    ChangeNotifierProvider<Engine>(
      create: (context) => Engine(),
      child: MaterialApp(
        title: 'rpCalc',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark,
            seedColor: Colors.brown,
          ),
          useMaterial3: true,
        ),
        home: FrameView(),
      ),
    ),
  );
}
 
Future<void> saveWindowGeo() async {
  if (!allowSaveWindowGeo) return;
  final bounds = await windowManager.getBounds();
  await prefs.setDouble('win_size_x', bounds.size.width);
  await prefs.setDouble('win_size_y', bounds.size.height);
  await prefs.setDouble('win_pos_x', bounds.left);
  await prefs.setDouble('win_pos_y', bounds.top);
}
