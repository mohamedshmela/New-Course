import 'package:flutter/material.dart';

/*
This widget is a regular textformfield but with fixed border radius so that all textformfields looks like each other
*/

class MyTextFormField extends StatelessWidget {
  const MyTextFormField({
    super.key,
    this.controller,
    required this.hint,
    required this.validator,
    this.onChanged,
    this.initialValue,
    this.readOnly = false,
    this.maxLines,
  });

  final String hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? initialValue;
  final bool readOnly;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hint: Text(hint),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      initialValue: initialValue,
      readOnly: readOnly,
    );
  }
}
