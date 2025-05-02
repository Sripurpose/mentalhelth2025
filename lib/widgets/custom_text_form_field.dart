import 'package:flutter/material.dart';
import 'package:flutter/src/services/text_formatter.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';

import '../utils/theme/colors.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    Key? key,
    this.alignment,
    this.width,
    this.scrollPadding,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.textStyle,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.textInputType = TextInputType.text,
    this.maxLines,
    this.hintText,
    this.hintStyle,
    this.prefix,
    this.prefixConstraints,
    this.suffix,
    this.suffixConstraints,
    this.prefixText,
    this.prefixStyle,
    this.contentPadding,
    this.borderDecoration,
    this.fillColor,
    this.filled = false,
    this.validator,
    this.onChanged,
    this.onTap, // Added onTap parameter
    this.onEditingComplete, // Added onEditingComplete parameter
    this.textAlign,
    this.isValids,
    this.inputFormatters,
    this.readOnly = false,
  }) : super(key: key);

  final Alignment? alignment;
  final double? width;
  final TextEditingController? scrollPadding;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool? autofocus;
  final TextStyle? textStyle;
  final bool? obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final int? maxLines;
  final String? hintText;
  final TextStyle? hintStyle;
  final Widget? prefix;
  final BoxConstraints? prefixConstraints;
  final Widget? suffix;
  final BoxConstraints? suffixConstraints;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final EdgeInsets? contentPadding;
  final InputBorder? borderDecoration;
  final Color? fillColor;
  final bool? filled;
  final FormFieldValidator<String>? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap; // Declare onTap
  final VoidCallback? onEditingComplete; // Declare onEditingComplete
  final TextAlign? textAlign;
  final bool? isValids;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
      alignment: alignment ?? Alignment.center,
      child: textFormFieldWidget(context),
    )
        : textFormFieldWidget(context);
  }

  Widget textFormFieldWidget(BuildContext context) => SizedBox(
    width: width ?? double.maxFinite,
    child: TextFormField(
      textAlign: textAlign ?? TextAlign.start,
      onChanged: onChanged,
      onTap: onTap,
      onEditingComplete: () {
        FocusScope.of(context).unfocus(); // Ensures keyboard is closed
        if (onEditingComplete != null) {
          onEditingComplete!(); // Calls the provided callback
        }
      },
      scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      style: textStyle ?? CustomTextStyles.bodyMediumOnPrimary,
      obscureText: obscureText ?? false,
      textInputAction: textInputAction,
      keyboardType: textInputType,
      maxLines: maxLines ?? 1,
      decoration: decoration,
      validator: validator,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
    ),
  );


  InputDecoration get decoration => InputDecoration(
    hintText: hintText ?? "",
    errorText: isValids == null ? null : isValids! ? null : 'Invalid phone number',
    hintStyle: hintStyle ?? CustomTextStyles.bodyLargeRobotoOnSecondaryContainer,
    prefixIcon: prefix,
    prefixIconConstraints: prefixConstraints,
    suffixIcon: suffix,
    suffixIconConstraints: suffixConstraints,
    isDense: true,
    contentPadding: contentPadding ?? const EdgeInsets.all(11),
    fillColor: fillColor,
    filled: filled,
    prefixText: prefixText,
    prefixStyle: prefixStyle ?? CustomTextStyles.bodyLargeRobotoOnSecondaryContainer,
    border: borderDecoration ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: appTheme.gray500,
            width: 1,
          ),
        ),
    enabledBorder: borderDecoration ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: appTheme.gray500,
            width: 1,
          ),
        ),
    focusedBorder: borderDecoration ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: appTheme.gray700,
            width: 1,
          ),
        ),
  );
}

