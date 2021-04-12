import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/buy_record.dart';
import '../utils/currency_input_formatter.dart';
import 'gradient_button.dart';
import 'w_text_form_field.dart';

class AddRecordForm extends StatefulWidget {
  final void Function(BuyRecord record)? onAddRecord;

  const AddRecordForm({Key? key, this.onAddRecord}) : super(key: key);

  @override
  _AddRecordFormState createState() => _AddRecordFormState();
}

class _AddRecordFormState extends State<AddRecordForm> {
  final _formKey = GlobalKey<FormState>();

  var _buyPrice = '';
  var _amount = '';

  void submitForm() {
    if (_formKey.currentState == null) {
      return;
    }

    if (widget.onAddRecord != null && _formKey.currentState!.validate()) {
      widget.onAddRecord!(
        BuyRecord(
          buyPrice: double.parse(_buyPrice.replaceAll(',', '')),
          amount: double.parse(_amount.replaceAll(',', '')),
        ),
      );
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
              'Add new buy record',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: WTextFormField(
              autofocus: true,
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
              hintText: 'Amount',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                node.unfocus();
                submitForm();
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
          GradientButton(
            onPressed: submitForm,
            child: const Text(
              'Add Record',
              style: TextStyle(
                fontSize: 18.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
