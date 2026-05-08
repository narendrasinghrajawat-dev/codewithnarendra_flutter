import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../exceptions/app_exceptions.dart';

/// Service for handling and displaying errors throughout the app
class ErrorHandlerService {
  /// Show error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onRetry,
    String? retryLabel,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: retryLabel ?? 'RETRY',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onRetry();
                },
              )
            : null,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }

  /// Show warning snackbar
  static void showWarningSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning_amber_outlined,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange[800],
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[700],
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }

  /// Get user-friendly error message from exception
  static String getErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error is ServerException) {
      return 'Server error occurred. Please try again later.';
    } else if (error is AuthenticationException) {
      return 'Your session has expired. Please login again.';
    } else if (error is AuthorizationException) {
      return 'You don\'t have permission to perform this action.';
    } else if (error is NotFoundException) {
      return 'The requested resource was not found.';
    } else if (error is ValidationException) {
      return error.message;
    } else if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Log error for debugging
  static void logError(dynamic error, StackTrace? stackTrace, {String? context}) {
    print('╔══════════════════════════════════════════════════════════════╗');
    print('║                        ERROR OCCURRED                        ║');
    print('╠══════════════════════════════════════════════════════════════╣');
    if (context != null) {
      print('║ Context: $context');
    }
    print('║ Error: $error');
    if (stackTrace != null) {
      print('║ StackTrace: $stackTrace');
    }
    print('╚══════════════════════════════════════════════════════════════╝');
  }
}

/// Provider for ErrorHandlerService
final errorHandlerServiceProvider = Provider<ErrorHandlerService>((ref) {
  return ErrorHandlerService();
});
