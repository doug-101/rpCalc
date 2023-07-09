// engine.dart, provides the model for the main calcualtions and storage.
// rpCalc, a calculator using reverse polish notation.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

// foundation.dart includes [ChangeNotifier].
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../main.dart' show prefs;
import 'stack.dart';

enum Mode {
  entry,
  save,
  replace,
  exponent,
  memStore,
  memRecall,
  decPlaces,
  error,
}

/// This provides the core functionality of the RPN calculator.
class Engine extends ChangeNotifier {
  final operCommands = <String, VoidCallback>{};
  final numpadCommands = <String, VoidCallback>{};
  final allCommands = <String, VoidCallback>{};

  final stack = Stack();
  late String xString;
  var flag = Mode.save;
  var entryStr = '';
  var showMode = false;
  final historyList = <({String eqn, double result})>[];

  Engine() {
    operCommands['x2'] = squareEntry;
    operCommands['sqRT'] = squareRootEntry;
    operCommands['yX'] = powerOfEntry;
    operCommands['xRT'] = rootOfEntry;
    operCommands['RCIP'] = reciprocalEntry;
    operCommands['SIN'] = sinEntry;
    operCommands['COS'] = cosEntry;
    operCommands['TAN'] = tanEntry;
    operCommands['LN'] = logEntry;
    operCommands['eX'] = invLogEntry;
    operCommands['ASIN'] = asinEntry;
    operCommands['ACOS'] = acosEntry;
    operCommands['ATAN'] = atanEntry;
    operCommands['LOG'] = log10Entry;
    operCommands['tnX'] = invLog10Entry;
    operCommands['STO'] = memStore;
    operCommands['RCL'] = memRecall;
    operCommands['R<'] = rollBackEntry;
    operCommands['R>'] = rollForwardEntry;
    operCommands['x<>y'] = exchangeEntry;
    operCommands['SHOW'] = showEntry;
    operCommands['CLR'] = clearEntry;
    operCommands['PLCS'] = decPlacesEntry;
    operCommands['SCI'] = sciNotationEntry;
    operCommands['DEG'] = degreeEntry;
    // Off command is set from the frame view.
    operCommands['OFF'] = () {};
    operCommands['Pi'] = piEntry;
    operCommands['EE'] = expEntry;
    operCommands['CHS'] = changeSignEntry;
    operCommands['<-'] = backspaceEntry;
    numpadCommands['OPT'] = () {};
    numpadCommands['/'] = divideEntry;
    numpadCommands['*'] = multiplyEntry;
    numpadCommands['-'] = subtractEntry;
    numpadCommands['7'] = digitEntry('7');
    numpadCommands['8'] = digitEntry('8');
    numpadCommands['9'] = digitEntry('9');
    numpadCommands['+'] = plusEntry;
    numpadCommands['4'] = digitEntry('4');
    numpadCommands['5'] = digitEntry('5');
    numpadCommands['6'] = digitEntry('6');
    numpadCommands['1'] = digitEntry('1');
    numpadCommands['2'] = digitEntry('2');
    numpadCommands['3'] = digitEntry('3');
    numpadCommands['ENT'] = enterEntry;
    numpadCommands['0'] = digitEntry('0');
    numpadCommands['.'] = digitEntry('.');

    allCommands.addAll(operCommands);
    // Add uppercase versions to map to allow keyboard entry.
    for (var key in operCommands.keys) {
      allCommands[key.toUpperCase()] = operCommands[key]!;
    }
    allCommands.addAll(numpadCommands);

    readStoredStack();
    updateXString();
  }

  /// Reads the stored stack values from shared_preferences.
  void readStoredStack() {
    for (var i = 0; i < 4; i++) {
      stack[i] = prefs.getDouble('stack$i') ?? 0.0;
    }
  }

  /// Writes the stored stack values to shared_preferences.
  void writeStoredStack() async {
    for (var i = 0; i < 4; i++) {
      prefs.setDouble('stack$i', stack[i]);
    }
  }

  /// Set [xString] based on current stack value.
  ///
  /// Also clears show mode and stores the stack in shared_preferences.
  void updateXString() {
    if (!stack[0].isFinite) {
      flag = Mode.error;
      xString = stack[0].isInfinite ? 'Error 9' : 'Error 0';
      readStoredStack();
      return;
    }
    xString = formatNumber(stack[0]);
    showMode = false;
    writeStoredStack();
    if (historyList.length > (prefs.getInt('store_history_count') ?? 50)) {
      historyList.removeRange(
        0,
        historyList.length - (prefs.getInt('store_history_count') ?? 50),
      );
    }
  }

  /// Set [stack[0]] based on [numString], return true on success.
  bool setStackFromString(String numString) {
    final value = double.tryParse(numString.replaceAll(' ', ''));
    if (value != null) {
      stack[0] = value;
      return true;
    }
    return false;
  }

