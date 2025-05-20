import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewExample extends StatefulWidget {
  final String targetUrl;

  WebViewExample({Key? key, required this.targetUrl}) : super(key: key);

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  InAppWebViewController? _webViewController;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter InAppWebView Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              if (_webViewController != null && await _webViewController!.canGoBack()) {
                await _webViewController!.goBack();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () async {
              if (_webViewController != null && await _webViewController!.canGoForward()) {
                await _webViewController!.goForward();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _webViewController?.reload();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(3.0),
          child: LinearProgressIndicator(
            value: _progress < 1.0 ? _progress : 0,
            backgroundColor: Colors.transparent,
            color: Colors.white,
            minHeight: 3,
          ),
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(widget.targetUrl),
        ),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
           // debuggingEnabled: true,
          ),
          android: AndroidInAppWebViewOptions(
            useHybridComposition: true,
          ),
          ios: IOSInAppWebViewOptions(
            allowsInlineMediaPlayback: true,
          ),
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        onLoadStart: (controller, url) {
          print('Page started loading: $url');
        },
        onLoadStop: (controller, url) {
          print('Page finished loading: $url');
        },
        onProgressChanged: (controller, progress) {
          setState(() {
            _progress = progress / 100;
          });
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          // Example: You can intercept URL loading here if needed
          // For now, allow all navigations
          return NavigationActionPolicy.ALLOW;
        },
      ),
    );
  }
}
