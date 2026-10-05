import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_controller.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';

/// Lets the user change their display name. Email is read-only here --
/// changing it is tied to the Firebase sign-in work being done separately.
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text('EDIT PROFILE', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'NAME',
                        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 0.8),
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF383838))),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accent)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      initialValue: email,
                      enabled: false,
                      style: TextStyle(color: AppColors.textSecondary),
                      decoration: InputDecoration(
                        labelText: 'EMAIL',
                        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 0.8),
                        disabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2A2A2A))),
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.onAccent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSaving
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onAccent),
                      )
                    : const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