class CustomTextFormFieldNumu extends StatelessWidget {
  const CustomTextFormFieldNumu({
    Key? key,
    this.alignment,
    this.width,
    this.scrollPadding,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.textStyle,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.textInputType = TextInputType.text,
    this.maxLines,
    this.hintText,
    this.hintStyle,
    this.prefix,
    this.prefixConstraints,
    this.suffix,
    this.suffixConstraints,
    this.prefixText,
    this.prefixStyle,
    this.contentPadding,
    this.borderDecoration,
    this.fillColor,
    this.filled = false,
    this.validator,
    this.onChanged,
    this.onTap, // Added onTap parameter
    this.onEditingComplete, // Added onEditingComplete parameter
    this.textAlign,
    this.isValids,
    this.inputFormatters,
    this.readOnly = false,
  }) : super(key: key);

  final Alignment? alignment;
  final double? width;
  final TextEditingController? scrollPadding;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool? autofocus;
  final TextStyle? textStyle;
  final bool? obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final int? maxLines;
  final String? hintText;
  final TextStyle? hintStyle;
  final Widget? prefix;
  final BoxConstraints? prefixConstraints;
  final Widget? suffix;
  final BoxConstraints? suffixConstraints;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final EdgeInsets? contentPadding;
  final InputBorder? borderDecoration;
  final Color? fillColor;
  final bool? filled;
  final FormFieldValidator<String>? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap; // Declare onTap
  final VoidCallback? onEditingComplete; // Declare onEditingComplete
  final TextAlign? textAlign;
  final bool? isValids;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
      alignment: alignment ?? Alignment.center,
      child: textFormFieldWidget(context),
    )
        : textFormFieldWidget(context);
  }

  Widget textFormFieldWidget(BuildContext context) => SizedBox(
    width: width ?? double.maxFinite,
    child: TextFormField(
      textAlign: textAlign ?? TextAlign.start,
      onChanged: onChanged,
      onTap: onTap,
      onEditingComplete: () {
        FocusScope.of(context).unfocus(); // Ensures keyboard is closed
        if (onEditingComplete != null) {
          onEditingComplete!(); // Calls the provided callback
        }
      },
      scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      style: textStyle ?? CustomTextStyles.bodyMediumOnPrimary,
      obscureText: obscureText ?? false,
      textInputAction: textInputAction,
      keyboardType: textInputType,
      maxLines: maxLines ?? 1,
      decoration: decoration,
      validator: validator,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
    ),
  );


  InputDecoration get decoration => InputDecoration(
    hintText: hintText ?? "",
    errorText: isValids == null ? null : isValids! ? null : 'Invalid phone number',
    hintStyle: hintStyle ?? CustomTextStyles.bodyLargeRobotoOnSecondaryContainer,
    prefixIcon: prefix,
    prefixIconConstraints: prefixConstraints,
    suffixIcon: suffix,
    suffixIconConstraints: suffixConstraints,
    isDense: true,
    contentPadding: contentPadding ?? const EdgeInsets.all(11),
    fillColor: Colors.white, // Background color
    filled: true, // Ensures background color is applied
    prefixText: prefixText,
    prefixStyle: prefixStyle ?? CustomTextStyles.bodyLargeRobotoOnSecondaryContainer,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8), // Curved border radius
      borderSide: BorderSide.none, // Removes border
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8), // Curved border radius
      borderSide: BorderSide.none, // Removes enabled border
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8), // Curved border radius
      borderSide: BorderSide.none, // Removes focused border
    ),
  );


}


class CustomTextFormFieldGoalOrActionDesc extends StatelessWidget {
  const CustomTextFormFieldGoalOrActionDesc({
    Key? key,
    this.alignment,
    this.width,
    this.scrollPadding,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.textStyle,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.textInputType = TextInputType.text,
    this.maxLines,
    this.hintText,
    this.hintStyle,
    this.prefix,
    this.prefixConstraints,
    this.suffix,
    this.suffixConstraints,
    this.prefixText,
    this.prefixStyle,
    this.contentPadding,
    this.borderDecoration,
    this.fillColor,
    this.filled = false,
    this.validator,
    this.onChanged,
    this.onTap, // Added onTap parameter
    this.onEditingComplete, // Added onEditingComplete parameter
    this.textAlign,
    this.isValids,
    this.inputFormatters,
    this.readOnly = false,
  }) : super(key: key);

