import 'package:flutter/material.dart';
import 'package:walue_app/widgets/w_text_form_field.dart';

class AddRecordForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  AddRecordForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          WTextFormField(),
        ],
      ),
    );
  }
}
