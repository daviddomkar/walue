import 'package:flutter/material.dart';
import 'package:walue_app/models/buy_record.dart';
import 'package:walue_app/widgets/add_record_form.dart';

class AddRecordDialog extends StatelessWidget {
  final void Function(BuyRecord record)? onAddRecord;

  const AddRecordDialog({Key? key, this.onAddRecord}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AddRecordForm(
          onAddRecord: onAddRecord,
        ),
      ),
    );
  }
}
