import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void showErrorPopupDialog(BuildContext context, String message, Function() onSuccess ) {
  final double screenWidth = MediaQuery.of(context).size.width;
  final double screenHeight = MediaQuery.of(context).size.height;

  Future.delayed(const Duration(seconds: 2), () {
    Navigator.of(context).pop();
    onSuccess();
  });
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          height: screenHeight * 0.3,
          width: screenWidth * 0.4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Ensure the column takes only the minimum required height
              children: [
                DefaultTextStyle(
                  style: const TextStyle(
                    color: Color(0xFF2F2A42),
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFF694C00),
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 0),
                Lottie.asset(
                  'assets/lottie/alert.json',
                  width: screenWidth * 0.22,
                  height: screenHeight * 0.22,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
