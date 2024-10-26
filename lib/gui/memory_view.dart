// memory_view.dart, an extra view showing a memory register list.
// rpCalc, a calculator using reverse polish notation.
// Copyright (c) 2024, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/material.dart';
import '../main.dart' show prefs;
import '../model/engine.dart';

/// This provides a list with calculation history.
class MemoryView extends StatefulWidget {
  const MemoryView({super.key});

  @override
  State<MemoryView> createState() => _MemoryViewState();
}

class _MemoryViewState extends State<MemoryView> {
  @override
  Widget build(BuildContext context) {
    final ratio = prefs.getDouble('view_scale') ?? 1.0;
    return FractionallySizedBox(
      widthFactor: 1 / ratio,
      heightFactor: 1 / ratio,
      child: Transform.scale(
        scale: ratio,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Memory - rpCalc'),
          ),
          body: SingleChildScrollView(
            child: DataTable(
              headingTextStyle: TextStyle(fontWeight: FontWeight.bold),
              columns: const <DataColumn>[
                DataColumn(
                  label: Text('Number'),
                ),
                DataColumn(
                  label: Text('Value'),
                ),
              ],
              rows: <DataRow>[
                for (var i = 0; i < 10; i++)
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text(i.toString())),
                      DataCell(
                        SelectableText(
                          formatNumber(prefs.getDouble('memory$i') ?? 0.0),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
