// lcd_display.dart, a widget for the main number display.
// rpCalc, a calculator using reverse polish notation.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/engine.dart';

/// Provides the main display for the calculator registers.
class LcdDisplay extends StatelessWidget {
  LcdDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(width: 6),
        borderRadius: BorderRadius.circular(12),
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
                  Text(numString, style: TextStyle(fontSize: 18)),
                Text(model.xString, style: TextStyle(fontSize: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}
