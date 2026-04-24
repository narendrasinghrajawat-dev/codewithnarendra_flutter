import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/widgets/common_text.dart';
import '../../../../core/widgets/common_text_field.dart';
import '../../../../core/widgets/common_button.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/config/app_theme_colors.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppThemeColors.lightBackground,
      body: ResponsiveLayout(
        mobile: _buildMobileContent(context, l10n, authState),
        tablet: _buildTabletContent(context, l10n, authState),
        desktop: _buildDesktopContent(context, l10n, authState),
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context, AppLocalizations l10n, dynamic authState) {
    return _buildContent(context, l10n, authState, 24, 32, 400);
  }

  Widget _buildTabletContent(BuildContext context, AppLocalizations l10n, dynamic authState) {
    return _buildContent(context, l10n, authState, 32, 40, 450);
  }

  Widget _buildDesktopContent(BuildContext context, AppLocalizations l10n, dynamic authState) {
    return _buildContent(context, l10n, authState, 40, 48, 500);
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, dynamic authState, double padding, double cardPadding, double maxWidth) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeColors.lightBackground,
            AppThemeColors.lightBackground.withOpacity(0.95),
            AppThemeColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Card(
              elevation: 8,
              shadowColor: AppThemeColors.primary.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: EdgeInsets.all(cardPadding),
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      _buildHeader(l10n),
                      const SizedBox(height: 32),
                      _buildEmailField(l10n),
                      const SizedBox(height: 20),
                      _buildPasswordField(l10n),
                      if (authState.hasError && authState.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppThemeColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CommonText.verySmall(
                            authState.errorMessage!,
                            color: AppThemeColors.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      _buildForgotPasswordLink(l10n),
                      const SizedBox(height: 24),
                      _buildLoginButton(l10n, authState),
                      const SizedBox(height: 20),
                      _buildRegisterLink(l10n),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppThemeColors.primary,
                AppThemeColors.primary.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppThemeColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.work,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        CommonText.veryLarge(
          l10n.authWelcome,
          fontWeight: FontWeight.bold,
          color: AppThemeColors.primary,
        ),
        const SizedBox(height: 8),
        CommonText.small(
          l10n.appName,
          color: AppThemeColors.grey600,
        ),
      ],
    );
  }

  Widget _buildEmailField(AppLocalizations l10n) {
    return CommonTextField(
      controller: _emailController,
      labelText: l10n.authEmail,
      hintText: l10n.authEmail,
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
      hintText: l10n.authPassword,
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
          return l10n.fieldInvalidPassword;
        }
        return null;
      },
    );
  }

  Widget _buildForgotPasswordLink(AppLocalizations l10n) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: Implement forgot password
        },
        child: CommonText.small(
          l10n.authForgotPassword,
          color: AppThemeColors.primary,
        ),
      ),
    );
  }

  Widget _buildLoginButton(AppLocalizations l10n, dynamic authState) {
    return CommonButton(
      text: l10n.authLogin,
      onPressed: authState.isLoading ? null : _handleSubmit,
      isLoading: authState.isLoading,
      type: CommonButtonType.primary,
      size: CommonButtonSize.large,
    );
  }

  Widget _buildRegisterLink(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CommonText.small(
          l10n.authAlreadyHaveAccount,
        ),
        TextButton(
          onPressed: () {
            // TODO: Navigate to register
          },
          child: CommonText.small(
            l10n.authRegister,
            color: AppThemeColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final controller = ref.read(authControllerProvider.notifier);
      final success = await controller.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        // Navigate to home/portfolio
        // TODO: Implement navigation
      }
    }
  }
}