  final Alignment? alignment;
  final double? width;
  final TextEditingController? scrollPadding;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool? autofocus;
  final TextStyle? textStyle;
  final bool? obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final int? maxLines;
  final String? hintText;
  final TextStyle? hintStyle;
  final Widget? prefix;
  final BoxConstraints? prefixConstraints;
  final Widget? suffix;
  final BoxConstraints? suffixConstraints;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final EdgeInsets? contentPadding;
  final InputBorder? borderDecoration;
  final Color? fillColor;
  final bool? filled;
  final FormFieldValidator<String>? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap; // Declare onTap
  final VoidCallback? onEditingComplete; // Declare onEditingComplete
  final TextAlign? textAlign;
  final bool? isValids;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
      alignment: alignment ?? Alignment.center,
      child: textFormFieldWidget(context),
    )
        : textFormFieldWidget(context);
  }

  Widget textFormFieldWidget(BuildContext context) => SizedBox(
    width: width ?? double.maxFinite,
    child: TextFormField(
      textAlign: textAlign ?? TextAlign.start,
      onChanged: onChanged,
      onTap: onTap,
      onEditingComplete: () {
        FocusScope.of(context).unfocus(); // Ensures keyboard is closed
        if (onEditingComplete != null) {
          onEditingComplete!(); // Calls the provided callback
        }
      },
      scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      style: textStyle ?? CustomTextStyles.bodyMediumOnPrimary,
      obscureText: obscureText ?? false,
      textInputAction: textInputAction,
      keyboardType: textInputType,
      maxLines: maxLines ?? 1,
      decoration: decoration,
      validator: validator,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
    ),
  );


  InputDecoration get decoration => InputDecoration(
    hintText: hintText ?? "",
    errorText: isValids == null ? null : isValids! ? null : 'Invalid phone number',
    hintStyle: hintStyle ?? CustomTextStyles.bodyLargeRobotoOnSecondaryContainer,
    prefixIcon: prefix,
    prefixIconConstraints: prefixConstraints,
    suffixIcon: suffix,
    suffixIconConstraints: suffixConstraints,
    isDense: false, // Ensure padding takes effect
    contentPadding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16), // Increase vertical padding
    fillColor: Colors.white, // Set background color to white
    filled: true, // Ensure fill color is applied
    prefixText: prefixText,
    prefixStyle: prefixStyle ?? CustomTextStyles.bodyLargeRobotoOnSecondaryContainer,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10), // Curve for all four sides
      borderSide: BorderSide.none, // No border
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10), // Apply same curve
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10), // Apply same curve
      borderSide: BorderSide.none,
    ),
  );

}


class CustomTextFormFieldGoalOrActionDescPopUp extends StatelessWidget {
  const CustomTextFormFieldGoalOrActionDescPopUp({
    Key? key,
    this.alignment,
    this.width,
    this.scrollPadding,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.textStyle,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.textInputType = TextInputType.text,
    this.maxLines,
    this.hintText,
    this.hintStyle,
    this.prefix,
    this.prefixConstraints,
    this.suffix,
    this.suffixConstraints,
    this.prefixText,
    this.prefixStyle,
    this.contentPadding,
    this.borderDecoration,
    this.fillColor,
    this.filled = false,
    this.validator,
    this.onChanged,
    this.onTap, // Added onTap parameter
    this.onEditingComplete, // Added onEditingComplete parameter
    this.textAlign,
    this.isValids,
    this.inputFormatters,
    this.readOnly = false,
  }) : super(key: key);

