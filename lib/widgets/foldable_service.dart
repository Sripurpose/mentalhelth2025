import 'package:flutter/widgets.dart';

class FoldableService {
  /// Detect foldable or unfolded fold phone based on screen width > 600dp
  static bool isFoldable(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // If width > 600 --> Unfolded foldable or tablet size
    return width > 600;
  }
}
