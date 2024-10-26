// stack.dart, provides storage and rotation for a stack of 4 numbers.
// rpCalc, a calculator using reverse polish notation.
// Copyright (c) 2024, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'dart:collection';

class Stack extends ListBase<double> {
  final _innerList = <double>[0.0, 0.0, 0.0, 0.0];

  Stack();

  @override
  int get length => _innerList.length;

  @override
  set length(int length) {
    _innerList.length = length;
  }

  @override
  double operator [](int index) => _innerList[index];

  @override
  void operator []=(int index, double value) {
    _innerList[index] = value;
  }

  @override
  void add(double element) => _innerList.add(element);

  @override
  void addAll(Iterable<double> iterable) => _innerList.addAll(iterable);

  /// Replace stack with [values].
  void replaceAll(Iterable<double> values) {
    setAll(0, values);
  }

  /// Replace X & Y registers with [value], pulls stack.
  void replaceXY(double value) {
    removeAt(0);
    this[0] = value;
    add(this[2]);
  }

  /// Push X onto stack into Y register.
  void enterX() {
    insert(0, this[0]);
    removeAt(4);
  }

  /// Roll stack so x = old y, etc.
  void rollBack() {
    final value = removeAt(0);
    add(value);
  }

  /// Roll stack so x = old stack bottom.
  void rollUp() {
    final value = removeAt(3);
    insert(0, value);
  }
}
