import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mentalhelth/screens/no_internet/no_internet_screen.dart';

class ConnectivityWidget extends StatefulWidget {
  final Widget child;

  const ConnectivityWidget({Key? key, required this.child}) : super(key: key);

  @override
  _ConnectivityWidgetState createState() => _ConnectivityWidgetState();
}

class _ConnectivityWidgetState extends State<ConnectivityWidget> {
  late Stream<List<ConnectivityResult>> _connectivityStream;
  List<ConnectivityResult>? _connectionStatus;

  @override
  void initState() {
    super.initState();
    _connectivityStream = Connectivity().onConnectivityChanged;
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _connectionStatus = result; // Ensures _connectionStatus is updated with the latest connectivity state
    });
  }

  bool hasInternet(List<ConnectivityResult>? results) {
    if (results == null || results.isEmpty) return false;
    return results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: _connectivityStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _connectionStatus = snapshot.data;
        }

        if (hasInternet(_connectionStatus)) {
          return widget.child; // Show actual screen when internet is available
        }

        return  NoInternetScreen(); // Show No Internet Screen
      },
    );
  }
}