  final Alignment? alignment;
  final double? width;
  final TextEditingController? scrollPadding;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool? autofocus;
  final TextStyle? textStyle;
  final bool? obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final int? maxLines;
  final String? hintText;
  final TextStyle? hintStyle;
  final Widget? prefix;
  final BoxConstraints? prefixConstraints;
  final Widget? suffix;
  final BoxConstraints? suffixConstraints;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final EdgeInsets? contentPadding;
  final InputBorder? borderDecoration;
  final Color? fillColor;
  final bool? filled;
  final FormFieldValidator<String>? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap; // Declare onTap
  final VoidCallback? onEditingComplete; // Declare onEditingComplete
  final TextAlign? textAlign;
  final bool? isValids;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
      alignment: alignment ?? Alignment.center,
      child: textFormFieldWidget(context),
    )
        : textFormFieldWidget(context);
  }

  Widget textFormFieldWidget(BuildContext context) => SizedBox(
    width: width ?? double.maxFinite,
    child: TextFormField(
      textAlign: textAlign ?? TextAlign.start,
      onChanged: onChanged,
      onTap: onTap,
      onEditingComplete: () {
        FocusScope.of(context).unfocus(); // Ensures keyboard is closed
        if (onEditingComplete != null) {
          onEditingComplete!(); // Calls the provided callback
        }
      },
      scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      style: textStyle ?? CustomTextStyles.bodyMediumOnPrimary,
      obscureText: obscureText ?? false,
      textInputAction: textInputAction,
      keyboardType: textInputType,
      maxLines: maxLines ?? 1,
      decoration: decoration,
      validator: validator,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
    ),
  );


  InputDecoration get decoration => InputDecoration(
    hintText: hintText ?? "",
    errorText: isValids == null ? null : isValids! ? null : 'Invalid phone number',
    hintStyle: hintStyle ?? CustomTextStyles.bodyLargeRobotoOnSecondaryContainer,
    prefixIcon: prefix,
    prefixIconConstraints: prefixConstraints,
    suffixIcon: suffix,
    suffixIconConstraints: suffixConstraints,
    isDense: false, // Ensure padding takes effect
    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16), // Increase vertical padding
    fillColor: Colors.white, // Set background color to white
    filled: true, // Ensure fill color is applied
    prefixText: prefixText,
    prefixStyle: prefixStyle ?? CustomTextStyles.bodyLargeRobotoOnSecondaryContainer,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10), // Curve for all four sides
      borderSide: BorderSide.none, // No border
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10), // Apply same curve
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10), // Apply same curve
      borderSide: BorderSide.none,
    ),
  );

}


class CustomTextFormFieldGoalOrActionName extends StatelessWidget {
  const CustomTextFormFieldGoalOrActionName({
    Key? key,
    this.alignment,
    this.width,
    this.scrollPadding,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.textStyle,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.textInputType = TextInputType.text,
    this.maxLines,
    this.hintText,
    this.hintStyle,
    this.prefix,
    this.prefixConstraints,
    this.suffix,
    this.suffixConstraints,
    this.prefixText,
    this.prefixStyle,
    this.contentPadding,
    this.borderDecoration,
    this.fillColor,
    this.filled = false,
    this.validator,
    this.onChanged,
    this.onTap, // Added onTap parameter
    this.onEditingComplete, // Added onEditingComplete parameter
    this.textAlign,
    this.isValids,
    this.inputFormatters,
    this.readOnly = false,
  }) : super(key: key);

