import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mentalhelth/utils/theme/colors.dart';

import '../model/get_category.dart';

class MultiSelectCategoryWidget extends StatefulWidget {
  final List<Category> categories;
  final List<Category> selectedCategories;

  const MultiSelectCategoryWidget({
    Key? key,
    required this.categories,
    required this.selectedCategories,
  }) : super(key: key);

  @override
  _MultiSelectCategoryWidgetState createState() =>
      _MultiSelectCategoryWidgetState();
}

class _MultiSelectCategoryWidgetState extends State<MultiSelectCategoryWidget> {
  late List<Category> _tempSelectedCategories;

  @override
  void initState() {
    super.initState();
    // Initialize with already selected categories
    _tempSelectedCategories = List.from(widget.selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: widget.categories.length,
            itemBuilder: (BuildContext context, int index) {
              final category = widget.categories[index];
              final bool isSelected = _tempSelectedCategories.contains(category);

              return CheckboxListTile(
                title: Text(category.categoryName ?? ""),
                value: isSelected,
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      // Allow adding only if less than 2 items are selected
                      if (_tempSelectedCategories.length < 2) {
                        _tempSelectedCategories.add(category);
                      } else {
                        // Show a message if more than 2 items are being selected
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text('alreday selected item!'),
                        //   ),
                        // );
                        Fluttertoast.showToast(
                            msg: 'Already selected item!',
                            toastLength: Toast.LENGTH_SHORT, // Length of the toast
                            gravity: ToastGravity.BOTTOM,     // Position of the toast
                            timeInSecForIosWeb: 1,            // Duration for iOS and web
                            backgroundColor: Colors.black,     // Background color
                            textColor: Colors.white,           // Text color
                            fontSize: 16.0                     // Font size
                        );
                      }
                    } else {
                      // Remove from the list if unchecked
                      _tempSelectedCategories.remove(category);
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: ColorsContent.newThemeColor,
                checkColor: Colors.white,
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Return the final list of selected categories
            Navigator.pop(context, _tempSelectedCategories);
          },
          child: Text('Save Selection'),
        ),
      ],
    );
  }
}



