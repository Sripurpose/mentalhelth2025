// import 'dart:io';
//
// import 'package:flutter/material.dart';
//
// import 'package:mentalhelth/utils/core/image_constant.dart';
//
// import '../../../utils/theme/colors.dart';
// import '../../no_internet/duplicate_screen.dart';
// import '../sign_in/landing_register_screen.dart';
//
// class NewSplashScreen extends StatefulWidget {
//   const NewSplashScreen({super.key});
//
//   @override
//   State<NewSplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<NewSplashScreen> {
//   bool _isFirstState = true; // Track which state is currently displayed
//   int _clickCount = 0; // Track number of clicks
//   double _progress = 0.5; // Initial progress at 50%
//
//   void _handleButtonClick() {
//     setState(() {
//       _clickCount++;
//
//       if (_clickCount == 1) {
//         _isFirstState = false; // First click: Change image & text
//         _progress = 1.0; // Update progress bar to 100%
//       } else if (_clickCount == 2) {
//         // Second click: Navigate to LandingRegisterScreen
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (context) => const LandingRegisterScreenScreen(),
//           ),
//         );
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ConnectivityWidget(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Center(
//           child: Padding(
//             padding: Platform.isAndroid ?
//             const EdgeInsets.symmetric(vertical: 23.0,horizontal: 10):const EdgeInsets.symmetric(vertical: 0.0,horizontal: 10),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Image.asset(
//                   _isFirstState ? ImageConstant.numuNewSplash1 : ImageConstant.numuNewSplash2, // Change image dynamically
//                 ),
//                 const SizedBox(height: 40),
//
//                 /// 🔹 Progress Bar (Container)
//                 Container(
//                   width: 200,
//                   height: 10,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300], // Background color
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                   alignment: Alignment.centerLeft,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 500),
//                     width: 200 * _progress, // Dynamic width based on progress
//                     height: 10,
//                     decoration: BoxDecoration(
//                       color: ColorsContent.newThemeColor, // Progress color
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 50),
//                 RichText(
//                   text: TextSpan(
//                     children: [
//                       TextSpan(
//                         text: _isFirstState ? "Lorem Ipsum" : "Welcome to",
//                         style: TextStyle(
//                           fontSize: 30,
//                           fontWeight: FontWeight.w800,
//                           fontFamily: 'Urbanist',
//                           color: _isFirstState ? ColorsContent.newThemeColor : Colors.black,
//                         ),
//                       ),
//                        TextSpan(
//                         text: _isFirstState ? " is simply" :"",
//                         style: const TextStyle(
//                           fontSize: 30,
//                           fontWeight: FontWeight.w800,
//                           fontFamily: 'Urbanist',
//                           color: Colors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Text(
//                   _isFirstState ? "dummy text" : "Numu App",
//                   style:  TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.w800,
//                     color: _isFirstState ? Colors.black : ColorsContent.newThemeColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         bottomNavigationBar: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: SizedBox(
//             width: 70,
//             height: 70,
//             child: ElevatedButton(
//               onPressed: _handleButtonClick, // Handle button click logic
//               style: ElevatedButton.styleFrom(
//                 shape: const CircleBorder(),
//               ),
//               child: Image.asset(
//                 ImageConstant.splashNextIcon, // Button icon
//                 width: 80,
//                 height: 80,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



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
  bool _isFirstState = true; // Track which state is currently displayed
  int _clickCount = 0; // Track number of clicks
  double _progress = 0.5; // Initial progress at 50%

  void _handleButtonClick() {
    setState(() {
      _clickCount++;

      if (_clickCount == 1) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const LandingRegisterScreenScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );

      } else if (_clickCount == 2) {
        // Second click: Navigate to LandingRegisterScreen
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const LandingRegisterScreenScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: Platform.isAndroid ?
          const EdgeInsets.symmetric(vertical: 0.0,horizontal: 0):const EdgeInsets.symmetric(vertical: 0.0,horizontal: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
               ImageConstant.numuNewSplash1
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
                        color: _isFirstState ? ColorsContent.newThemeColor : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                " Numu app",
                style:  TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: _isFirstState ? Colors.black : ColorsContent.newThemeColor,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding:  EdgeInsets.symmetric(vertical: Platform.isIOS ? 80.0: 50.0),
        child: SizedBox(
          width: 70,
          height: 70,
          child: ElevatedButton(
            onPressed: _handleButtonClick, // Handle button click logic
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
            ),
            child: Image.asset(
              ImageConstant.splashNextIcon, // Button icon
              width: 80,
              height: 80,
            ),
          ),
        ),
      ),
    );
  }
}
