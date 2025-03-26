import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
    this.height,
    this.leadingWidth,
    this.leading,
    this.title,
    this.centerTitle,
    this.actions,
  }) : super(
          key: key,
        );

  final double? height;

  final double? leadingWidth;

  final Widget? leading;

  final Widget? title;

  final bool? centerTitle;

  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      toolbarHeight: height ?? 56,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      leadingWidth: leadingWidth ?? 0,
      leading: leading,
      title: title,
      titleSpacing: 0,
      centerTitle: centerTitle ?? false,
      actions: actions,
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => Size(
        double.infinity,
        height ?? 56,
      );
}


class CustomAppBarBuild extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBarBuild({
    Key? key,
    this.height,
    this.leadingWidth,
    this.leading,
    this.title,
    this.centerTitle,
    this.actions,
    this.automaticallyImplyLeading = true, // Default to true
  }) : super(key: key);

  final double? height;
  final double? leadingWidth;
  final Widget? leading;
  final Widget? title;
  final bool? centerTitle;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading; // Add this parameter

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      toolbarHeight: height ?? 56,
      automaticallyImplyLeading: automaticallyImplyLeading, // Pass it here
      backgroundColor: Colors.transparent,
      leadingWidth: leadingWidth ?? 0,
      leading: leading,
      title: title,
      titleSpacing: 0,
      centerTitle: centerTitle ?? false,
      actions: actions,
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => Size(
    double.infinity,
    height ?? 56,
  );
}



class CustomAppBarNumu extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBarNumu({
    Key? key,
    this.height,
    this.leadingWidth,
    this.leading,
    this.title,
    this.centerTitle,
    this.actions,
    this.backgroundColor, // Add background color parameter
  }) : super(key: key);

  final double? height;
  final double? leadingWidth;
  final Widget? leading;
  final Widget? title;
  final bool? centerTitle;
  final List<Widget>? actions;
  final Color? backgroundColor; // Define background color

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      toolbarHeight: height ?? 56,
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor ?? Colors.transparent, // Set background color
      leadingWidth: leadingWidth ?? 0,
      leading: leading,
      title: title,
      titleSpacing: 0,
      centerTitle: centerTitle ?? false,
      actions: actions,
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => Size(
    double.infinity,
    height ?? 56,
  );
}

