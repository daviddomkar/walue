import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final bool autofocus;
  final String? hintText;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function(String?)? onSaved;
  final void Function()? onEditingComplete;

  const WTextFormField({
    Key? key,
    this.controller,
    this.autofocus = false,
    this.hintText,
    this.obscureText = false,
    this.inputFormatters,
    this.validator,
    this.keyboardType,
    this.textInputAction,
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
      controller: widget.controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16.0),
          ),
        ),
        isDense: true,
        hintText: widget.hintText,
      ),
      autofocus: widget.autofocus,
      focusNode: _focusNode,
      autovalidateMode: _dirty != null && _dirty! ? AutovalidateMode.always : AutovalidateMode.disabled,
      obscureText: widget.obscureText,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      onSaved: widget.onSaved,
      onEditingComplete: widget.onEditingComplete,
    );
  }
}
