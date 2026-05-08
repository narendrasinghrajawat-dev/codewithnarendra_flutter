import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme_colors.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/theme_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Admin navigation item model
class AdminNavItem {
  final String id;
  final String labelEn;
  final String labelHi;
  final IconData icon;
  final IconData selectedIcon;
  final Color color;

  const AdminNavItem({
    required this.id,
    required this.labelEn,
    required this.labelHi,
    required this.icon,
    required this.selectedIcon,
    required this.color,
  });
}

/// Admin shell with responsive sidebar (desktop/tablet) and bottom nav (mobile)
class AdminShell extends ConsumerStatefulWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onDestinationSelected;
  final List<AdminNavItem> navItems;
  final String? title;
  final List<Widget>? actions;

  const AdminShell({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.navItems,
    this.title,
    this.actions,
  });

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  bool _isSidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeStateProvider);
    final authState = ref.watch(authControllerProvider);
    final isDark = themeState.isDarkMode;
    
    // Check admin access
    if (authState.user?.isUserAdmin != true) {
      return _buildAccessDeniedScreen(context, isDark);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
        
        if (isDesktop) {
          return _buildDesktopLayout(context, isDark);
        } else if (isTablet) {
          return _buildTabletLayout(context, isDark);
        } else {
          return _buildMobileLayout(context, isDark);
        }
      },
    );
  }

  Widget _buildAccessDeniedScreen(BuildContext context, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppThemeColors.darkBackground : AppThemeColors.lightBackground,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppThemeColors.darkSurface : AppThemeColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 64,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You need admin privileges to access this page.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppThemeColors.darkBackground : AppThemeColors.lightBackground,
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isSidebarExpanded ? 280 : 80,
            child: _buildSidebar(context, isDark, isExpanded: _isSidebarExpanded),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                _buildAppBar(context, isDark, showMenu: false),
                Expanded(child: widget.body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppThemeColors.darkBackground : AppThemeColors.lightBackground,
      body: Row(
        children: [
          // Compact sidebar
          SizedBox(
            width: 80,
            child: _buildSidebar(context, isDark, isExpanded: false),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                _buildAppBar(context, isDark, showMenu: false),
                Expanded(child: widget.body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppThemeColors.darkBackground : AppThemeColors.lightBackground,
      appBar: _buildMobileAppBar(context, isDark),
      body: widget.body,
      bottomNavigationBar: _buildBottomNav(context, isDark),
    );
  }

  Widget _buildSidebar(BuildContext context, bool isDark, {required bool isExpanded}) {
    final localizations = ref.watch(localizationStateProvider);
    final isHindi = localizations.language == AppLanguage.hi;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeColors.darkSurface : AppThemeColors.lightSurface,
        borderRadius: isExpanded 
            ? const BorderRadius.horizontal(right: Radius.circular(20))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Header
          Container(
            padding: const EdgeInsets.all(20),
            child: isExpanded
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade400, Colors.purple.shade400],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.dashboard_customize,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin Panel',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'CodeWithNarendra',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isSidebarExpanded ? Icons.chevron_left : Icons.chevron_right,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSidebarExpanded = !_isSidebarExpanded;
                          });
                        },
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.purple.shade400],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.dashboard_customize,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
          ),
          const Divider(height: 1),
          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              itemCount: widget.navItems.length,
              itemBuilder: (context, index) {
                final item = widget.navItems[index];
                final isSelected = widget.currentIndex == index;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildNavItem(
                    context,
                    item: item,
                    isSelected: isSelected,
                    isExpanded: isExpanded,
                    isHindi: isHindi,
                    isDark: isDark,
                    onTap: () => widget.onDestinationSelected(index),
                  ),
                );
              },
            ),
          ),
          // Bottom actions
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: isExpanded
                ? Row(
                    children: [
                      _buildIconButton(
                        icon: ref.watch(themeStateProvider).isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        onPressed: () {
                          ref.read(themeStateProvider.notifier).toggleTheme();
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildIconButton(
                        icon: Icons.language,
                        onPressed: () {
                          final current = ref.read(localizationStateProvider).language;
                          final newLang = current == AppLanguage.en ? AppLanguage.hi : AppLanguage.en;
                          ref.read(localizationStateProvider.notifier).setLanguage(newLang);
                        },
                        isDark: isDark,
                      ),
                      const Spacer(),
                      _buildLogoutButton(isExpanded: true, isDark: isDark),
                    ],
                  )
                : Column(
                    children: [
                      _buildIconButton(
                        icon: ref.watch(themeStateProvider).isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        onPressed: () {
                          ref.read(themeStateProvider.notifier).toggleTheme();
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildIconButton(
                        icon: Icons.language,
                        onPressed: () {
                          final current = ref.read(localizationStateProvider).language;
                          final newLang = current == AppLanguage.en ? AppLanguage.hi : AppLanguage.en;
                          ref.read(localizationStateProvider.notifier).setLanguage(newLang);
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildLogoutButton(isExpanded: false, isDark: isDark),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required AdminNavItem item,
    required bool isSelected,
    required bool isExpanded,
    required bool isHindi,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final label = isHindi ? item.labelHi : item.labelEn;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded ? 16 : 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      item.color.withOpacity(0.2),
                      item.color.withOpacity(0.05),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: item.color.withOpacity(0.3), width: 1)
                : null,
          ),
          child: isExpanded
              ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? item.color.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected ? item.color : (isDark ? Colors.white60 : Colors.black54),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? item.color
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                )
              : Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? item.color.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    color: isSelected ? item.color : (isDark ? Colors.white60 : Colors.black54),
                    size: 24,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: isDark ? Colors.white70 : Colors.black54,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton({required bool isExpanded, required bool isDark}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await ref.read(authControllerProvider.notifier).logout();
        },
        borderRadius: BorderRadius.circular(8),
        child: isExpanded
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.logout,
                  color: Colors.red.shade400,
                  size: 22,
                ),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark, {required bool showMenu}) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? AppThemeColors.darkBackground : AppThemeColors.lightBackground,
      title: Text(
        widget.title ?? 'Admin Panel',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (widget.actions != null) ...widget.actions!,
        const SizedBox(width: 8),
      ],
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context, bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? AppThemeColors.darkBackground : AppThemeColors.lightBackground,
      title: Text(
        widget.title ?? 'Admin Panel',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (widget.actions != null) ...widget.actions!,
        IconButton(
          icon: Icon(
            ref.watch(themeStateProvider).isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          onPressed: () {
            ref.read(themeStateProvider.notifier).toggleTheme();
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.language,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          onSelected: (language) {
            final lang = language == 'hi' ? AppLanguage.hi : AppLanguage.en;
            ref.read(localizationStateProvider.notifier).setLanguage(lang);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'en', child: Text('English')),
            const PopupMenuItem(value: 'hi', child: Text('हिंदी')),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.logout,
            color: Colors.red.shade400,
          ),
          onPressed: () async {
            await ref.read(authControllerProvider.notifier).logout();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeColors.darkSurface : AppThemeColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widget.navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = widget.currentIndex == index;
              
              return _buildBottomNavItem(
                context,
                item: item,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () => widget.onDestinationSelected(index),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    BuildContext context, {
    required AdminNavItem item,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? item.color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? item.selectedIcon : item.icon,
                color: isSelected ? item.color : (isDark ? Colors.white60 : Colors.black54),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
