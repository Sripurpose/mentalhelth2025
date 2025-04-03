import 'package:connectivity_plus/connectivity_plus.dart';

class InternetService {
  static final Connectivity _connectivity = Connectivity();

  // Check if the device is connected to the internet
  static Future<bool> isConnected() async {
    List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi) || results.contains(ConnectivityResult.mobile);
  }
}
