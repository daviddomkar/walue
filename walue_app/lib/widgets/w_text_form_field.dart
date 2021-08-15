import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
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
    this.initialValue,
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
      initialValue: widget.initialValue,
      controller: widget.controller,
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.light ? const Color(0x80222222) : const Color(0x80FFFFFF)),
          borderRadius: const BorderRadius.all(
            Radius.circular(16.0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2.0, color: Theme.of(context).brightness == Brightness.light ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondary),
          borderRadius: const BorderRadius.all(
            Radius.circular(16.0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.light ? const Color(0x80222222) : const Color(0x80FFFFFF)),
          borderRadius: const BorderRadius.all(
            Radius.circular(16.0),
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.all(
            Radius.circular(16.0),
          ),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(width: 2.0, color: Colors.red),
          borderRadius: BorderRadius.all(
            Radius.circular(16.0),
          ),
        ),
        isDense: true,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.light ? const Color(0x80222222) : const Color(0x80FFFFFF)),
        errorStyle: const TextStyle(
          color: Colors.red,
        ),
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
