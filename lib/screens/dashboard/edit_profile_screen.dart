import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/swiss.dart';
import '../../theme/theme_controller.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';

/// Lets the user change their display name. Email is read-only: it is the
/// Firebase sign-in identity.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with ThemeAwareState {
  late final _nameController = TextEditingController(text: AuthService.cachedUser?.name ?? '');
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Name cannot be empty');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await AuthService.updateProfile(name: name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = AuthService.cachedUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: swissAppBar(context, 'Edit profile'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Your name',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 34, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -1.6),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
                decoration: swissInput('Name'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: email,
                enabled: false,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 17),
                decoration: swissInput('Email').copyWith(
                  disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.ruleSoft, width: 0.8)),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(_errorMessage!, style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 32),
              SwissButton('Save', onPressed: _save, loading: _isSaving),
            ],
          ),
        ),
      ),
    );
  }
}
