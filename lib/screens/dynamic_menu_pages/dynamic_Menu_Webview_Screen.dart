import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../utils/logic/shared_prefrence.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../auth/sign_in/provider/sign_in_provider.dart';
import '../no_internet/duplicate_screen.dart';

class DynamicMenuWebviewScreen extends StatefulWidget {
  final String? title;
  final String? url;

  const DynamicMenuWebviewScreen({
    Key? key,
    this.title,
    this.url,
  }) : super(key: key);

  @override
  State<DynamicMenuWebviewScreen> createState() =>
      _DynamicMenuWebviewScreenState();
}

class _DynamicMenuWebviewScreenState extends State<DynamicMenuWebviewScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _title;
  String? _url;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final signInProvider =
      Provider.of<SignInProvider>(context, listen: false);
      await _clearWebViewCache(); // ✅ Clear cache before loading
      await _loadDynamicMenu(signInProvider);
    });
  }

  /// ✅ Clear only WebView cache (no cookies)
  Future<void> _clearWebViewCache() async {
    try {
      final tempController = WebViewController();
      await tempController.clearCache();
      debugPrint("✅ WebView cache cleared");
    } catch (e) {
      debugPrint("⚠️ Error clearing WebView cache: $e");
    }
  }

  Future<void> _loadDynamicMenu(SignInProvider signInProvider) async {
    // ✅ If the clicked item passed title & URL, use it directly
    if (widget.url != null && widget.url!.isNotEmpty) {

      // 🔹 Get user token
      String? token = await getUserTokenSharePref();

      // 🔹 Append token at the end of the URL (NO ? or &)
      String finalUrl = widget.url!;
      if (token != null && token.isNotEmpty) {
        if (!finalUrl.endsWith("/")) {
          finalUrl = "$finalUrl/";
        }
        finalUrl = "$finalUrl$token";   // 👉 Append token directly
      }

      setState(() {
        _title = widget.title ?? "Page";
        _url = finalUrl;   // ✅ Final appended URL
        print("Final URL: $_url");
      });

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) => setState(() => _isLoading = true),
            onPageFinished: (_) => setState(() => _isLoading = false),
          ),
        )
        ..loadRequest(Uri.parse(_url!));

      return;
    }


    // 🌀 Fallback: Load first active dynamic menu if none passed
    final dynamicMenuList = signInProvider.dynamicMenuList ?? [];
    var activeItem;
    try {
      activeItem = dynamicMenuList.firstWhere(
            (item) => item.status == "1" && (item.linkUrl?.isNotEmpty ?? false),
      );
    } catch (e) {
      activeItem = null;
    }

    if (activeItem != null) {
      setState(() {
        _title = activeItem.title ?? "Page";
        _url = activeItem.linkUrl;
      });

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) => setState(() => _isLoading = true),
            onPageFinished: (_) => setState(() => _isLoading = false),
          ),
        )
        ..loadRequest(Uri.parse(_url!));
    } else {
      setState(() {
        _title = "No page available";
        _url = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ConnectivityWidget(
      child: SafeArea(
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: ColorsContent.homeBackGroundColor,
            image: DecorationImage(
              image: AssetImage(ImageConstant.imgGroup193),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              buildAppBar(context, size, heading: _title ?? "Loading...",isSigned: false),
              Expanded(
                child: (_controller == null || _url == null)
                    ? const Center(child: CupertinoActivityIndicator())
                    : Stack(
                  children: [
                    WebViewWidget(controller: _controller!),
                    if (_isLoading)
                      const Center(child: CupertinoActivityIndicator()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}