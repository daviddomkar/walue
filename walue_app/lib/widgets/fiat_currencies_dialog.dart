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
                      currency.name,
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16.0),
                    ),
                    Text(
                      currency.symbol.toUpperCase(),
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16.0),
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
