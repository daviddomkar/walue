import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/buy_record.dart';
import '../utils/currency_input_formatter.dart';
import 'basic_button.dart';
import 'gradient_button.dart';
import 'w_text_form_field.dart';

class BuyRecordForm extends StatefulWidget {
  final BuyRecord? initialRecord;

  final void Function(double buyPrice, double amount)? onAddRecord;
  final void Function(String id, double? buyPrice, double? amount)? onEditRecord;
  final void Function(String id)? onDeleteRecord;

  const BuyRecordForm({Key? key, this.initialRecord, this.onAddRecord, this.onEditRecord, this.onDeleteRecord}) : super(key: key);

  @override
  _BuyRecordFormState createState() => _BuyRecordFormState();
}

class _BuyRecordFormState extends State<BuyRecordForm> {
  final _formKey = GlobalKey<FormState>();

  var _buyPrice = '';
  var _amount = '';

  void addRecord() {
    if (_formKey.currentState == null) {
      return;
    }

    if (widget.onAddRecord != null && _formKey.currentState!.validate()) {
      widget.onAddRecord!(
        double.parse(_buyPrice.replaceAll(',', '')),
        double.parse(_amount.replaceAll(',', '')),
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

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Text(
              widget.initialRecord != null ? 'Edit buy record' : 'Add new buy record',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: WTextFormField(
              initialValue: CurrencyInputFormatter.valueToString(widget.initialRecord?.buyPrice),
              autofocus: widget.initialRecord == null,
              hintText: 'Buy price',
              keyboardType: TextInputType.number,
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
              keyboardType: TextInputType.number,
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