  /// Return list of strings for three previous registers, in reverse order.
  List<String> previousRegisterStrings() {
    return <String>[
      for (var value in List.of(stack.skip(1)).reversed) formatNumber(value),
    ];
  }

  /// Return true if the mode should disable most commands.
  ///
  /// Also cancels error mode.
  bool inDisabledCommandMode() {
    if (flag == Mode.error) {
      flag = Mode.save;
      updateXString();
      notifyListeners();
      return true;
    }
    if (flag.index >= Mode.memStore.index) {
      return true;
    }
    return false;
  }

  /// Return a command string resulting from a single key press.
  ///
  /// The key press can be combined with [entryStr].
  String? handleKeyboardEntry(String ch) {
    if (entryStr.isEmpty && allCommands.containsKey(ch.toUpperCase())) {
      return ch.toUpperCase();
    }
    if (ch == 'BSP') {
      if (flag.index >= Mode.memStore.index) {
        // Cancel special modes.
        flag = Mode.save;
        updateXString();
        notifyListeners();
        return null;
      }
      if (entryStr.isNotEmpty) {
        entryStr = entryStr.substring(0, entryStr.length - 1);
        notifyListeners();
        return null;
      } else {
        return '<-';
      }
    }
    if (ch == 'ESC') {
      if (flag.index >= Mode.memStore.index) {
        // Cancel special modes.
        flag = Mode.save;
        updateXString();
        notifyListeners();
        return null;
      }
      if (entryStr.isNotEmpty) {
        entryStr = '';
        notifyListeners();
      }
      return null;
    }
    if (inDisabledCommandMode()) return null;
    if (ch == '\t') {
      if (entryStr.isNotEmpty) {
        try {
          var cmd = allCommands.keys
              .singleWhere((key) => key.startsWith(entryStr.toUpperCase()));
          entryStr = '';
          notifyListeners();
          return cmd.toUpperCase();
        } on StateError {}
      }
      return null;
    }
    var newStr = '$entryStr$ch'.toUpperCase();
    if (entryStr.isNotEmpty && allCommands.containsKey(newStr)) {
      entryStr = '';
      notifyListeners();
      return newStr;
    }
    if (allCommands.keys.any((key) => key.startsWith(newStr))) {
      entryStr = '$entryStr$ch';
      notifyListeners();
      return null;
    }
  }

  /// Closure to handle number digit and decimal point entry.
  VoidCallback digitEntry(String digitStr) {
    return () {
      if (flag == Mode.error) {
        flag = Mode.save;
        updateXString();
        notifyListeners();
        return;
      }
      if (flag.index >= Mode.memStore.index) {
        if (digitStr != '.') {
          if (flag == Mode.decPlaces) {
            setDecPlaces(int.parse(digitStr));
          } else if (flag == Mode.memStore) {
            storeInMem(int.parse(digitStr));
          } else if (flag == Mode.memRecall) {
            recallFromMem(int.parse(digitStr));
          }
        }
        return;
      }
      if (flag == Mode.save) stack.enterX();
      var newXStr = '';
      if (flag == Mode.entry || flag == Mode.exponent) {
        newXStr = xString + digitStr;
      } else if (digitStr == '.') {
        newXStr = '0.';
      } else {
        newXStr = digitStr;
      }
      if (setStackFromString(newXStr)) {
        xString = newXStr;
        if (flag != Mode.exponent) flag = Mode.entry;
        notifyListeners();
      }
    };
  }

  /// Handle an ENT key press.
  void enterEntry() {
    if (inDisabledCommandMode()) return;
    stack.enterX();
    flag = Mode.replace;
    updateXString();
    notifyListeners();
  }

