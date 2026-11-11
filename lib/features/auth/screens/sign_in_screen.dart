import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/tatito_colors.dart';
import '../providers/auth_provider.dart';
import '../../auth/screens/forgot_password_screen.dart';
import '../../auth/screens/role_placeholder_screen.dart';
import '../../auth/screens/sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController =
      TextEditingController(text: 'customer@tatitofoods.test');
  final _passwordController = TextEditingController(text: 'Customer@12345');
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = context.read<AuthProvider>();
    final error = await auth.signIn(email: email, password: password);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _loading = false;
        _error = error;
      });
      return;
    }
    final profile = auth.currentUser;
    if (profile != null && profile.role.name != 'customer') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RolePlaceholderScreen(profile: profile),
        ),
      );
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          const Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: TatitoColors.brandBlack,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sign in to checkout, track orders, save addresses and write reviews.',
            style: TextStyle(color: TatitoColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TatitoColors.dangerRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _error!,
                style: const TextStyle(color: TatitoColors.dangerRed),
              ),
            ),
          ],
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Sign in'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              );
            },
            child: const Text('Forgot password?'),
          ),
          const Divider(height: 28),
          const Text(
            'Demo credentials',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _DemoCredential(
            role: 'Customer',
            email: 'customer@tatitofoods.test',
            password: 'Customer@12345',
            onTap: _fillCustomer,
          ),
          _DemoCredential(
            role: 'Admin',
            email: 'admin@tatitofoods.test',
            password: 'Admin@12345',
            onTap: () => _fill('admin@tatitofoods.test', 'Admin@12345'),
          ),
          _DemoCredential(
            role: 'Delivery',
            email: 'delivery@tatitofoods.test',
            password: 'Delivery@12345',
            onTap: () => _fill('delivery@tatitofoods.test', 'Delivery@12345'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
              );
            },
            child: const Text('Create a new account'),
          ),
        ],
      ),
    );
  }

  void _fill(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
    setState(() => _error = null);
  }

  void _fillCustomer() => _fill(
        'customer@tatitofoods.test',
        'Customer@12345',
      );
}

class _DemoCredential extends StatelessWidget {
  const _DemoCredential({
    required this.role,
    required this.email,
    required this.password,
    required this.onTap,
  });

  final String role;
  final String email;
  final String password;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.person_outline, size: 20),
      title: Text('$role: $email'),
      subtitle: Text(password),
      trailing: const Icon(Icons.arrow_forward_ios, size: 13),
      onTap: onTap,
    );
  }
}
