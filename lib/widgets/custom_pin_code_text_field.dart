import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

// ignore: must_be_immutable
class CustomPinCodeTextField extends StatelessWidget {
  CustomPinCodeTextField({
    Key? key,
    required this.context,
    required this.onChanged,
    this.alignment,
    this.controller,
    this.textStyle,
    this.hintStyle,
    this.validator,
  }) : super(
          key: key,
        );

  final Alignment? alignment;

  final BuildContext context;

  final TextEditingController? controller;

  final TextStyle? textStyle;

  final TextStyle? hintStyle;

  Function(String) onChanged;

  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: pinCodeTextFieldWidget,
          )
        : pinCodeTextFieldWidget;
  }

  Widget get pinCodeTextFieldWidget => PinCodeTextField(
    appContext: context,
    controller: controller,
    length: 6,
    keyboardType: TextInputType.number,
    textStyle: textStyle,
    hintStyle: hintStyle,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
    ],
    enableActiveFill: true,
    pinTheme: PinTheme(
      fieldHeight: 40,
      fieldWidth: 43,
      shape: PinCodeFieldShape.box,
      borderRadius: BorderRadius.circular(5),
      inactiveColor: Colors.transparent, // Removes inactive border
      activeColor: Colors.transparent, // Removes active border
      selectedColor: Colors.transparent, // Removes selected border
      inactiveFillColor:
      theme.colorScheme.onSecondaryContainer.withOpacity(1),
      activeFillColor:
      theme.colorScheme.onSecondaryContainer.withOpacity(1),
      selectedFillColor:
      theme.colorScheme.onSecondaryContainer.withOpacity(1),
    ),
    onChanged: (value) => onChanged(value),
    validator: validator,
  );

}