  final Alignment? alignment;
  final double? width;
  final TextEditingController? scrollPadding;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool? autofocus;
  final TextStyle? textStyle;
  final bool? obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final int? maxLines;
  final String? hintText;
  final TextStyle? hintStyle;
  final Widget? prefix;
  final BoxConstraints? prefixConstraints;
  final Widget? suffix;
  final BoxConstraints? suffixConstraints;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final EdgeInsets? contentPadding;
  final InputBorder? borderDecoration;
  final Color? fillColor;
  final bool? filled;
  final FormFieldValidator<String>? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap; // Declare onTap
  final VoidCallback? onEditingComplete; // Declare onEditingComplete
  final TextAlign? textAlign;
  final bool? isValids;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
      alignment: alignment ?? Alignment.center,
      child: textFormFieldWidget(context),
    )
        : textFormFieldWidget(context);
  }

  Widget textFormFieldWidget(BuildContext context) => SizedBox(
    width: width ?? double.maxFinite,
    child: TextFormField(
      textAlign: textAlign ?? TextAlign.start,
      onChanged: onChanged,
      onTap: onTap,
      onEditingComplete: () {
        FocusScope.of(context).unfocus(); // Ensures keyboard is closed
        if (onEditingComplete != null) {
          onEditingComplete!(); // Calls the provided callback
        }
      },
      scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      style: textStyle ?? CustomTextStyles.bodyMediumOnPrimary,
      obscureText: obscureText ?? false,
      textInputAction: textInputAction,
      keyboardType: textInputType,
      maxLines: maxLines ?? 1,
      decoration: decoration,
      validator: validator,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
    ),
  );


  InputDecoration get decoration => InputDecoration(
    hintText: hintText ?? "",
    errorText: isValids == null ? null : isValids! ? null : 'Invalid phone number',
    hintStyle: hintStyle ?? CustomTextStyles.bodyLargeRobotoOnSecondaryContainer,
    prefixIcon: prefix,
    prefixIconConstraints: prefixConstraints,
    suffixIcon: suffix,
    suffixIconConstraints: suffixConstraints,
    isDense: false, // Ensure padding takes effect
    contentPadding: contentPadding ?? const EdgeInsets.all(11),
    fillColor: Colors.white, // Set background color to white
    filled: true, // Ensure fill color is applied
    prefixText: prefixText,
    prefixStyle: prefixStyle ?? CustomTextStyles.bodyLargeRobotoOnSecondaryContainer,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10), // Curve for all four sides
      borderSide: BorderSide.none, // No border
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10), // Apply same curve
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10), // Apply same curve
      borderSide: BorderSide.none,
    ),
  );

}

class CustomTextFormFieldEmailAndPasswordNumu extends StatelessWidget {
  const CustomTextFormFieldEmailAndPasswordNumu({
    Key? key,
    this.alignment,
    this.width,
    this.scrollPadding,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.textStyle,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.textInputType = TextInputType.text,
    this.maxLines,
    this.hintText,
    this.hintStyle,
    this.prefix,
    this.prefixConstraints,
    this.suffix,
    this.suffixConstraints,
    this.prefixText,
    this.prefixStyle,
    this.contentPadding,
    this.borderDecoration,
    this.fillColor,
    this.filled = false,
    this.validator,
    this.onChanged,
    this.onTap, // Added onTap parameter
    this.onEditingComplete, // Added onEditingComplete parameter
    this.textAlign,
    this.isValids,
    this.inputFormatters,
    this.readOnly = false,
  }) : super(key: key);

  final Alignment? alignment;
  final double? width;
  final TextEditingController? scrollPadding;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool? autofocus;
  final TextStyle? textStyle;
  final bool? obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final int? maxLines;
  final String? hintText;
  final TextStyle? hintStyle;
  final Widget? prefix;
  final BoxConstraints? prefixConstraints;
  final Widget? suffix;
  final BoxConstraints? suffixConstraints;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final EdgeInsets? contentPadding;
  final InputBorder? borderDecoration;
  final Color? fillColor;
  final bool? filled;
  final FormFieldValidator<String>? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap; // Declare onTap
  final VoidCallback? onEditingComplete; // Declare onEditingComplete
  final TextAlign? textAlign;
  final bool? isValids;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
      alignment: alignment ?? Alignment.center,
      child: textFormFieldWidget(context),
    )
        : textFormFieldWidget(context);
  }

  Widget textFormFieldWidget(BuildContext context) => SizedBox(
    width: width ?? double.maxFinite,
    child: TextFormField(
      textAlign: textAlign ?? TextAlign.start,
      onChanged: onChanged,
      onTap: onTap,
      onEditingComplete: () {
        FocusScope.of(context).unfocus(); // Ensures keyboard is closed
        if (onEditingComplete != null) {
          onEditingComplete!(); // Calls the provided callback
        }
      },
      scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      style: textStyle ?? CustomTextStyles.bodyMediumOnPrimary,
      obscureText: obscureText ?? false,
      textInputAction: textInputAction,
      keyboardType: textInputType,
      maxLines: maxLines ?? 1,
      decoration: decoration,
      validator: validator,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
    ),
  );


  InputDecoration get decoration => InputDecoration(
    hintText: hintText ?? "",
    errorText: isValids == null ? null : isValids! ? null : 'Invalid phone number',
    hintStyle: hintStyle ?? CustomTextStyles.bodyLargeRobotoOnSecondaryContainer,
    prefixIcon: prefix,
    prefixIconConstraints: prefixConstraints,
    suffixIcon: suffix,
    suffixIconConstraints: suffixConstraints,
    isDense: true,
    contentPadding: contentPadding ?? const EdgeInsets.all(14),
    fillColor: Colors.white,
    filled: true, // Ensures background color is applied
    prefixText: prefixText,
    prefixStyle: prefixStyle ?? CustomTextStyles.bodyLargeRobotoOnSecondaryContainer,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5), // Curved border radius
      borderSide: BorderSide.none, // Removes border
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5), // Curved border radius
      borderSide: BorderSide.none, // Removes enabled border
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5), // Curved border radius
      borderSide: BorderSide.none, // Removes focused border
    ),
  );


}




