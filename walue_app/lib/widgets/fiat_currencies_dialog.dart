import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/currency.dart';

class FiatCurrenciesDialog extends StatelessWidget {
  final List<Currency> currencies;
  final void Function(Currency currency) onCurrencySelected;

  const FiatCurrenciesDialog({required this.currencies, required this.onCurrencySelected, Key? key}) : super(key: key);

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
        child: Column(
          children: currencies.map((currency) {
            return InkWell(
              onTap: () {
                onCurrencySelected(currency);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currency.symbol.tr() == currency.symbol ? currency.name : currency.symbol.tr(),
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white),
                    ),
                    Text(
                      currency.symbol.toUpperCase(),
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
