import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/tatito_colors.dart';
import '../models/address.dart';
import '../providers/address_provider.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key, this.address});

  final Address? address;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  late final TextEditingController _line1;
  late final TextEditingController _line2;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _pincode;
  late AddressLabel _label;
  late bool _isDefault;
  String? _error;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _line1 = TextEditingController(text: address?.line1 ?? '');
    _line2 = TextEditingController(text: address?.line2 ?? '');
    _city = TextEditingController(text: address?.city ?? 'Hyderabad');
    _state = TextEditingController(text: address?.state ?? 'Telangana');
    _pincode = TextEditingController(text: address?.pincode ?? '');
    _label = address?.label ?? AddressLabel.home;
    _isDefault = address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _line1.dispose();
    _line2.dispose();
    _city.dispose();
    _state.dispose();
    _pincode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final line1 = _line1.text.trim();
    final pincode = _pincode.text.trim();
    if (line1.isEmpty || _city.text.trim().isEmpty) {
      setState(() => _error = 'Address line 1 and city are required.');
      return;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(pincode)) {
      setState(() => _error = 'Enter a valid 6-digit pincode.');
      return;
    }

    final provider = context.read<AddressProvider>();
    final address = Address(
      id: widget.address?.id ?? '',
      label: _label,
      line1: line1,
      line2: _line2.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      pincode: pincode,
      isDefault: _isDefault,
    );

    if (widget.address == null) {
      await provider.add(address);
    } else {
      await provider.update(address);
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final zone = context.watch<AddressProvider>().zoneFor(_pincode.text.trim());
    final pincodeEntered = _pincode.text.trim().length == 6;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Add address' : 'Edit address'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<AddressLabel>(
            initialValue: _label,
            decoration: const InputDecoration(labelText: 'Address label'),
            items: AddressLabel.values
                .map(
                  (label) => DropdownMenuItem(
                    value: label,
                    child: Text(label.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _label = value);
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _line1,
            decoration: const InputDecoration(
              labelText: 'Flat / house / building',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _line2,
            decoration: const InputDecoration(
              labelText: 'Area / street (optional)',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _city,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _state,
                  decoration: const InputDecoration(labelText: 'State'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _pincode,
            keyboardType: TextInputType.number,
            maxLength: 6,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: '6-digit pincode',
              counterText: '',
            ),
          ),
          if (pincodeEntered) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: zone == null
                    ? TatitoColors.warningOrange.withValues(alpha: 0.12)
                    : TatitoColors.brandGreenLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                zone == null
                    ? 'Delivery is not available at this pincode yet. You can still save this address.'
                    : 'Delivery available · Fee ₹${zone.deliveryFee.toStringAsFixed(0)} · Minimum order ₹${zone.minimumOrder.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: zone == null
                      ? const Color(0xFF92400E)
                      : TatitoColors.brandGreenDark,
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _isDefault,
            onChanged: (value) => setState(() => _isDefault = value),
            title: const Text('Set as default address'),
          ),
          if (_error != null) ...[
            Text(
              _error!,
              style: const TextStyle(color: TatitoColors.dangerRed),
            ),
            const SizedBox(height: 10),
          ],
          ElevatedButton(
            onPressed: _save,
            child: const Text('Save address'),
          ),
        ],
      ),
    );
  }
}