class CustomTextFormFieldEmailAndPasswordNumuEye extends StatefulWidget {
  const CustomTextFormFieldEmailAndPasswordNumuEye({
    Key? key,
    this.alignment,
    this.width,
    this.scrollPadding,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.textStyle,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.textInputType = TextInputType.text,
    this.maxLines,
    this.hintText,
    this.hintStyle,
    this.prefix,
    this.prefixConstraints,
    this.suffix,
    this.suffixConstraints,
    this.prefixText,
    this.prefixStyle,
    this.contentPadding,
    this.borderDecoration,
    this.fillColor,
    this.filled = false,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.textAlign,
    this.isValids,
    this.inputFormatters,
    this.readOnly = false,
  }) : super(key: key);

  final Alignment? alignment;
  final double? width;
  final TextEditingController? scrollPadding;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool? autofocus;
  final TextStyle? textStyle;
  final bool? obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final int? maxLines;
  final String? hintText;
  final TextStyle? hintStyle;
  final Widget? prefix;
  final BoxConstraints? prefixConstraints;
  final Widget? suffix;
  final BoxConstraints? suffixConstraints;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final EdgeInsets? contentPadding;
  final InputBorder? borderDecoration;
  final Color? fillColor;
  final bool? filled;
  final FormFieldValidator<String>? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final TextAlign? textAlign;
  final bool? isValids;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  @override
  State<CustomTextFormFieldEmailAndPasswordNumuEye> createState() =>
      _CustomTextFormFieldEmailAndPasswordNumuEyeState();
}

class _CustomTextFormFieldEmailAndPasswordNumuEyeState
    extends State<CustomTextFormFieldEmailAndPasswordNumuEye> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return widget.alignment != null
        ? Align(
      alignment: widget.alignment!,
      child: _buildTextField(context),
    )
        : _buildTextField(context);
  }

  Widget _buildTextField(BuildContext context) => SizedBox(
    width: widget.width ?? double.infinity,
    child: TextFormField(
      textAlign: widget.textAlign ?? TextAlign.start,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      onEditingComplete: () {
        FocusScope.of(context).unfocus();
        if (widget.onEditingComplete != null) {
          widget.onEditingComplete!();
        }
      },
      scrollPadding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      controller: widget.controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus ?? false,
      style:
      widget.textStyle ?? CustomTextStyles.bodyMediumOnPrimary,
      obscureText: _obscureText,
      textInputAction: widget.textInputAction,
      keyboardType: widget.textInputType,
      maxLines: widget.maxLines ?? 1,
      decoration: _inputDecoration(),
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      readOnly: widget.readOnly,
    ),
  );

  InputDecoration _inputDecoration() => InputDecoration(
    hintText: widget.hintText ?? "",
    errorText: widget.isValids == null
        ? null
        : widget.isValids!
        ? null
        : 'Invalid phone number',
    hintStyle: widget.hintStyle ??
        CustomTextStyles.bodyLargeRobotoOnSecondaryContainer,
    prefixIcon: widget.prefix,
    prefixIconConstraints: widget.prefixConstraints,
    suffixIcon: IconButton(
      icon: Icon(
        _obscureText ? Icons.visibility_off : Icons.visibility,
        color: Colors.grey,
      ),
      onPressed: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
    ),
    suffixIconConstraints: widget.suffixConstraints,
    isDense: true,
    contentPadding: widget.contentPadding ?? const EdgeInsets.all(11),
    fillColor: Colors.white,
    filled: true,
    prefixText: widget.prefixText,
    prefixStyle: widget.prefixStyle ??
        CustomTextStyles.bodyLargeRobotoOnSecondaryContainer,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide.none,
    ),
  );
}



