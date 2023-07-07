// history_view.dart, an extra view showing a history list.
// rpCalc, a calculator using reverse polish notation.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show prefs;
import '../model/engine.dart';

/// This provides a list with calculation history.
class HistoryView extends StatefulWidget {
  HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<Engine>(context, listen: false);
    final ratio = prefs.getDouble('view_scale') ?? 1.0;
    return FractionallySizedBox(
      widthFactor: 1 / ratio,
      heightFactor: 1 / ratio,
      child: Transform.scale(
        scale: ratio,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('History - rpCalc'),
          ),
          body: SingleChildScrollView(
            child: DataTable(
              headingTextStyle: TextStyle(fontWeight: FontWeight.bold),
              columns: const <DataColumn>[
                DataColumn(
                  label: Text('Equation'),
                ),
                DataColumn(
                  label: Text('Result'),
                ),
              ],
              rows: <DataRow>[
                for (var item in model.historyList)
                  DataRow(
                    cells: <DataCell>[
                      DataCell(SelectableText(item.eqn)),
                      DataCell(SelectableText(formatNumber(item.result))),
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
