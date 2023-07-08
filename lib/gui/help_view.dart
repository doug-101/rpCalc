// help_view.dart, shows a view with Markdown output of the README file.
// rpCalc, a calculator using reverse polish notation.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown_selectionarea/flutter_markdown.dart';
import '../main.dart' show prefs;

/// Provides a view with Markdown output of the README file.
class HelpView extends StatefulWidget {
  @override
  State<HelpView> createState() => _HelpViewState();
}

class _HelpViewState extends State<HelpView> {
  String _helpContent = '';

  @override
  void initState() {
    super.initState();
    _loadHelpContent();
  }

  void _loadHelpContent() async {
    _helpContent = await rootBundle.loadString('README.md');
    setState(() {});
  }

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
            title: const Text('Help - TreeTag'),
          ),
          body: SelectionArea(
            child: Markdown(
              data: _helpContent,
              onTapLink: (String text, String? href, String title) async {
                if (href != null) {
                  launchUrl(
                    Uri.parse(href),
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