class CustomTextFormFieldPhoneNumberNumu extends StatelessWidget {
  const CustomTextFormFieldPhoneNumberNumu({
    Key? key,
    this.alignment,
    this.width,
    this.scrollPadding,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.textStyle,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.textInputType = TextInputType.text,
    this.maxLines,
    this.hintText,
    this.hintStyle,
    this.prefix,
    this.prefixConstraints,
    this.suffix,
    this.suffixConstraints,
    this.prefixText,
    this.prefixStyle,
    this.contentPadding,
    this.borderDecoration,
    this.fillColor,
    this.filled = false,
    this.validator,
    this.onChanged,
    this.onTap, // Added onTap parameter
    this.onEditingComplete, // Added onEditingComplete parameter
    this.textAlign,
    this.isValids,
    this.inputFormatters,
    this.readOnly = false,
  }) : super(key: key);

  final Alignment? alignment;
  final double? width;
  final TextEditingController? scrollPadding;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool? autofocus;
  final TextStyle? textStyle;
  final bool? obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final int? maxLines;
  final String? hintText;
  final TextStyle? hintStyle;
  final Widget? prefix;
  final BoxConstraints? prefixConstraints;
  final Widget? suffix;
  final BoxConstraints? suffixConstraints;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final EdgeInsets? contentPadding;
  final InputBorder? borderDecoration;
  final Color? fillColor;
  final bool? filled;
  final FormFieldValidator<String>? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap; // Declare onTap
  final VoidCallback? onEditingComplete; // Declare onEditingComplete
  final TextAlign? textAlign;
  final bool? isValids;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
      alignment: alignment ?? Alignment.center,
      child: textFormFieldWidget(context),
    )
        : textFormFieldWidget(context);
  }

  Widget textFormFieldWidget(BuildContext context) => SizedBox(
    width: width ?? double.maxFinite,
    child: TextFormField(
      textAlign: textAlign ?? TextAlign.start,
      onChanged: onChanged,
      onTap: onTap,
      onEditingComplete: () {
        FocusScope.of(context).unfocus(); // Ensures keyboard is closed
        if (onEditingComplete != null) {
          onEditingComplete!(); // Calls the provided callback
        }
      },
      scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      style: textStyle ?? CustomTextStyles.bodyMediumOnPrimary,
      obscureText: obscureText ?? false,
      textInputAction: textInputAction,
      keyboardType: textInputType,
      maxLines: maxLines ?? 1,
      decoration: decoration,
      validator: validator,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
    ),
  );


  InputDecoration get decoration => InputDecoration(
    hintText: hintText ?? "",
    errorText: isValids == null ? null : isValids! ? null : 'Invalid phone number',
    hintStyle: hintStyle ?? CustomTextStyles.bodyLargeRobotoOnSecondaryContainer,
    prefixIcon: prefix,
    prefixIconConstraints: prefixConstraints,
    suffixIcon: suffix,
    suffixIconConstraints: suffixConstraints,
    isDense: true,
    contentPadding: contentPadding ?? const EdgeInsets.all(11),
    fillColor: Colors.white,
    filled: true, // Ensures background color is applied
    prefixText: prefixText,
    prefixStyle: prefixStyle ?? CustomTextStyles.bodyLargeRobotoOnSecondaryContainer,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5), // Curved border radius
      borderSide: BorderSide.none, // Removes border
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5), // Curved border radius
      borderSide: BorderSide.none, // Removes enabled border
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5), // Curved border radius
      borderSide: BorderSide.none, // Removes focused border
    ),
  );


}


