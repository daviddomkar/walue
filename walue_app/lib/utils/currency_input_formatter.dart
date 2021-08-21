import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:intl/number_symbols_data.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  CurrencyInputFormatter(this.context);

  final BuildContext context;

  static String? valueToString(BuildContext context, double? value) {
    if (value == null) return null;

    final decimal = Decimal.parse(value.toString()).toString();

    final decimalDigits = decimal.contains('.') ? decimal.split('.')[1].length : 0;

    final formatter = NumberFormat.simpleCurrency(locale: context.locale.languageCode, name: '', decimalDigits: decimalDigits);

    return formatter.format(value).trim();
  }

  static double? stringToValue(BuildContext context, String? value) {
    if (value == null || value.isEmpty) return null;

    return NumberFormat.simpleCurrency(locale: context.locale.languageCode).parse(value).toDouble();
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue.text == newValue.text) {
      return newValue;
    }

    var text = newValue.text;

    final decimalSeparator = numberFormatSymbols[context.locale.languageCode]!.DECIMAL_SEP.toString();

    // Remove everything that is not a number or a decimal separator.
    text = text.replaceAll(RegExp('[^0-9$decimalSeparator]'), '');

    if (text.endsWith(decimalSeparator) || text.isEmpty) {
      if (text.endsWith('$decimalSeparator$decimalSeparator')) {
        text = text.substring(0, text.length - 1);
      }

      if (text.endsWith(decimalSeparator)) {
        final usefulPart = text.split(decimalSeparator)[0];

        if (usefulPart.isNotEmpty) {
          text = '${NumberFormat.simpleCurrency(locale: context.locale.languageCode, name: '', decimalDigits: 0).format(stringToValue(context, usefulPart)).trim()}$decimalSeparator';
        }
      }

      return newValue.copyWith(
        text: text,
        selection: TextSelection(
          baseOffset: oldValue.text.length > newValue.text.length ? newValue.selection.baseOffset.clamp(0, text.length) : text.length,
          extentOffset: oldValue.text.length > newValue.text.length ? newValue.selection.extentOffset.clamp(0, text.length) : text.length,
        ),
      );
    }

    if (text.contains(decimalSeparator)) {}

    final value = stringToValue(context, text);

    final decimalDigits = text.contains(decimalSeparator) ? text.split(decimalSeparator)[1].length : 0;

    final formatter = NumberFormat.simpleCurrency(locale: context.locale.languageCode, name: '', decimalDigits: decimalDigits);

    text = formatter.format(value).trim();

    return newValue.copyWith(
      text: text,
      selection: TextSelection(
        baseOffset: oldValue.text.length > newValue.text.length ? newValue.selection.baseOffset.clamp(0, text.length) : text.length,
        extentOffset: oldValue.text.length > newValue.text.length ? newValue.selection.extentOffset.clamp(0, text.length) : text.length,
      ),
    );
  }
}
