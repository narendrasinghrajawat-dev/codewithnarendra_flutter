import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/common_text.dart';
import '../../../../core/widgets/common_text_field.dart';
import '../../../../core/widgets/common_button.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/config/app_icons.dart';
import '../controllers/auth_controller.dart';
  

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Listen for auth state changes and give user feedback
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go('/portfolio');
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: ResponsiveLayout(
        mobile: _buildMobileContent(context, l10n),
        tablet: _buildTabletContent(context, l10n),
        desktop: _buildDesktopContent(context, l10n),
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context, AppLocalizations l10n) {
    return _buildContent(context, l10n, 24, 32, 400);
  }

  Widget _buildTabletContent(BuildContext context, AppLocalizations l10n) {
    return _buildContent(context, l10n, 32, 40, 450);
  }

  Widget _buildDesktopContent(BuildContext context, AppLocalizations l10n) {
    return _buildContent(context, l10n, 40, 48, 500);
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, double padding, double cardPadding, double maxWidth) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.95),
            AppColors.primary.withOpacity(0.05),
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
              shadowColor: AppColors.primary.withOpacity(0.2),
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
                      _buildRegisterForm(l10n),
                      const SizedBox(height: 24),
                      _buildSubmitButton(l10n),
                      const SizedBox(height: 20),
                      _buildLoginLink(l10n),
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
                AppColors.primary,
                AppColors.primary.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AppIcons.logoMedium(),
          ),
        ),
        const SizedBox(height: 24),
        CommonText.veryLarge(
          l10n.authRegister,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        CommonText.medium(
          l10n.authCreateNewAccount,
          textAlign: TextAlign.center,
          color: AppColors.grey600,
        ),
      ],
    );
  }

  Widget _buildRegisterForm(AppLocalizations l10n) {
    return Column(
      spacing: 20,
      children: [
        _buildDisplayNameField(l10n),
        _buildEmailField(l10n),
        _buildPasswordField(l10n),
        _buildConfirmPasswordField(l10n),
      ],
    );
  }

  Widget _buildDisplayNameField(AppLocalizations l10n) {
    return CommonTextField(
      controller: _displayNameController,
      labelText: l10n.authDisplayName,
      hintText: l10n.authDisplayName,
      prefixIcon: Icons.person_outlined,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.fieldRequired;
        }
        if (value.length < 2) {
          return 'Display name must be at least 2 characters';
        }
        return null;
      },
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
      prefixIcon: Icons.lock_outlined,
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
        if (value.length < 6) {
          return l10n.fieldInvalidPassword;
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField(AppLocalizations l10n) {
    return CommonTextField(
      controller: _confirmPasswordController,
      labelText: l10n.authConfirmPassword,
      hintText: l10n.authConfirmPassword,
      prefixIcon: Icons.lock_outlined,
      suffixIcon: _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
      onSuffixIconPressed: () {
        setState(() {
          _obscureConfirmPassword = !_obscureConfirmPassword;
        });
      },
      obscureText: _obscureConfirmPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.fieldRequired;
        }
        if (value != _passwordController.text) {
          return l10n.fieldPasswordMismatch;
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authControllerProvider);
        
        return CommonButton(
          text: l10n.authCreateAccount,
          onPressed: authState.status == AuthStatus.loading ? null : _handleSubmit,
          isLoading: authState.status == AuthStatus.loading,
          type: CommonButtonType.primary,
          size: CommonButtonSize.large,
        );
      },
    );
  }

  Widget _buildLoginLink(AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonText.small(
            l10n.authAlreadyHaveAccount,
          ),
          TextButton(
            onPressed: () {
              GoRouter.of(context).push('/login');
            },
            child: CommonText.small(
              l10n.authSignInInstead,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {

    print(" handleSubmit called");
    if (_formKey.currentState?.validate() ?? false) {
      final notifier = ref.read(authControllerProvider.notifier);
      final displayName = _displayNameController.text.trim();
      final nameParts = displayName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      
      
      print("Submitting registration with: email=${_emailController.text.trim()}, password=${_passwordController.text}, firstName=$firstName, lastName=$lastName"); 
      
      await notifier.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: firstName,
        lastName: lastName,
      );
    }
  }
}
