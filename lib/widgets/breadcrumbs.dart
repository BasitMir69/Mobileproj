import 'package:flutter/material.dart';

class Breadcrumbs extends StatelessWidget {
  final List<BreadcrumbItem> items;
  const Breadcrumbs({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          GestureDetector(
            onTap: items[i].onTap,
            child: Text(
              items[i].label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (i < items.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.0),
              child: Text('›'),
            ),
        ]
      ],
    );
  }
}

class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;
  BreadcrumbItem({required this.label, this.onTap});
}
