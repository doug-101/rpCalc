// frame_view.dart, the main view's frame and controls.
// rpCalc, a calculator using reverse polish notation.
// Copyright (c) 2024, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../main.dart' show prefs, saveWindowGeo;
import '../model/engine.dart';
import 'calc_button.dart';
import 'help_view.dart';
import 'history_view.dart';
import 'lcd_display.dart';
import 'memory_view.dart';
import 'settings_edit.dart';

const _backgroundColor = Color(0xFF403020);
const _statusBackgroundColor = Color(0xFF302418);
const _statusTextColor = Color(0xFFd1baa3);
const _statusborderColor = Color(0xFF483624);
const _drawerHeaderColor = Color(0xFFd0a67d);
const _drawerHeaderTextColor = Color(0xFF241b12);

// Command buttons that span rows or columns.
const _doubleRowSpanCmds = {'+', 'ENT'};
const _doubleColumnSpanCmds = {'0'};

const _superscriptCmds = {'x2', 'yX', 'eX', 'tnX'};

/// This provides the window, LCD display, button structure and other controls.
class FrameView extends StatefulWidget {
  const FrameView({super.key});

  @override
  State<FrameView> createState() => _FrameViewState();
}

class _FrameViewState extends State<FrameView> with WindowListener {
  final buttonKeys = <String, GlobalKey>{};

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Programmatically press a button for operation and graphical affect.
  void simulateKeyPress(String keyId) {
    final buttonKey = buttonKeys[keyId]!;
    final renderbox = buttonKey.currentContext!.findRenderObject() as RenderBox;
    final position =
        renderbox.size.center(renderbox.localToGlobal(Offset.zero));
    GestureBinding.instance.handlePointerEvent(
      PointerDownEvent(position: position),
    );
    // await Future.delayed(const Duration(milliseconds: 400));
    GestureBinding.instance.handlePointerEvent(
      PointerUpEvent(position: position),
    );
  }

  /// Open the drawer using the OPT key press.
  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      windowManager.addListener(this);
    }
    final model = Provider.of<Engine>(context, listen: false);
    for (var label in model.operCommands.keys) {
      buttonKeys[label.toUpperCase()] = GlobalKey();
    }
    for (var label in model.numpadCommands.keys) {
      buttonKeys[label.toUpperCase()] = GlobalKey();
    }
    // Set exit command in model to pop this widget.
    // TODO: Test in other platforms.
    model.operCommands['OFF'] = SystemNavigator.pop;
    // Set OPT command to open the drawer.
    model.numpadCommands['OPT'] = openDrawer;
  }

  @override
  void dispose() {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  /// Call main function to save window geometry after a resize.
  @override
  void onWindowResize() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      await saveWindowGeo();
    }
  }

  /// Call main function to save window geometry after a move.
  @override
  void onWindowMove() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      await saveWindowGeo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<Engine>(context, listen: false);
    final ratio = prefs.getDouble('view_scale') ?? 1.0;
    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        child: FractionallySizedBox(
          widthFactor: 1 / ratio,
          heightFactor: 1 / ratio,
          child: Transform.scale(
            scale: ratio,
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: _drawerHeaderColor,
                  ),
                  child: Text(
                    'rpCalc',
                    style: TextStyle(
                      color: _drawerHeaderTextColor,
                      fontSize: 32,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('History View'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryView(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text('Memory View'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MemoryView(),
                      ),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingEdit(),
                      ),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help View'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HelpView(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About rpCalc'),
                  onTap: () async {
                    Navigator.pop(context);
                    final packageInfo = await PackageInfo.fromPlatform();
                    final ratio = prefs.getDouble('view_scale') ?? 1.0;
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return FractionallySizedBox(
                          widthFactor: 1 / ratio,
                          heightFactor: 1 / ratio,
                          child: Transform.scale(
                            scale: ratio,
                            child: AboutDialog(
                              applicationName: 'rpCalc',
                              applicationVersion:
                                  'Version ${packageInfo.version}',
                              applicationLegalese: '©2024 by Douglas W. Bell',
                              applicationIcon:
                                  Image.asset('assets/images/calc_icon_48.png'),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            String? keyStr;
            if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter) {
              keyStr = 'ENT';
            } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
              keyStr = 'BSP';
            } else if (event.logicalKey == LogicalKeyboardKey.escape) {
              keyStr = 'ESC';
            } else if (event.character != null) {
              keyStr = event.character;
            }
            if (keyStr != null) {
              final keyId = model.handleKeyboardEntry(keyStr);
              if (keyId != null) {
                simulateKeyPress(keyId);
              }
            }
          }
          return KeyEventResult.handled;
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          color: _backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 5,
                child: LcdDisplay(),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: LayoutGrid(
                    columnSizes: [auto, auto, auto, auto, auto],
                    rowSizes: [auto, auto, auto, auto, auto, auto],
                    columnGap: 7,
                    rowGap: 9,
                    children: [
                      for (var label in model.operCommands.keys)
                        GridPlacement(
                          child: CalcButton(
                            label: label,
                            buttonKey: buttonKeys[label.toUpperCase()]!,
                            onPressed: model.operCommands[label]!,
                            hasSuperscript: _superscriptCmds.contains(label),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: LayoutGrid(
                    columnSizes: [auto, auto, auto, auto],
                    rowSizes: [auto, auto, auto, auto, auto],
                    columnGap: 7,
                    rowGap: 9,
                    children: [
                      for (var label in model.numpadCommands.keys)
                        GridPlacement(
                          rowSpan: _doubleRowSpanCmds.contains(label) ? 2 : 1,
                          columnSpan:
                              _doubleColumnSpanCmds.contains(label) ? 2 : 1,
                          child: CalcButton(
                            label: label,
                            buttonKey: buttonKeys[label.toUpperCase()]!,
                            onPressed: model.numpadCommands[label]!,
                            heightScaleFactor:
                                _doubleRowSpanCmds.contains(label) ? 0.5 : 1.0,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(width: 4, color: _statusborderColor),
                    borderRadius: BorderRadius.circular(12),
                    color: _statusBackgroundColor,
                  ),
                  child: Consumer<Engine>(
                    builder: (context, model, child) {
                      final numFormat = prefs.getBool('use_fixed_nums') ?? true
                          ? 'fix'
                          : 'sci';
                      final numDecPlaces = prefs.getInt('num_dec_plcs') ?? 4;
                      final angleUnit =
                          prefs.getBool('use_degrees') ?? true ? 'deg' : 'rad';
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.contain,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '> ${model.entryStr}',
                                style: TextStyle(color: _statusTextColor),
                              ),
                            ),
                          ),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.contain,
                              alignment: Alignment.centerRight,
                              child: Text(
                                '$numFormat $numDecPlaces   $angleUnit',
                                style: TextStyle(color: _statusTextColor),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
