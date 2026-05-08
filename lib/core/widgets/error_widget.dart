import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../exceptions/app_exceptions.dart';

/// Types of error states that can be displayed
enum ErrorType {
  network,
  server,
  auth,
  notFound,
  validation,
  timeout,
  unknown,
  empty,
}

/// A reusable error widget that can be used across the app
class AppErrorWidget extends StatelessWidget {
  final String? message;
  final ErrorType errorType;
  final VoidCallback? onRetry;
  final String? retryText;
  final bool showRetryButton;

  const AppErrorWidget({
    super.key,
    this.message,
    this.errorType = ErrorType.unknown,
    this.onRetry,
    this.retryText,
    this.showRetryButton = true,
  });

  /// Create from an exception
  factory AppErrorWidget.fromException(
    dynamic exception, {
    VoidCallback? onRetry,
    bool showRetryButton = true,
  }) {
    ErrorType type = ErrorType.unknown;
    String message = exception.toString();

    if (exception is NetworkException) {
      type = ErrorType.network;
      message = exception.message;
    } else if (exception is ServerException) {
      type = ErrorType.server;
      message = exception.message;
    } else if (exception is AuthenticationException) {
      type = ErrorType.auth;
      message = exception.message;
    } else if (exception is NotFoundException) {
      type = ErrorType.notFound;
      message = exception.message;
    } else if (exception is ValidationException) {
      type = ErrorType.validation;
      message = exception.message;
    } else if (exception is TimeoutException) {
      type = ErrorType.timeout;
      message = exception.message;
    }

    return AppErrorWidget(
      message: message,
      errorType: type,
      onRetry: onRetry,
      showRetryButton: showRetryButton,
    );
  }

  /// Create empty state widget
  factory AppErrorWidget.empty({
    String? message,
    VoidCallback? onRetry,
  }) {
    return AppErrorWidget(
      message: message ?? AppStrings.statusEmpty,
      errorType: ErrorType.empty,
      onRetry: onRetry,
      showRetryButton: onRetry != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(isDark),
            const SizedBox(height: AppSizes.spacingLG),
            Text(
              _getTitle(),
              style: TextStyle(
                fontSize: AppSizes.fontLG,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.darkOnBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingSM),
            Text(
              message ?? _getDefaultMessage(),
              style: TextStyle(
                fontSize: AppSizes.fontMD,
                color: isDark ? Colors.grey[400] : AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: AppSizes.spacingLG),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? AppStrings.actionRetry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingLG,
                    vertical: AppSizes.paddingMD,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(bool isDark) {
    IconData iconData;
    Color color;

    switch (errorType) {
      case ErrorType.network:
        iconData = Icons.wifi_off;
        color = AppColors.warning;
        break;
      case ErrorType.server:
        iconData = Icons.cloud_off;
        color = AppColors.error;
        break;
      case ErrorType.auth:
        iconData = Icons.lock_outline;
        color = AppColors.warning;
        break;
      case ErrorType.notFound:
        iconData = Icons.search_off;
        color = AppColors.grey500;
        break;
      case ErrorType.validation:
        iconData = Icons.error_outline;
        color = AppColors.warning;
        break;
      case ErrorType.timeout:
        iconData = Icons.timer_off;
        color = AppColors.warning;
        break;
      case ErrorType.empty:
        iconData = AppIcons.empty;
        color = isDark ? Colors.grey[600]! : AppColors.grey400;
        break;
      case ErrorType.unknown:
        iconData = AppIcons.error;
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: AppSizes.iconXXXXL,
        color: color,
      ),
    );
  }

  String _getTitle() {
    switch (errorType) {
      case ErrorType.network:
        return 'No Internet Connection';
      case ErrorType.server:
        return 'Server Error';
      case ErrorType.auth:
        return 'Session Expired';
      case ErrorType.notFound:
        return 'Not Found';
      case ErrorType.validation:
        return 'Invalid Data';
      case ErrorType.timeout:
        return 'Request Timeout';
      case ErrorType.empty:
        return AppStrings.statusEmpty;
      case ErrorType.unknown:
        return 'Oops!';
    }
  }

  String _getDefaultMessage() {
    switch (errorType) {
      case ErrorType.network:
        return 'Please check your internet connection and try again.';
      case ErrorType.server:
        return 'Something went wrong on our end. Please try again later.';
      case ErrorType.auth:
        return 'Your session has expired. Please login again.';
      case ErrorType.notFound:
        return 'The requested resource was not found.';
      case ErrorType.validation:
        return 'Please check your input and try again.';
      case ErrorType.timeout:
        return 'The request took too long. Please try again.';
      case ErrorType.empty:
        return 'No data available at the moment.';
      case ErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}

/// Extension to easily show error widget in place of child
extension ErrorWidgetExtension on Widget {
  Widget withErrorHandler(
    dynamic error, {
    VoidCallback? onRetry,
    bool showRetry = true,
  }) {
    if (error != null) {
      return AppErrorWidget.fromException(
        error,
        onRetry: onRetry,
        showRetryButton: showRetry,
      );
    }
    return this;
  }
}
