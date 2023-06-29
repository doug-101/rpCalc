// button_key.dart, a widget for each calculator button.
// rpCalc, a calculator using reverse polish notation.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/engine.dart';

/// This defines buttons for the calculator GUI.
class ButtonKey extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final GlobalKey buttonKey;
  final bool hasSuperscript;
  final double heightScaleFactor;

  ButtonKey({
    super.key,
    required this.label,
    required this.buttonKey,
    required this.onPressed,
    this.hasSuperscript = false,
    this.heightScaleFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    // Started with an ElevatedButton, but FittedBox didn't expand text.
    return Container(
      key: buttonKey,
      decoration: BoxDecoration(
        border: Border.all(width: 4),
        borderRadius: BorderRadius.circular(18),
      ),
      constraints: BoxConstraints(
        minWidth: double.infinity,
        minHeight: double.infinity,
      ),
      child: InkWell(
        onTap: onPressed,
        child: FractionallySizedBox(
          heightFactor: heightScaleFactor,
          child: FittedBox(
            fit: BoxFit.contain,
            child: hasSuperscript
                ? Text.rich(
                    TextSpan(
                      text: label.substring(0, label.length - 1),
                      children: [
                        WidgetSpan(
                          child: Transform.translate(
                            offset: const Offset(0.0, -4.0),
                            child: Text(
                              label.substring(label.length - 1),
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(label),
          ),
        ),
      ),
    );
  }
}