  /// Handle a plus key press.
  void plusEntry() {
    if (inDisabledCommandMode()) return;
    var eqn = '${formatNumber(stack[1])} + ${formatNumber(stack[0])}';
    stack.replaceXY(stack[1] + stack[0]);
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a subtract key press.
  void subtractEntry() {
    if (inDisabledCommandMode()) return;
    var eqn = '${formatNumber(stack[1])} - ${formatNumber(stack[0])}';
    stack.replaceXY(stack[1] - stack[0]);
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a multiply key press.
  void multiplyEntry() {
    if (inDisabledCommandMode()) return;
    var eqn = '${formatNumber(stack[1])} * ${formatNumber(stack[0])}';
    stack.replaceXY(stack[1] * stack[0]);
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a divide key press.
  void divideEntry() {
    if (inDisabledCommandMode()) return;
    var eqn = '${formatNumber(stack[1])} / ${formatNumber(stack[0])}';
    stack.replaceXY(stack[1] / stack[0]);
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle an x^2 key press.
  void squareEntry() {
    if (inDisabledCommandMode()) return;
    var eqn = '${formatNumber(stack[0])}^2';
    stack[0] = stack[0] * stack[0];
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a square root.
  void squareRootEntry() {
    if (inDisabledCommandMode()) return;
    var eqn = 'SQRT(${formatNumber(stack[0])})';
    stack[0] = sqrt(stack[0]);
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle an arbitrary power key press.
  void powerOfEntry() {
    if (inDisabledCommandMode()) return;
    var eqn = '(${formatNumber(stack[1])})^${formatNumber(stack[0])}';
    stack[0] = pow(stack[1], stack[0]).toDouble();
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle an arbitrary root key press.
  void rootOfEntry() {
    if (inDisabledCommandMode()) return;
    var eqn = '(${formatNumber(stack[1])})^(1/${formatNumber(stack[0])})';
    stack[0] = pow(stack[1], 1 / stack[0]).toDouble();
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a reciprocal key press.
  void reciprocalEntry() {
    if (inDisabledCommandMode()) return;
    var eqn = '1 / ${formatNumber(stack[0])}';
    stack[0] = 1 / stack[0];
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a SIN key press.
  void sinEntry() {
    if (inDisabledCommandMode()) return;
    var eqn = 'sin(${formatNumber(stack[0])})';
    stack[0] = sin(
      prefs.getBool('use_degrees') ?? true ? stack[0] * pi / 180 : stack[0],
    );
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a COS key press.
  void cosEntry() {
    if (inDisabledCommandMode()) return;
    var eqn = 'cos(${formatNumber(stack[0])})';
    stack[0] = cos(
      prefs.getBool('use_degrees') ?? true ? stack[0] * pi / 180 : stack[0],
    );
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a TAN key press.
  void tanEntry() {
    if (inDisabledCommandMode()) return;
    var eqn = 'tan(${formatNumber(stack[0])})';
    stack[0] = tan(
      prefs.getBool('use_degrees') ?? true ? stack[0] * pi / 180 : stack[0],
    );
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a LN key press for a natural log.
  void logEntry() {
    if (inDisabledCommandMode()) return;
    var eqn = 'ln(${formatNumber(stack[0])})';
    stack[0] = log(stack[0]);
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a e^X key press for an inverse natural log.
  void invLogEntry() {
    if (inDisabledCommandMode()) return;
    var eqn = 'e^${formatNumber(stack[0])}';
    stack[0] = exp(stack[0]);
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a ASIN key press.
  void asinEntry() {
    if (inDisabledCommandMode()) return;
    var eqn = 'asin(${formatNumber(stack[0])})';
    stack[0] = asin(stack[0]) /
        (prefs.getBool('use_degrees') ?? true ? pi / 180 : 1.0);
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a ACOS key press.
  void acosEntry() {
    if (inDisabledCommandMode()) return;
    var eqn = 'acos(${formatNumber(stack[0])})';
    stack[0] = acos(stack[0]) /
        (prefs.getBool('use_degrees') ?? true ? pi / 180 : 1.0);
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a ATAN key press.
  void atanEntry() {
    if (inDisabledCommandMode()) return;
    var eqn = 'atan(${formatNumber(stack[0])})';
    stack[0] = atan(stack[0]) /
        (prefs.getBool('use_degrees') ?? true ? pi / 180 : 1.0);
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a LOG key press for a base 10 log.
  void log10Entry() {
    if (inDisabledCommandMode()) return;
    var eqn = 'log(${formatNumber(stack[0])})';
    stack[0] = log(stack[0]) / ln10;
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a tn^X key press for an inverse base 10 log.
  void invLog10Entry() {
    if (inDisabledCommandMode()) return;
    var eqn = '10^${formatNumber(stack[0])}';
    stack[0] = pow(10.0, stack[0]).toDouble();
    historyList.add((eqn: eqn, result: stack[0]));
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a memory store key press.
  void memStore() {
    flag = Mode.memStore;
    xString = '0-9:';
    notifyListeners();
  }

  void storeInMem(int pos) async {
    prefs.setDouble('memory$pos', stack[0]);
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a memory recall key press.
  void memRecall() {
    flag = Mode.memRecall;
    xString = '0-9:';
    notifyListeners();
  }

  void recallFromMem(int pos) {
    stack[0] = prefs.getDouble('memory$pos') ?? 0.0;
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a roll stack back key press.
  void rollBackEntry() {
    if (inDisabledCommandMode()) return;
    stack.rollBack();
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a roll stack forward key press.
  void rollForwardEntry() {
    if (inDisabledCommandMode()) return;
    stack.rollUp();
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle an x exchange y key press.
  void exchangeEntry() {
    if (inDisabledCommandMode()) return;
    final tmpVar = stack[0];
    stack[0] = stack[1];
    stack[1] = tmpVar;
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a show key press.
  void showEntry() {
    if (showMode) {
      updateXString();
      showMode = false;
    } else {
      xString = formatNumber(stack[0], useFixed: false, numDecPlaces: 12);
      showMode = true;
    }
    notifyListeners();
  }

  /// Handle a clear key press.
  void clearEntry() {
    if (inDisabledCommandMode()) return;
    stack.replaceAll([0.0, 0.0, 0.0, 0.0]);
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle a decimal places key press.
  void decPlacesEntry() {
    flag = Mode.decPlaces;
    xString = '0-9:';
    notifyListeners();
  }

  /// Change decimal places from entered number.
  void setDecPlaces(int numPlaces) async {
    await prefs.setInt('num_dec_plcs', numPlaces);
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle FIX / SCI swap key press.
  void sciNotationEntry() async {
    if (inDisabledCommandMode()) return;
    await prefs.setBool(
      'use_fixed_nums',
      !(prefs.getBool('use_fixed_nums') ?? true),
    );
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Kandle DEG / RAD swap key press.
  void degreeEntry() async {
    if (inDisabledCommandMode()) return;
    await prefs.setBool(
      'use_degrees',
      !(prefs.getBool('use_degrees') ?? true),
    );
    flag = Mode.save;
    notifyListeners();
  }

  /// Handle pi constant key press.
  void piEntry() {
    if (inDisabledCommandMode()) return;
    stack.enterX();
    stack[0] = pi;
    flag = Mode.save;
    updateXString();
    notifyListeners();
  }

  /// Handle exponent key press.
  void expEntry() {
    if (inDisabledCommandMode()) return;
    if (flag == Mode.exponent) return;
    if (flag == Mode.entry) {
      xString = '$xString E 0';
    } else {
      if (flag == Mode.save) stack.enterX();
      stack[0] = 1.0;
      xString = '1 E 0';
    }
    flag = Mode.exponent;
    notifyListeners();
  }

  /// Handle change sign key press.
  void changeSignEntry() {
    if (inDisabledCommandMode()) return;
    if (flag == Mode.exponent) {
      if (xString.contains('E-')) {
        xString = xString.replaceFirst('E-', 'E ');
      } else {
        xString = xString.replaceFirst('E ', 'E-');
      }
    } else {
      if (xString.startsWith('-')) {
        xString = xString.substring(1);
      } else {
        xString = '-$xString';
      }
    }
    setStackFromString(xString);
    notifyListeners();
  }

  /// Handle backspace key press.
  void backspaceEntry() {
    print(flag);
    if (flag.index >= Mode.memStore.index) {
      // Cancel special modes.
      flag = Mode.save;
      updateXString();
    } else if (flag == Mode.entry && xString.length > 1) {
      xString = xString.substring(0, xString.length - 1);
      setStackFromString(xString);
    } else if (flag == Mode.exponent) {
      final ePos = xString.indexOf('E');
      if (xString.length - ePos > 3) {
        xString = xString.substring(0, xString.length - 1);
      } else {
        xString = xString.substring(0, ePos - 1);
        flag = Mode.entry;
      }
      setStackFromString(xString);
    } else {
      stack[0] = 0.0;
      flag = Mode.replace;
      updateXString();
    }
    notifyListeners();
  }
}

/// Format the given number using current option settings.
///
/// Use system preferences if [useFixed] and [numDecPlaces] are not given.
String formatNumber(double number, {bool? useFixed, int? numDecPlaces}) {
  if (useFixed == null) {
    useFixed = prefs.getBool('use_fixed_nums') ?? true;
  }
  if (numDecPlaces == null) {
    numDecPlaces = prefs.getInt('num_dec_plcs') ?? 4;
  }
  final absNumber = number.abs();
  var exp = 0;
  if (absNumber != 0.0 &&
      (absNumber < pow(10.0, -min(numDecPlaces, 4)) ||
          absNumber > 1e7 ||
          !useFixed)) {
    exp = (log(absNumber) / ln10).floor();
    number /= pow(10.0, exp);
    // Round the number to see if rounding should bump the exponent.
    number = (number * pow(10.0, numDecPlaces)).roundToDouble() /
        pow(10.0, numDecPlaces);
    if (number.abs() >= 10.0) {
      number /= 10.0;
      exp += 1;
    }
  }
  var numberStr = number.toStringAsFixed(numDecPlaces);
  if (exp != 0 || !useFixed) {
    numberStr = exp >= 0
        ? '${numberStr} E ${exp.toString().padLeft(3, '0')}'
        : '${numberStr} E-${exp.abs().toString().padLeft(3, '0')}';
  }
  return numberStr;
}
