import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/buy_record.dart';
import '../models/crypto_currency.dart';
import '../models/currency.dart';
import '../utils/currency_input_formatter.dart';
import 'basic_button.dart';
import 'gradient_button.dart';
import 'w_text_form_field.dart';

class BuyRecordForm extends StatefulWidget {
  final BuyRecord? initialRecord;
  final Map<String, Currency>? fiatCurrencies;
  final CryptoCurrency? cryptoCurrency;
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

  const BuyRecordForm({
    Key? key,
    this.initialRecord,
    this.fiatCurrencies,
    this.cryptoCurrency,
    this.selectedCurrency,
    this.onAddRecord,
    this.onEditRecord,
    this.onDeleteRecord,
  }) : super(key: key);

  @override
  _BuyRecordFormState createState() => _BuyRecordFormState();
}

class _BuyRecordFormState extends State<BuyRecordForm> {
  final _formKey = GlobalKey<FormState>();

  var _buyPrice = '';
  var _amount = '';

  late Currency _currency;

  @override
  void initState() {
    super.initState();

    if (widget.selectedCurrency != null) {
      _currency = widget.selectedCurrency!;
    }
  }

  void addRecord() {
    if (_formKey.currentState == null) {
      return;
    }

    if (widget.onAddRecord != null && _formKey.currentState!.validate()) {
      widget.onAddRecord!(
        double.parse(_buyPrice.replaceAll(',', '')),
        double.parse(_amount.replaceAll(',', '')),
        _currency,
      );
    }
  }

  void editRecord() {
    if (_formKey.currentState == null) {
      return;
    }

    if (widget.onEditRecord != null && widget.initialRecord != null && _formKey.currentState!.validate()) {
      widget.onEditRecord!(
        widget.initialRecord!.id,
        double.tryParse(_buyPrice.replaceAll(',', '')),
        double.tryParse(_amount.replaceAll(',', '')),
      );
    }
  }

  void deleteRecord() {
    if (widget.onDeleteRecord != null && widget.initialRecord != null) {
      widget.onDeleteRecord!(widget.initialRecord!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    final autoSizeGroup = AutoSizeGroup();

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Text(
              widget.initialRecord != null ? 'Edit buy record' : 'Add new buy record',
              style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: WTextFormField(
              initialValue: CurrencyInputFormatter.valueToString(widget.initialRecord?.buyPrice ?? widget.cryptoCurrency?.fiatPrice),
              autofocus: widget.initialRecord == null,
              hintText: 'Buy price',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              onEditingComplete: () => node.nextFocus(),
              inputFormatters: [
                CurrencyInputFormatter(),
              ],
              onChanged: (value) => _buyPrice = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }

                if (double.tryParse(value.replaceAll(',', '')) == null) {
                  return 'Invalid value';
                }

                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: WTextFormField(
              initialValue: CurrencyInputFormatter.valueToString(widget.initialRecord?.amount),
              hintText: 'Amount',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                node.unfocus();

                if (widget.initialRecord != null) {
                  editRecord();
                } else {
                  addRecord();
                }
              },
              inputFormatters: [
                CurrencyInputFormatter(),
              ],
              onChanged: (value) => _amount = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }

                if (double.tryParse(value.replaceAll(',', '')) == null) {
                  return 'Invalid value';
                }

                return null;
              },
            ),
          ),
          if (widget.fiatCurrencies != null && widget.selectedCurrency != null && widget.onAddRecord != null && widget.initialRecord == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, left: 4.0, right: 4.0),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: _currency.symbol,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                  fontSize: 18.0,
                  fontFamily: Theme.of(context).textTheme.bodyText1!.fontFamily,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                iconDisabledColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                iconEnabledColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                onChanged: (String? newValue) {
                  _currency = widget.fiatCurrencies![newValue]!;
                },
                dropdownColor: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
                items: widget.fiatCurrencies!.keys.map((symbol) {
                  return DropdownMenuItem<String>(
                    value: symbol,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LimitedBox(
                          maxWidth: 130.0,
                          child: AutoSizeText(
                            widget.fiatCurrencies![symbol]!.name,
                            group: autoSizeGroup,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: AutoSizeText(
                            widget.fiatCurrencies![symbol]!.symbol.toUpperCase(),
                            group: autoSizeGroup,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          if (widget.initialRecord == null)
            GradientButton(
              onPressed: addRecord,
              child: const Text(
                'Add',
                style: TextStyle(
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (widget.initialRecord != null)
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: GradientButton(
                      onPressed: editRecord,
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: BasicButton(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      onPressed: deleteRecord,
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}
