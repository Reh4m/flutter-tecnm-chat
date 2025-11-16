import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/presentation/config/themes/color_palette.dart';
import 'package:toastification/toastification.dart';

enum ToastNotificationType { success, error, info, warning }

class ToastNotification {
  static void show(
    BuildContext context, {
    required String title,
    required String description,
    ToastNotificationType type = ToastNotificationType.success,
  }) {
    toastification.show(
      context: context,
      type: _mapToToastificationType(type),
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 5),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      description: Text(
        description,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
        ),
      ),
      alignment: Alignment.topCenter,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 500),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      icon: _buildNotificationIcon(type),
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none,
      closeOnClick: false,
      dragToClose: true,
    );
  }

  static ToastificationType _mapToToastificationType(
    ToastNotificationType type,
  ) {
    switch (type) {
      case ToastNotificationType.success:
        return ToastificationType.success;
      case ToastNotificationType.error:
        return ToastificationType.error;
      case ToastNotificationType.info:
        return ToastificationType.info;
      case ToastNotificationType.warning:
        return ToastificationType.warning;
    }
  }

  static Widget _buildNotificationIcon(ToastNotificationType type) {
    switch (type) {
      case ToastNotificationType.success:
        return _notificationIcon(
          icon: Icons.task_alt_outlined,
          color: ColorPalette.success,
          backgroundColor: ColorPalette.successLight.withAlpha(50),
        );
      case ToastNotificationType.error:
        return _notificationIcon(
          icon: Icons.error_outline_outlined,
          color: ColorPalette.error,
          backgroundColor: ColorPalette.errorLight.withAlpha(50),
        );
      case ToastNotificationType.info:
        return _notificationIcon(
          icon: Icons.info_outline,
          color: ColorPalette.info,
          backgroundColor: ColorPalette.infoLight.withAlpha(50),
        );
      case ToastNotificationType.warning:
        return _notificationIcon(
          icon: Icons.warning_amber_rounded,
          color: ColorPalette.warning,
          backgroundColor: ColorPalette.warningLight.withAlpha(50),
        );
    }
  }

  static Widget _notificationIcon({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      height: 35.0,
      width: 35.0,
      decoration: BoxDecoration(shape: BoxShape.circle, color: backgroundColor),
      child: Icon(icon, color: color, size: 25.0),
    );
  }
}
