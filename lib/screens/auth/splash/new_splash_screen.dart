import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import '../../../utils/theme/colors.dart';
import '../../no_internet/duplicate_screen.dart';
import '../sign_in/landing_register_screen.dart';

class NewSplashScreen extends StatefulWidget {
  const NewSplashScreen({super.key});

  @override
  State<NewSplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<NewSplashScreen> {
  bool _isFirstState = true;
  int _clickCount = 0;
  double _progress = 0.5;

  void _handleButtonClick() {
    setState(() {
      _clickCount++;
      if (_clickCount == 1) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
            const LandingRegisterScreenScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else if (_clickCount == 2) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
            const LandingRegisterScreenScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Detect foldable devices (wider screens)
    final isFoldable = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isFoldable
          ? _buildFoldableLayout()
          : _buildNormalLayout(),
    );
  }

  // Original layout for normal phones
  Widget _buildNormalLayout() {
    return Center(
      child: Padding(
        padding: Platform.isAndroid
            ? const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0)
            : const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              ImageConstant.numuNewSplash1,
            ),
            const SizedBox(height: 40),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Welcome to",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Urbanist',
                      color: _isFirstState
                          ? ColorsContent.newThemeColor
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              " Numu app",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: _isFirstState
                    ? Colors.black
                    : ColorsContent.newThemeColor,
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _handleButtonClick,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
              ),
              child: Image.asset(
                ImageConstant.splashNextIcon,
                width: 80,
                height: 80,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Optimized layout for foldable phones
  Widget _buildFoldableLayout() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top spacer
            const SizedBox(height: 10),

            // Image - flexible to fit available space
            Flexible(
              flex: 5,
              child: Image.asset(
                ImageConstant.numuNewSplash1,
                fit: BoxFit.contain,
                width: screenWidth,
              ),
            ),

            // Bottom content
            Column(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Welcome to",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Urbanist',
                          color: _isFirstState
                              ? ColorsContent.newThemeColor
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  " Numu app",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _isFirstState
                        ? Colors.black
                        : ColorsContent.newThemeColor,
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _handleButtonClick,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                  ),
                  child: Image.asset(
                    ImageConstant.splashNextIcon,
                    width: 75,
                    height: 75,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}