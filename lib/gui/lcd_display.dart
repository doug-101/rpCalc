// lcd_display.dart, a widget for the main number display.
// rpCalc, a calculator using reverse polish notation.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/engine.dart';

const _backgroundColor = Color(0xFF807366);
const _textColor = Color(0xFF241b12);
const _borderColor = Color(0xFFc0ad99);

/// Provides the main display for the calculator registers.
class LcdDisplay extends StatelessWidget {
  LcdDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _backgroundColor,
        border: Border.all(width: 6, color: _borderColor),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Consumer<Engine>(
        builder: (context, model, child) {
          return FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                for (var numString in model.previousRegisterStrings())
                  Text(
                    numString,
                    style: TextStyle(
                      fontFamily: 'LCD_16',
                      fontSize: 18,
                      color: _textColor,
                    ),
                  ),
                Text(
                  model.xString,
                  style: TextStyle(
                    fontFamily: 'LCD_16',
                    fontSize: 24,
                    color: _textColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
