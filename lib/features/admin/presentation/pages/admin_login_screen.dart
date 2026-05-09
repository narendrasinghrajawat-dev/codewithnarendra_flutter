import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/widgets/common_text.dart';
import '../../../../core/widgets/common_text_field.dart';
import '../../../../core/widgets/common_button.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/constants/app_sizes.dart';
import '../controllers/admin_auth_controller.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(adminAuthControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: ResponsiveContainer(
        center: true,
        useCard: true,
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ResponsiveSpacing(mobile: AppSizes.spacingXL),
              _buildHeader(l10n),
              const ResponsiveSpacing(mobile: AppSizes.spacingXL),
              _buildEmailField(l10n),
              const ResponsiveSpacing(mobile: AppSizes.spacingMD),
              _buildPasswordField(l10n),
              if (authState.hasError && authState.errorMessage != null) ...[
                const ResponsiveSpacing(mobile: AppSizes.spacingSM),
                CommonText.verySmall(
                  authState.errorMessage!,
                  color: Colors.red,
                ),
              ],
              const ResponsiveSpacing(mobile: AppSizes.spacingLG),
              _buildLoginButton(authState, l10n),
              const ResponsiveSpacing(mobile: AppSizes.spacingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        CommonText.veryLarge(
          l10n.adminPortal,
          fontWeight: FontWeight.bold,
        ),
        const ResponsiveSpacing(mobile: AppSizes.spacingSM),
        CommonText.small(
          l10n.adminDashboardTitle,
          color: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildEmailField(AppLocalizations l10n) {
    return CommonTextField(
      controller: _emailController,
      labelText: l10n.authEmail,
      hintText: l10n.enterAdminEmail,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.fieldRequired;
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return l10n.fieldInvalidEmail;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n) {
    return CommonTextField(
      controller: _passwordController,
      labelText: l10n.authPassword,
      hintText: l10n.enterAdminPassword,
      prefixIcon: Icons.lock_outline,
      suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
      onSuffixIconPressed: () {
        setState(() {
          _obscurePassword = !_obscurePassword;
        });
      },
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.fieldRequired;
        }
        if (value.length < 8) {
          return l10n.authPassword.length < 8 ? l10n.fieldInvalidPassword : null;
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton(dynamic authState, AppLocalizations l10n) {
    return CommonButton(
      text: l10n.adminLogin,
      onPressed: authState.isLoading ? null : _handleSubmit,
      isLoading: authState.isLoading,
      type: CommonButtonType.primary,
      size: CommonButtonSize.large,
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final controller = ref.read(adminAuthControllerProvider.notifier);
      final success = await controller.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        // Navigate to admin dashboard
        // TODO: Implement navigation
      }
    }
  }
}
