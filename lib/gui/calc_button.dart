// calc_button.dart, a widget for each calculator button.
// rpCalc, a calculator using reverse polish notation.
// Copyright (c) 2024, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/material.dart';

const _backgroundColor = Color(0xFF241b12);
const _textColor = Color(0xFFe6cdb3);
const _borderColor = Color(0xFF807366);
const _shadowColor = Color(0xFF101010);

/// This defines buttons for the calculator GUI.
class CalcButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Key buttonKey;
  final bool hasSuperscript;
  final double heightScaleFactor;

  const CalcButton({
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
        border: Border.all(width: 2, color: _borderColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            offset: Offset(4.0, 4.0),
            blurRadius: 2.0,
          )
        ],
      ),
      constraints: BoxConstraints(
        minWidth: double.infinity,
        minHeight: double.infinity,
      ),
      child: Material(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
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
                        style: TextStyle(color: _textColor),
                        children: [
                          WidgetSpan(
                            child: Transform.translate(
                              offset: const Offset(0.0, -4.0),
                              child: Text(
                                label.substring(label.length - 1),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _textColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyle(color: _textColor),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
