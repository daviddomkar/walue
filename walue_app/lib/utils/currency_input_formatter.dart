import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  static final _formatter = NumberFormat.decimalPattern('en');

  static String? valueToString(double? value) {
    if (value == null) return null;

    var text = '${_formatter.format(value).split('.')[0]}.${value.toString().split('.')[1]}';

    if (text.endsWith('.0')) {
      text = text.substring(0, text.length - 2);
    }

    return text;
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue.text == newValue.text) {
      return newValue;
    }

    var text = newValue.text;

    text = text.replaceAll(RegExp('[^0-9.,]'), '');

    if (text.endsWith(',')) {
      text = '${text.substring(0, text.length - 1)}.';
    }

    if ((text.endsWith('.') && text.split('.').length == 2) || text.isEmpty) {
      return newValue.copyWith(
          text: text,
          selection: TextSelection(
            baseOffset: oldValue.text.length > newValue.text.length ? newValue.selection.baseOffset.clamp(0, text.length) : text.length,
            extentOffset: oldValue.text.length > newValue.text.length ? newValue.selection.extentOffset.clamp(0, text.length) : text.length,
          ));
    } else if (text.contains('.')) {
      final splitted = text.split('.');

      splitted[0] = splitted[0].replaceAll(RegExp(r'\D'), '');
      splitted[1] = splitted[1].replaceAll(RegExp(r'\D'), '');

      splitted[0] = splitted[0].replaceAll(RegExp(r'^0+(?!$)'), '');

      if (splitted[0].isNotEmpty) {
        splitted[0] = _formatter.format(double.parse(splitted[0]));
      }

      text = '${splitted[0]}.${splitted[1]}';
    } else {
      text = text.replaceAll(RegExp(r'\D'), '');
      text = text.replaceAll(RegExp(r'^0+(?!$)'), '');

      text = _formatter.format(double.parse(text));
    }

    return newValue.copyWith(
        text: text,
        selection: TextSelection(
          baseOffset: oldValue.text.length > newValue.text.length ? newValue.selection.baseOffset.clamp(0, text.length) : text.length,
          extentOffset: oldValue.text.length > newValue.text.length ? newValue.selection.extentOffset.clamp(0, text.length) : text.length,
        ));
  }
}
