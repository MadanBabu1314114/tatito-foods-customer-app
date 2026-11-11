import 'package:flutter/material.dart';

import '../models/catalog_sort.dart';

Future<CatalogSort?> showSortSheet(
  BuildContext context,
  CatalogSort current,
) {
  return showModalBottomSheet<CatalogSort>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sort products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            RadioGroup<CatalogSort>(
              groupValue: current,
              onChanged: (value) => Navigator.pop(context, value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final option in CatalogSort.values)
                    RadioListTile<CatalogSort>(
                      value: option,
                      title: Text(option.label),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}
