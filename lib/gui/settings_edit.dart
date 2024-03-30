// settings_edit.dart, a view to edit the app's preferences.
// rpCalc, a calculator using reverse polish notation.
// Copyright (c) 2024, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../main.dart' show prefs, allowSaveWindowGeo, saveWindowGeo;
import '../model/engine.dart';

/// A user settings view.
class SettingEdit extends StatefulWidget {
  SettingEdit({super.key});

  @override
  State<SettingEdit> createState() => _SettingEditState();
}

class _SettingEditState extends State<SettingEdit> {
  /// A flag showing that the view was forced to close.
  var _cancelFlag = false;

  final _formKey = GlobalKey<FormState>();

  Future<bool> updateOnPop() async {
    if (_cancelFlag) return true;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final model = Provider.of<Engine>(context, listen: false);
      if (model.flag != Mode.entry && model.flag != Mode.exponent) {
        model.updateXString();
      }
      model.notifyListeners();
      return true;
    }
    return false;
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
            title: Text('Settings - rpCalc'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _cancelFlag = true;
                  Navigator.pop(context, null);
                },
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            onWillPop: updateOnPop,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    items: [
                      DropdownMenuItem<String>(
                        value: 'Degrees',
                        child: Text('Degrees'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Radians',
                        child: Text('Radians'),
                      ),
                    ],
                    value: prefs.getBool('use_degrees') ?? true
                        ? 'Degrees'
                        : 'Radians',
                    decoration: const InputDecoration(
                      labelText: 'Angle Unit',
                    ),
                    onChanged: (String? value) => null,
                    onSaved: (String? value) async {
                      if (value != null) {
                        await prefs.setBool('use_degrees', value == 'Degrees');
                      }
                    },
                  ),
                  DropdownButtonFormField<String>(
                    items: [
                      DropdownMenuItem<String>(
                        value: 'Fixed',
                        child: Text('Fixed'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Scientific',
                        child: Text('Scientific'),
                      ),
                    ],
                    value: prefs.getBool('use_fixed_nums') ?? true
                        ? 'Fixed'
                        : 'Scientific',
                    decoration: const InputDecoration(
                      labelText: 'Notation Type',
                    ),
                    onChanged: (String? value) => null,
                    onSaved: (String? value) async {
                      if (value != null) {
                        await prefs.setBool('use_fixed_nums', value == 'Fixed');
                      }
                    },
                  ),
                  TextFormField(
                    initialValue:
                        (prefs.getInt('num_dec_plcs') ?? 4).toString(),
                    decoration: const InputDecoration(
                      labelText: 'Number of Decimal Places',
                    ),
                    validator: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        var places = int.tryParse(value);
                        if (places == null) {
                          return 'Must be an integer';
                        }
                        if (places < 0 || places > 9) {
                          return 'Must be between 0 and 9';
                        }
                      }
                      return null;
                    },
                    onSaved: (String? value) async {
                      if (value != null && value.isNotEmpty) {
                        await prefs.setInt('num_dec_plcs', int.parse(value));
                      }
                    },
                  ),
                  TextFormField(
                    initialValue:
                        (prefs.getInt('store_history_count') ?? 50).toString(),
                    decoration: const InputDecoration(
                      labelText: 'Maximum History Entries',
                    ),
                    validator: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        var count = int.tryParse(value);
                        if (count == null) {
                          return 'Must be an integer';
                        }
                        if (count < 0) {
                          return 'Must be greater than or equal to zero';
                        }
                      }
                      return null;
                    },
                    onSaved: (String? value) async {
                      if (value != null && value.isNotEmpty) {
                        await prefs.setInt(
                            'store_history_count', int.parse(value));
                      }
                    },
                  ),
                  if (kIsWeb)
                    TextFormField(
                      initialValue:
                          (prefs.getDouble('calc_scale') ?? 1.0).toString(),
                      decoration: const InputDecoration(
                        labelText: 'Calculator view scale ratio',
                      ),
                      validator: (String? value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value) == null) {
                            return 'Must be an number';
                          }
                          final scale = double.parse(value);
                          if (scale > 5.0 || scale < 0.2) {
                            return 'Valid range is 0.2 to 5.0';
                          }
                        }
                        return null;
                      },
                      onSaved: (String? value) async {
                        if (value != null && value.isNotEmpty) {
                          await prefs.setDouble(
                              'calc_scale', double.parse(value));
                        }
                      },
                    ),
                  TextFormField(
                    initialValue:
                        (prefs.getDouble('view_scale') ?? 1.0).toString(),
                    decoration: const InputDecoration(
                      labelText: 'Auxilliary View Scale Ratio',
                    ),
                    validator: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        if (double.tryParse(value) == null) {
                          return 'Must be an number';
                        }
                        final scale = double.parse(value);
                        if (scale > 5.0 || scale < 0.2) {
                          return 'Valid range is 0.2 to 5.0';
                        }
                      }
                      return null;
                    },
                    onSaved: (String? value) async {
                      if (value != null && value.isNotEmpty) {
                        await prefs.setDouble(
                            'view_scale', double.parse(value));
                      }
                    },
                  ),
                  if (!kIsWeb &&
                      (defaultTargetPlatform == TargetPlatform.linux ||
                          defaultTargetPlatform == TargetPlatform.windows ||
                          defaultTargetPlatform == TargetPlatform.macOS))
                    BoolFormField(
                      initialValue: prefs.getBool('save_window_geo') ?? true,
                      heading: 'Remember Window Position and Size',
                      onSaved: (bool? value) async {
                        if (value != null) {
                          await prefs.setBool('save_window_geo', value);
                          allowSaveWindowGeo = value;
                          if (allowSaveWindowGeo) saveWindowGeo();
                        }
                      },
                    ),
                  if (!kIsWeb &&
                      (defaultTargetPlatform == TargetPlatform.linux ||
                          defaultTargetPlatform == TargetPlatform.windows ||
                          defaultTargetPlatform == TargetPlatform.macOS))
                    BoolFormField(
                      initialValue: prefs.getBool('show_title_bar') ?? true,
                      heading: 'Show the Window Title Bar',
                      onSaved: (bool? value) async {
                        if (value != null) {
                          await prefs.setBool('show_title_bar', value);
                          await windowManager.setTitleBarStyle(
                            value ? TitleBarStyle.normal : TitleBarStyle.hidden,
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A [FormField] widget for boolean settings.
class BoolFormField extends FormField<bool> {
  BoolFormField({
    bool? initialValue,
    String? heading,
    Key? key,
    FormFieldSetter<bool>? onSaved,
  }) : super(
          onSaved: onSaved,
          initialValue: initialValue,
          key: key,
          builder: (FormFieldState<bool> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    state.didChange(!state.value!);
                  },
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(heading ?? 'Boolean Value'),
                      ),
                      Switch(
                        value: state.value!,
                        onChanged: (bool value) {
                          state.didChange(!state.value!);
                        },
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 3.0,
                  height: 6.0,
                ),
              ],
            );
          },
        );
}
