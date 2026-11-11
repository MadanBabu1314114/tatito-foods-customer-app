import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/tatito_colors.dart';
import '../providers/auth_provider.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _token;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your account email.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _token = null;
    });
    final result =
        await context.read<AuthProvider>().requestPasswordReset(email);
    if (!mounted) return;
    final isToken = result != null && RegExp(r'^\d{6}$').hasMatch(result);
    setState(() {
      _loading = false;
      if (isToken) {
        _token = result;
      } else {
        _error = result ?? 'Unable to send a reset code.';
      }
    });
  }

  Future<void> _continueToReset() async {
    final email = _emailController.text.trim();
    final token = _token;
    if (token == null) return;
    final reset = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(email: email, token: token),
      ),
    );
    if (!mounted) return;
    if (reset == true) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Reset your password',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: TatitoColors.brandBlack,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter your email. In this demo the reset code is shown on screen instead of being emailed.',
            style: TextStyle(color: TatitoColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(
              _error!,
              style: const TextStyle(color: TatitoColors.dangerRed),
            ),
          ],
          if (_token != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: TatitoColors.brandGreenLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Demo reset code',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _token!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: TatitoColors.brandGreenDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading
                ? null
                : (_token == null ? _requestReset : _continueToReset),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_token == null ? 'Send reset code' : 'Continue'),
          ),
        ],
      ),
    );
  }
}
