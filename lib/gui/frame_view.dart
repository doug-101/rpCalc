// frame_view.dart, the main view's frame and controls.
// rpCalc, a calculator using reverse polish notation.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:provider/provider.dart';
import '../main.dart' show prefs;
import '../model/engine.dart';
import 'button_key.dart';
import 'lcd_display.dart';

const _backgroundColor = Color(0xFF404040);
const _statusBackgroundColor = Color(0xFF303030);
const _statusTextColor = Color(0xFFC0C0C0);
const _statusborderColor = Color(0xFF242424);

// Command buttons that span rows or columns.
const _doubleRowSpanCmds = {'+', 'ENT'};
const _doubleColumnSpanCmds = {'0'};

const _superscriptCmds = {'x2', 'yX', 'eX', 'tnX'};

/// This provides the window, LCD display, button structure and other controls.
class FrameView extends StatefulWidget {
  FrameView({super.key});

  @override
  State<FrameView> createState() => _FrameViewState();
}

class _FrameViewState extends State<FrameView> {
  final buttonKeys = <String, GlobalKey>{};

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

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<Engine>(context, listen: false);
    if (buttonKeys.isEmpty) {
      for (var label in model.operCommands.keys) {
        buttonKeys[label.toUpperCase()] = GlobalKey();
      }
      for (var label in model.numpadCommands.keys) {
        buttonKeys[label.toUpperCase()] = GlobalKey();
      }
      // Set exit command in model to pop this widget.
      // TODO: Test in other platforms.
      model.operCommands['OFF'] = SystemNavigator.pop;
    }
    return Scaffold(
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
          padding: const EdgeInsets.all(20),
          color: _backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 6,
                child: LcdDisplay(),
              ),
              Expanded(
                flex: 8,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: LayoutGrid(
                    columnSizes: [auto, auto, auto, auto, auto],
                    rowSizes: [auto, auto, auto, auto, auto, auto],
                    columnGap: 14,
                    rowGap: 16,
                    children: [
                      for (var label in model.operCommands.keys)
                        GridPlacement(
                          child: ButtonKey(
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
                flex: 8,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: LayoutGrid(
                    columnSizes: [auto, auto, auto, auto],
                    rowSizes: [auto, auto, auto, auto, auto],
                    columnGap: 14,
                    rowGap: 16,
                    children: [
                      for (var label in model.numpadCommands.keys)
                        GridPlacement(
                          rowSpan: _doubleRowSpanCmds.contains(label) ? 2 : 1,
                          columnSpan:
                              _doubleColumnSpanCmds.contains(label) ? 2 : 1,
                          child: ButtonKey(
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
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(width: 6, color: _statusborderColor),
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
