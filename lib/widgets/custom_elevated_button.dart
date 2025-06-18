import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/widgets/base_button.dart';

import '../utils/theme/theme_helper.dart';

class CustomElevatedButton extends BaseButton {
  const CustomElevatedButton({
    super.key,
    this.decoration,
    this.leftIcon,
    this.rightIcon,
    EdgeInsets? margin,
    VoidCallback? onPressed,
    ButtonStyle? buttonStyle,
    Alignment? alignment,
    TextStyle? buttonTextStyle,
    bool? isDisabled,
    double? height,
    double? width,
    required String text,
    bool? loading,
    this.underline = false,
    this.underLineText = '',
  }) : super(
          text: text,
          onPressed: onPressed,
          buttonStyle: buttonStyle,
          isDisabled: isDisabled,
          buttonTextStyle: buttonTextStyle,
          height: height,
          width: width,
          alignment: alignment,
          margin: margin,
          loading: loading,
          underLine: underline,
          underLineText: underLineText,
        );

  final BoxDecoration? decoration;

  final Widget? leftIcon;

  final Widget? rightIcon;
  final bool underline;
  final String underLineText;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: buildElevatedButtonWidget,
          )
        : buildElevatedButtonWidget;
  }

  Widget get buildElevatedButtonWidget => Container(
        height: height ?? 36,
        width: width ?? double.maxFinite,
        margin: margin,
        decoration: decoration,
        child: ElevatedButton(
          style: buttonStyle ??
              ElevatedButton.styleFrom(
                backgroundColor: ColorsContent.newThemeColor,
              ),
          onPressed: isDisabled ?? false ? null : onPressed ?? () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              leftIcon ?? const SizedBox.shrink(),
              loading == null
                  ? Text(
                      text,
                      style: buttonTextStyle ??
                          CustomTextStyles.bodyLargeRobotoOnSecondaryContainer,
                    )
                  : loading!
                      ? const Padding(
                          padding: EdgeInsets.only(
                            top: 5,
                            bottom: 5,
                          ),
                          child: SpinKitWave(
                            color: Colors.white,
                            size: 25,
                          ),
                        )
                      : Text(
                          text,
                          style: buttonTextStyle ??
                              CustomTextStyles
                                  .bodyLargeRobotoOnSecondaryContainer,
                        ),
              underLine
                  ? Text(
                      underLineText,
                      style: (buttonTextStyle ??
                              CustomTextStyles
                                  .bodyLargeRobotoOnSecondaryContainer)
                          .copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: theme.colorScheme.onSecondaryContainer
                            .withOpacity(1),
                      ),
                    )
                  : const SizedBox(),
              rightIcon ?? const SizedBox.shrink(),
            ],
          ),
        ),
      );
}
