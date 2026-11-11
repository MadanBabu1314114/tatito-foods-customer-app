import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/tatito_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../catalog/models/product.dart';
import '../../catalog/providers/catalog_provider.dart';
import '../providers/review_provider.dart';
import '../widgets/star_rating.dart';

class ReviewFormScreen extends StatefulWidget {
  const ReviewFormScreen({super.key, required this.product});

  final Product product;

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  int _rating = 0;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      setState(() => _error = 'Please sign in to write a review.');
      return;
    }
    if (_rating == 0) {
      setState(() => _error = 'Choose a star rating before submitting.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    await context.read<ReviewProvider>().submit(
          productId: widget.product.id,
          userId: user.id,
          rating: _rating,
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
        );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final product = context.watch<CatalogProvider>().byId(widget.product.id) ??
        widget.product;

    return Scaffold(
      appBar: AppBar(title: const Text('Write a review')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.shopping_basket_outlined,
                  color: TatitoColors.brandGreen,
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(product.unit),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Your rating',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StarRating(
              rating: _rating.toDouble(),
              size: 38,
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 80,
              decoration: const InputDecoration(
                labelText: 'Review title',
                hintText: 'Fresh and well packed',
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Add a short title.';
                if (text.length < 3) return 'Title is too short.';
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _bodyController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Your review',
                hintText: 'Tell us about freshness, quality and delivery.',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Add a few words about the product.';
                if (text.length < 10) return 'Please write at least 10 characters.';
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(
                  color: TatitoColors.dangerRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit review'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Reviews are saved locally and shown as pending until store approval.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: TatitoColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
