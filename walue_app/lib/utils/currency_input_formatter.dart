import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final formatter = NumberFormat.decimalPattern('en');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue.text == newValue.text) {
      return newValue;
    }

    var text = newValue.text;

    if ((text.endsWith('.') && text.split('.').length == 2) || text.isEmpty) {
      return newValue;
    } else if (text.contains('.')) {
      final splitted = text.split('.');

      splitted[0] = splitted[0].replaceAll(RegExp(r'\D'), '');
      splitted[1] = splitted[1].replaceAll(RegExp(r'\D'), '');

      splitted[0] = splitted[0].replaceAll(RegExp(r'^0+(?!$)'), '');

      if (splitted[0].isNotEmpty) {
        splitted[0] = formatter.format(double.parse(splitted[0]));
      }

      text = '${splitted[0]}.${splitted[1]}';
    } else {
      text = text.replaceAll(RegExp(r'\D'), '');
      text = text.replaceAll(RegExp(r'^0+(?!$)'), '');
      text = formatter.format(double.parse(text));
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection(
        baseOffset: oldValue.text.length > newValue.text.length ? newValue.selection.baseOffset.clamp(0, text.length) : text.length,
        extentOffset: oldValue.text.length > newValue.text.length ? newValue.selection.extentOffset.clamp(0, text.length) : text.length,
      ),
    );
  }
}
