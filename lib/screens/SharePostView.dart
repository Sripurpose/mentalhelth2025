// SharePostView.dart — complete screen with optional injected data
// Drop this into lib/screens/SharePostView.dart (or adjust import paths)

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Native channel that your iOS/Android code writes shared payload into.
/// iOS: App Group + MethodChannel should answer 'getSharedData' and 'clearSharedData'.
const MethodChannel shareDataChannel = MethodChannel('com.numuapp.numuapp/shareData');

class SharePostView extends StatefulWidget {
  final VoidCallback? onClose;

  /// Optional: pass pre-fetched data (e.g., from iOS share-extension bridge in Dart)
  final String? sharedUrl;
  final String? sharedText;
  final List<String>? sharedImages;

  const SharePostView({
    Key? key,
    this.onClose,
    this.sharedUrl,
    this.sharedText,
    this.sharedImages,
  }) : super(key: key);

  @override
  State<SharePostView> createState() => _SharePostViewState();
}

class _SharePostViewState extends State<SharePostView> {
  SharedContentData? sharedData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSharedContent();
  }

  Future<void> _loadSharedContent() async {
    setState(() => isLoading = true);

    // 1) Prefer injected data if present
    final hasInjected = (widget.sharedUrl != null && widget.sharedUrl!.isNotEmpty) ||
        (widget.sharedText != null && widget.sharedText!.isNotEmpty) ||
        ((widget.sharedImages?.isNotEmpty) ?? false);

    if (hasInjected) {
      sharedData = SharedContentData(
        text: null,
        url: widget.sharedUrl,
        sharedText: widget.sharedText,
        imagePaths: List<String>.from(widget.sharedImages ?? const <String>[]),
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );
      setState(() => isLoading = false);
      return;
    }

    // 2) Otherwise query native via MethodChannel
    try {
      final Map<dynamic, dynamic>? result =
      await shareDataChannel.invokeMethod<Map<dynamic, dynamic>>('getSharedData');

      if (result == null) {
        sharedData = null;
      } else {
        final json = result.cast<String, dynamic>();
        final String? text = json['text'] as String?;
        final String? url = json['url'] as String?;
        final String? sharedText = json['sharedText'] as String?; // optional in payload

        final dynamic tVal = json['timestamp'];
        final int? timestamp = tVal is num ? tVal.toInt() : null;

        final int imageCount = json['imageCount'] as int? ?? 0;
        List<String> imagePaths = <String>[];
        if (Platform.isIOS && imageCount > 0) {
          imagePaths = await _getImagePathsFromAppGroup(imageCount);
        } else if (json['images'] is List) {
          imagePaths = List<String>.from((json['images'] as List).map((e) => e.toString()));
        }

        sharedData = SharedContentData(
          text: text,
          url: url,
          sharedText: sharedText,
          imagePaths: imagePaths,
          timestamp: timestamp ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000),
        );

        // Clear after reading so we don't re-consume on next open
        try {
          await shareDataChannel.invokeMethod('clearSharedData');
        } catch (_) {}
      }
    } on PlatformException catch (e) {
      debugPrint('Platform error: ${e.message}');
      sharedData = null;
    } catch (e) {
      debugPrint('Failed to read shared content: $e');
      sharedData = null;
    }

    setState(() => isLoading = false);
  }

  Future<List<String>> _getImagePathsFromAppGroup(int imageCount) async {
    // NOTE: This is a best-effort scanner over the AppGroup base folder on iOS simulators/devices.
    // In production you should write exact file paths from the extension into the payload.
    final List<String> paths = [];
    try {
      final Directory baseDir = Directory('/var/mobile/Containers/Shared/AppGroup');
      if (!baseDir.existsSync()) return paths;
      for (final entity in baseDir.listSync()) {
        if (entity is! Directory) continue;
        for (int i = 0; i < imageCount; i++) {
          final f = File('${entity.path}/sharedImage$i.jpg');
          if (f.existsSync()) paths.add(f.path);
        }
        if (paths.isNotEmpty) break; // stop at first hit
      }
    } catch (e) {
      debugPrint('Error scanning app group images: $e');
    }
    return paths;
  }

  String _formattedDate(int secondsSinceEpoch) {
    final date = DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch * 1000);
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('MMM d, yyyy').format(date);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not open $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Content'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              widget.onClose?.call();
              Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
      body: isLoading
          ? _buildLoading()
          : (sharedData != null ? _buildContentView(sharedData!) : _buildErrorView()),
    );
  }

  Widget _buildLoading() => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading shared content...'),
        ],
      ),
    ),
  );

  Widget _buildContentView(SharedContentData data) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Comment/Text
          if ((data.text ?? '').isNotEmpty)
            _section(
              context,
              title: 'Your Comment',
              child: Text(data.text!),
            ),

          // URL
          if ((data.url ?? '').isNotEmpty)
            _section(
              context,
              title: 'Shared Link',
              child: GestureDetector(
                onTap: () => _openUrl(data.url!),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data.url!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                      const Icon(Icons.arrow_outward, size: 18),
                    ],
                  ),
                ),
              ),
            ),

          // Shared Text (from host app)
          if ((data.sharedText ?? '').isNotEmpty)
            _section(
              context,
              title: 'Shared Text',
              child: Text(data.sharedText!),
            ),

          // Images
          if (data.imagePaths.isNotEmpty)
            _section(
              context,
              title: 'Shared Images (${data.imagePaths.length})',
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: data.imagePaths.length,
                  itemBuilder: (_, index) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(data.imagePaths[index]),
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Timestamp
          if (data.timestamp != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Shared ${_formattedDate(data.timestamp!)}',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      debugPrint('Save tapped: text=${data.text}, url=${data.url}, images=${data.imagePaths.length}');
                      // TODO: Implement your save logic
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save to Library'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      widget.onClose?.call();
                      Navigator.of(context).maybePop();
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildErrorView() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_rounded, size: 60, color: Colors.orange),
          const SizedBox(height: 16),
          const Text('No Shared Content', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text("There's no content to display", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.onClose?.call();
              Navigator.of(context).maybePop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    ),
  );

  Widget _section(BuildContext context, {required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

// Lightweight model used by the screen
class SharedContentData {
  final String? text;        // User's comment in the extension sheet
  final String? url;         // Shared link
  final String? sharedText;  // Any text captured by host app
  final List<String> imagePaths; // Local file paths to images
  final int? timestamp;      // seconds since epoch

  SharedContentData({
    this.text,
    this.url,
    this.sharedText,
    required this.imagePaths,
    this.timestamp,
  });

  @override
  String toString() => 'SharedContentData(text: $text, url: $url, sharedText: $sharedText, images: ${imagePaths.length}, ts: $timestamp)';
}