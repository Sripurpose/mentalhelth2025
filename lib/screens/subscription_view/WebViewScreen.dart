import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/dash_borad_screen/dash_board_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final Uri initialUrl;

  const WebViewScreen({super.key, required this.initialUrl});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _hasRedirected = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) async {
            final uri = Uri.parse(url);

            // ✅ Match any URL ending in "/success"
            if (!_hasRedirected &&
                uri.pathSegments.isNotEmpty &&
                uri.pathSegments.last == 'success') {
              _hasRedirected = true;

              // Wait for 5 seconds
              await Future.delayed(const Duration(seconds: 5));

              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const DashBoardScreen()),
                );
              }
            }
          },
        ),
      )
      ..loadRequest(widget.initialUrl);

    // 🧠 Inject viewport JavaScript after small delay (once page loads)
    Future.delayed(const Duration(milliseconds: 500), () {
      _injectViewportFix();
    });
  }

  // 🧠 Prevent zoom/scroll issues on iOS by setting viewport
  void _injectViewportFix() {
    _controller.runJavaScript('''
      var meta = document.createElement('meta');
      meta.name = 'viewport';
      meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
      document.getElementsByTagName('head')[0].appendChild(meta);
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("In-App Browser")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
