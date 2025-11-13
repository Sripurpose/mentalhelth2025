import 'package:flutter/material.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomViewPreviewLink extends StatefulWidget {
  final String link;
  final VoidCallback? onRemove;
  final bool isViewOnly;

  const CustomViewPreviewLink({
    Key? key,
    required this.link,
    this.onRemove,
    this.isViewOnly = false,
  }) : super(key: key);

  @override
  State<CustomViewPreviewLink> createState() => _CustomViewPreviewLinkState();
}

class _CustomViewPreviewLinkState extends State<CustomViewPreviewLink> {
  late Uri _uri;

  @override
  void initState() {
    super.initState();
    _uri = Uri.parse(widget.link);
  }

  @override
  Widget build(BuildContext context) {
    final domain = _uri.host.replaceFirst('www.', ''); // e.g., youtube.com

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          // 🔗 Link Preview with domain
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnyLinkPreview(
                    link: widget.link,
                    displayDirection: UIDirection.uiDirectionVertical,
                    showMultimedia: true,
                    removeElevation: true,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      )
                    ],
                    bodyMaxLines: 2,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    bodyStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    errorBody: 'Unable to load preview',
                    backgroundColor: Colors.white,
                    borderRadius: 10,
                    onTap: () async {
                      if (await canLaunchUrl(_uri)) {
                        await launchUrl(_uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),

                  // 🌐 Domain text shown below
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6),
                    child: GestureDetector(
                      onTap: () async {
                        if (await canLaunchUrl(_uri)) {
                          await launchUrl(_uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Text(
                        domain,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                          decorationThickness: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ❌ Close button (only visible when not view-only)
          if (!widget.isViewOnly)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: widget.onRemove,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
