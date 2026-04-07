import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

enum ThemeMode { light, dark, system }

class ThemeState {
  final ThemeMode mode;
  final bool isDarkMode;
  
  const ThemeState({
    required this.mode,
    required this.isDarkMode,
  });
  
  ThemeState copyWith({
    ThemeMode? mode,
    bool? isDarkMode,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeState &&
          runtimeType == other.runtimeType &&
          mode == other.mode &&
          isDarkMode == other.isDarkMode;

  @override
  int get hashCode => Object.hash(mode, isDarkMode);
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  final SharedPreferences _prefs;
  
  ThemeNotifier(this._prefs) : super(const ThemeState(
    mode: ThemeMode.system,
    isDarkMode: false,
  )) {
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    final savedTheme = _prefs.getString(AppConstants.themeKey);
    final savedMode = savedTheme != null
        ? ThemeMode.values.firstWhere(
            (mode) => mode.name == savedTheme,
            orElse: () => ThemeMode.system,
          )
        : ThemeMode.system;
    
    final isDark = savedTheme == 'dark' ||
        (savedTheme == 'system' &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
    
    state = ThemeState(mode: savedMode, isDarkMode: isDark);
  }
  
  Future<void> setTheme(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    
    bool isDark = false;
    switch (mode) {
      case ThemeMode.light:
        isDark = false;
        break;
      case ThemeMode.dark:
        isDark = true;
        break;
      case ThemeMode.system:
        isDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
        break;
    }
    
    state = state.copyWith(mode: mode, isDarkMode: isDark);
    await _prefs.setString(AppConstants.themeKey, mode.name);
  }
  
  Future<void> toggleTheme() async {
    final newMode = state.isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setTheme(newMode);
  }
}

// Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

final themeStateProvider = Provider<ThemeState>((ref) {
  return ref.watch(themeNotifierProvider);
});

final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeStateProvider).isDarkMode;
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeStateProvider).mode;
});
