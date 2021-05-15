import 'package:flutter/material.dart';

import '../models/buy_record.dart';
import '../models/currency.dart';
import 'buy_record_form.dart';

class BuyRecordDialog extends StatelessWidget {
  final BuyRecord? initialRecord;
  final Map<String, Currency>? fiatCurrencies;
  final Currency? selectedCurrency;

  final void Function(
    double buyPrice,
    double amount,
    Currency currency,
  )? onAddRecord;

  final void Function(
    String id,
    double? buyPrice,
    double? amount,
  )? onEditRecord;

  final void Function(String id)? onDeleteRecord;

  const BuyRecordDialog({
    Key? key,
    this.initialRecord,
    this.fiatCurrencies,
    this.selectedCurrency,
    this.onAddRecord,
    this.onEditRecord,
    this.onDeleteRecord,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16.0),
        ),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BuyRecordForm(
            initialRecord: initialRecord,
            fiatCurrencies: fiatCurrencies,
            selectedCurrency: selectedCurrency,
            onAddRecord: onAddRecord,
            onEditRecord: onEditRecord,
            onDeleteRecord: onDeleteRecord,
          ),
        ),
      ),
    );
  }
}
