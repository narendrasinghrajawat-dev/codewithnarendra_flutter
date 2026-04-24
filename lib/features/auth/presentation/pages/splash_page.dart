import 'package:codewithnarendra/core/config/app_theme_colors.dart';
import 'package:codewithnarendra/core/services/theme_service.dart';
import 'package:codewithnarendra/core/themes/app_theme.dart';
import 'package:codewithnarendra/core/widgets/common_text.dart';
import 'package:codewithnarendra/core/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';


class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final authState = ref.read(authControllerProvider);
    
    if (mounted) {
      final isAuthenticated = authState.isAuthenticated;
      final context = this.context;
      
      if (isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/portfolio');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeStateProvider);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: themeState.isDarkMode
          ? AppThemeColors.darkBackground
          : AppThemeColors.lightBackground,
      body: ResponsiveLayout(
        mobile: _buildMobileContent(context, l10n, themeState),
        tablet: _buildTabletContent(context, l10n, themeState),
        desktop: _buildDesktopContent(context, l10n, themeState),
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context, AppLocalizations l10n, dynamic themeState) {
    return _buildContent(context, l10n, themeState, 120, 60);
  }

  Widget _buildTabletContent(BuildContext context, AppLocalizations l10n, dynamic themeState) {
    return _buildContent(context, l10n, themeState, 140, 70);
  }

  Widget _buildDesktopContent(BuildContext context, AppLocalizations l10n, dynamic themeState) {
    return _buildContent(context, l10n, themeState, 160, 80);
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, dynamic themeState, double logoSize, double iconSize) {
    return Center(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(logoSize * 0.25),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.work,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  CommonText.veryLarge(
                    l10n.appName,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.2,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  CommonText.medium(
                    l10n.authWelcome,
                    textAlign: TextAlign.center,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
