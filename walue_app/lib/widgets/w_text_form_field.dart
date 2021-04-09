import 'package:flutter/material.dart';

class WTextFormField extends StatefulWidget {
  final String? hintText;
  final bool? obscureText;
  final String Function(String)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function(String?)? onSaved;
  final void Function()? onEditingComplete;

  const WTextFormField({
    Key? key,
    this.hintText,
    this.obscureText,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onSaved,
    this.onEditingComplete,
  }) : super(key: key);

  @override
  _WTextFormFieldState createState() => _WTextFormFieldState();
}

class _WTextFormFieldState extends State<WTextFormField> {
  FocusNode? _focusNode;

  bool? _dirty;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _dirty = false;

    _focusNode?.addListener(() {
      if (_focusNode != null && _dirty != null && !_focusNode!.hasFocus && !_dirty!) {
        setState(() {
          _dirty = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: _focusNode,
      autovalidateMode: _dirty != null && _dirty! ? AutovalidateMode.always : AutovalidateMode.disabled,
      obscureText: widget.obscureText ?? false,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      onSaved: widget.onSaved,
      onEditingComplete: widget.onEditingComplete,
    );
  }
}
