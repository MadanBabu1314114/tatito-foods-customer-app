import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/tatito_colors.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../models/address.dart';
import '../providers/address_provider.dart';
import 'address_form_screen.dart';

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key, this.selectable = false});

  /// When true, tapping an address pops it back to the caller (checkout).
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final addresses = context.watch<AddressProvider>().addresses;

    return Scaffold(
      appBar: AppBar(
        title: Text(selectable ? 'Choose address' : 'Saved addresses'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final saved = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddressFormScreen()),
          );
          if (saved == true && selectable && context.mounted) {
            final latest = context.read<AddressProvider>().defaultAddress;
            if (latest != null) Navigator.pop(context, latest);
          }
        },
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add address'),
      ),
      body: addresses.isEmpty
          ? const AppEmptyState(
              icon: Icons.location_off_outlined,
              title: 'No saved addresses',
              message:
                  'Add a Home, Work or Other address to use it at checkout.',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: TatitoColors.brandGreenLight,
                      child: Icon(
                        _iconFor(address.label),
                        color: TatitoColors.brandGreenDark,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          address.label.label,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: TatitoColors.brandGreenLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'DEFAULT',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: TatitoColors.brandGreenDark,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(address.singleLine),
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddressFormScreen(address: address),
                            ),
                          );
                        } else if (value == 'default') {
                          await context
                              .read<AddressProvider>()
                              .setDefault(address.id);
                        } else if (value == 'delete') {
                          await context
                              .read<AddressProvider>()
                              .remove(address.id);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        if (!address.isDefault)
                          const PopupMenuItem(
                            value: 'default',
                            child: Text('Set as default'),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                    onTap: selectable
                        ? () => Navigator.pop(context, address)
                        : null,
                  ),
                );
              },
            ),
    );
  }

  IconData _iconFor(AddressLabel label) {
    switch (label) {
      case AddressLabel.home:
        return Icons.home_outlined;
      case AddressLabel.work:
        return Icons.work_outline;
      case AddressLabel.other:
        return Icons.place_outlined;
    }
  }
}
