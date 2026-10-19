import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:omidvpn/ui/shared/widgets/notification_permission_dialog.dart';

class NotificationPermissionService {
  static const MethodChannel _platform = MethodChannel('vpn_notification');

  /// Check if notification permission is granted
  static Future<bool> isNotificationPermissionGranted() async {
    if (!Platform.isAndroid) return true;
    
    try {
      // First, try to use the notification_permissions package
      final permissionStatus = await Permission.notification.status;
      return permissionStatus == PermissionStatus.granted;
    } catch (e) {
      // Fallback to the native implementation
      try {
        return await _platform.invokeMethod('checkNotificationPermission') as bool;
      } catch (e) {
        // If both methods fail, assume permission is needed
        return false;
      }
    }
  }

  /// Request notification permission
  static Future<bool> requestNotificationPermission(BuildContext context) async {
    if (!Platform.isAndroid) return true;
    
    try {
      // First, try to use the notification_permissions package
      final permissionStatus = await Permission.notification.status;
      
      if (permissionStatus == PermissionStatus.granted) {
        return true;
      } else {
        // Show a dialog to inform the user
        final shouldRequest = await showDialog<bool>(
          context: context,
          builder: (context) => const NotificationPermissionDialog(),
        );
        
        if (shouldRequest != true) {
          return false;
        }
        
        // Request notification permission
        final result = await Permission.notification.request();
        return result == PermissionStatus.granted;
      }
    } catch (e) {
      // Fallback to the native implementation
      try {
        // Show a dialog to inform the user
        final shouldRequest = await showDialog<bool>(
          context: context,
          builder: (context) => const NotificationPermissionDialog(),
        );
        
        if (shouldRequest != true) {
          return false;
        }
        
        await _platform.invokeMethod('requestNotificationPermission');
        // Wait a bit for user to grant permission
        await Future.delayed(Duration(seconds: 2));
        
        // Check if permission was granted
        return await isNotificationPermissionGranted();
      } catch (e) {
        // Handle error silently
        return false;
      }
    }
  }
}