class CustomTextFormFieldPhoneNumberFeedbackNumu extends StatelessWidget {
  const CustomTextFormFieldPhoneNumberFeedbackNumu({
    Key? key,
    this.alignment,
    this.width,
    this.scrollPadding,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.textStyle,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.textInputType = TextInputType.text,
    this.maxLines,
    this.hintText,
    this.hintStyle,
    this.prefix,
    this.prefixConstraints,
    this.suffix,
    this.suffixConstraints,
    this.prefixText,
    this.prefixStyle,
    this.contentPadding,
    this.borderDecoration,
    this.fillColor,
    this.filled = false,
    this.validator,
    this.onChanged,
    this.onTap, // Added onTap parameter
    this.onEditingComplete, // Added onEditingComplete parameter
    this.textAlign,
    this.isValids,
    this.inputFormatters,
    this.readOnly = false,
  }) : super(key: key);

  final Alignment? alignment;
  final double? width;
  final TextEditingController? scrollPadding;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool? autofocus;
  final TextStyle? textStyle;
  final bool? obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final int? maxLines;
  final String? hintText;
  final TextStyle? hintStyle;
  final Widget? prefix;
  final BoxConstraints? prefixConstraints;
  final Widget? suffix;
  final BoxConstraints? suffixConstraints;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final EdgeInsets? contentPadding;
  final InputBorder? borderDecoration;
  final Color? fillColor;
  final bool? filled;
  final FormFieldValidator<String>? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap; // Declare onTap
  final VoidCallback? onEditingComplete; // Declare onEditingComplete
  final TextAlign? textAlign;
  final bool? isValids;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
      alignment: alignment ?? Alignment.center,
      child: textFormFieldWidget(context),
    )
        : textFormFieldWidget(context);
  }

  Widget textFormFieldWidget(BuildContext context) => SizedBox(
    width: width ?? double.maxFinite,
    child: TextFormField(
      textAlign: textAlign ?? TextAlign.start,
      onChanged: onChanged,
      onTap: onTap,
      onEditingComplete: () {
        FocusScope.of(context).unfocus(); // Ensures keyboard is closed
        if (onEditingComplete != null) {
          onEditingComplete!(); // Calls the provided callback
        }
      },
      scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      style: textStyle ?? CustomTextStyles.bodyMediumOnPrimary,
      obscureText: obscureText ?? false,
      textInputAction: textInputAction,
      keyboardType: textInputType,
      maxLines: maxLines ?? 1,
      decoration: decoration,
      validator: validator,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
    ),
  );


  InputDecoration get decoration => InputDecoration(
    hintText: hintText ?? "",
    errorText: isValids == null ? null : isValids! ? null : 'Invalid phone number',
    hintStyle: hintStyle ??
        const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          fontFamily: 'Open Sans',
          color: Colors.black,
        ),
    prefixIcon: prefix,
    prefixIconConstraints: prefixConstraints,
    suffixIcon: suffix,
    suffixIconConstraints: suffixConstraints,
    isDense: true,
    contentPadding: contentPadding ?? const EdgeInsets.all(11),
    fillColor: Colors.white, // Background color
    filled: true, // Ensures background color is applied
    prefixText: prefixText,
    prefixStyle: prefixStyle ?? CustomTextStyles.bodyLargeRobotoOnSecondaryContainer,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5), // Curved border radius
      borderSide: BorderSide.none, // Removes border
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5), // Curved border radius
      borderSide: BorderSide.none, // Removes enabled border
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5), // Curved border radius
      borderSide: BorderSide.none, // Removes focused border
    ),
  );


}


/// Extension on [CustomTextFormField] to facilitate inclusion of all types of border style etc
extension TextFormFieldStyleHelper on CustomTextFormField {
  static OutlineInputBorder get fillBlue => OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: BorderSide.none,
      );
}
