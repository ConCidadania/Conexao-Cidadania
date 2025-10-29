import 'package:flutter/material.dart';

/// Abstract interface for showing messages to users
abstract class MessageService {
  void showSuccess(String message);
  void showError(String message);
  void showInfo(String message);
}

/// Implementation of MessageService using SnackBar
class SnackBarMessageService implements MessageService {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  SnackBarMessageService({required this.scaffoldMessengerKey});

  @override
  void showSuccess(String message) {
    _showSnackBar(
      message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  @override
  void showError(String message) {
    _showSnackBar(
      message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }

  @override
  void showInfo(String message) {
    _showSnackBar(
      message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
    );
  }

  void _showSnackBar(
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    final context = scaffoldMessengerKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}

/// Implementation using the existing showMessage utility
class LegacyMessageService implements MessageService {
  final BuildContext context;

  LegacyMessageService({required this.context});

  @override
  void showSuccess(String message) {
    _showMessage(context, message);
  }

  @override
  void showError(String message) {
    _showMessage(context, message);
  }

  @override
  void showInfo(String message) {
    _showMessage(context, message);
  }

  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
