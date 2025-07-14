import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/core/image_constant.dart';

class NoInternetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              ImageConstant.noInternet,
            ),
            const SizedBox(height: 20),
            const Text("No Internet Connection",
                style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold,fontFamily: 'Poppins',)),
            const SizedBox(height: 10),
            const Text("Please check your internet",
                style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.normal,fontFamily: 'Poppins',)),
            const SizedBox(height: 5),
            const Text("Connection",
                style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.normal,fontFamily: 'Poppins',)),
          ],
        ),
      ),
    );
  }
}
