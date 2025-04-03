import 'package:flutter/material.dart';

class NoInternetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, color: Colors.white, size: 100),
            SizedBox(height: 20),
            Text("No Internet Connection",
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}
