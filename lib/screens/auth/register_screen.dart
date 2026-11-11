import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils.dart';
import '../../models/enums.dart';
import '../../providers/auth_providers.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  String? _department;
  UserRole _role = UserRole.student;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).signUp(
            name: _nameCtrl.text,
            email: _emailCtrl.text,
            password: _passCtrl.text,
            role: _role,
            department: _department!,
          );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).popUntil((r) => r.isFirst);
      messenger.showSnackBar(
          const SnackBar(content: Text('Welcome to CampusWatch! 🎉')));
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        context.showSnack(AuthService.friendlyError(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                validator: (v) => Validators.minLength(v, 3, 'Full name'),
                decoration: const InputDecoration(
                    hintText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline_rounded)),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                decoration: const InputDecoration(
                    hintText: 'Email address',
                    prefixIcon: Icon(Icons.mail_outline_rounded)),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _department,
                items: [
                  for (final d in AppConstants.departments)
                    DropdownMenuItem(
                        value: d,
                        child: Text(d, style: const TextStyle(fontSize: 14))),
                ],
                onChanged: (v) => setState(() => _department = v),
                validator: (v) => v == null ? 'Select your department' : null,
                decoration: const InputDecoration(
                    hintText: 'Department',
                    prefixIcon: Icon(Icons.school_outlined)),
              ),
              const SizedBox(height: 18),
              const Text('I am a…',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: _RoleCard(
                        role: UserRole.student,
                        icon: Icons.school_rounded,
                        selected: _role == UserRole.student,
                        onTap: () =>
                            setState(() => _role = UserRole.student))),
                const SizedBox(width: 10),
                Expanded(
                    child: _RoleCard(
                        role: UserRole.staff,
                        icon: Icons.admin_panel_settings_rounded,
                        selected: _role == UserRole.staff,
                        onTap: () => setState(() => _role = UserRole.staff))),
              ]),
              if (_role == UserRole.staff) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _codeCtrl,
                  validator: (v) => v?.trim() != AppConstants.staffInviteCode
                      ? 'Invalid staff invite code'
                      : null,
                  decoration: const InputDecoration(
                      hintText: 'Staff invite code',
                      prefixIcon: Icon(Icons.vpn_key_outlined)),
                ),
                const SizedBox(height: 6),
                const Text(
                    'Staff accounts require an invite code from the administration.',
                    style:
                        TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
              ],
              const SizedBox(height: 14),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                validator: Validators.password,
                decoration: const InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline_rounded)),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: true,
                validator: (v) =>
                    v != _passCtrl.text ? 'Passwords do not match' : null,
                decoration: const InputDecoration(
                    hintText: 'Confirm password',
                    prefixIcon: Icon(Icons.lock_outline_rounded)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('Create Account'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final UserRole role;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.inProgressBg : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 1.6 : 1),
          ),
          child: Column(children: [
            Icon(icon,
                color: selected ? AppColors.primary : AppColors.textMuted),
            const SizedBox(height: 6),
            Text(role.label,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color:
                        selected ? AppColors.primary : AppColors.textDark)),
          ]),
        ),
      );
}