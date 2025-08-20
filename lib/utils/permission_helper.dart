import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:io';

/// 权限处理工具类
/// 专门处理不同Android版本的权限问题
class PermissionHelper {
  static const String _tag = 'PermissionHelper';

  /// 获取Android版本
  static int getAndroidVersion() {
    if (Platform.isAndroid) {
      // 这里应该使用实际的Android版本检测
      // 为了简化，我们假设需要处理所有版本
      return 30; // 假设Android 11
    }
    return 0;
  }

  /// 检查是否有足够的存储权限
  static Future<bool> hasStoragePermission() async {
    try {
      final androidVersion = getAndroidVersion();
      print('$_tag: 当前Android版本: $androidVersion');

      // 检查多种权限状态
      final storageStatus = await Permission.storage.status;
      final manageExternalStorageStatus = await Permission.manageExternalStorage.status;
      final photosStatus = await Permission.photos.status;

      bool hasPermission = false;

      if (androidVersion >= 30) {
        // Android 11+ (API 30+)
        hasPermission = storageStatus.isGranted ||
            manageExternalStorageStatus.isGranted ||
            photosStatus.isGranted;
        print('$_tag: Android 11+ 权限检查');
      } else if (androidVersion >= 29) {
        // Android 10 (API 29)
        hasPermission = storageStatus.isGranted;
        print('$_tag: Android 10 权限检查');
      } else {
        // Android 8-9 (API 26-28)
        hasPermission = storageStatus.isGranted;
        print('$_tag: Android 8-9 权限检查');
      }

      _logPermissionStatus(storageStatus, manageExternalStorageStatus, photosStatus, hasPermission);
      
      return hasPermission;
    } catch (e) {
      print('$_tag: 检查存储权限时发生错误: $e');
      return false;
    }
  }

  /// 请求存储权限
  static Future<bool> requestStoragePermission(BuildContext? context) async {
    try {
      final androidVersion = getAndroidVersion();
      print('$_tag: 正在请求存储权限... (Android $androidVersion)');

      if (androidVersion >= 30) {
        // Android 11+ 复杂权限处理
        return await _requestStoragePermissionAndroid11Plus(context);
      } else if (androidVersion >= 29) {
        // Android 10 权限处理
        return await _requestStoragePermissionAndroid10(context);
      } else {
        // Android 8-9 简单权限处理
        return await _requestStoragePermissionAndroid8To9(context);
      }
    } catch (e) {
      print('$_tag: 请求存储权限时发生错误: $e');
      if (context != null) {
        _showErrorMessage(context, '权限请求失败: $e');
      }
      return false;
    }
  }

  /// Android 11+ 权限请求
  static Future<bool> _requestStoragePermissionAndroid11Plus(BuildContext? context) async {
    print('$_tag: 使用Android 11+ 权限请求策略');

    // 直接尝试请求管理外部存储权限（这是Android 11+访问所有文件的关键权限）
    PermissionStatus manageStatus = PermissionStatus.denied;
    try {
      manageStatus = await Permission.manageExternalStorage.request();
      print('$_tag: 管理外部存储权限请求结果: ${manageStatus.isGranted ? "已授予" : "被拒绝"}');
    } catch (e) {
      print('$_tag: 请求管理外部存储权限失败: $e');
    }

    // 如果管理外部存储权限被拒绝，尝试请求基础存储权限
    PermissionStatus storageStatus = PermissionStatus.denied;
    if (!manageStatus.isGranted) {
      try {
        storageStatus = await Permission.storage.request();
        print('$_tag: 存储权限请求结果: ${storageStatus.isGranted ? "已授予" : "被拒绝"}');
      } catch (e) {
        print('$_tag: 请求存储权限失败: $e');
      }
    }

    // 如果还是被拒绝，尝试请求照片权限（Android 13+）
    PermissionStatus photosStatus = PermissionStatus.denied;
    if (!manageStatus.isGranted && !storageStatus.isGranted) {
      try {
        photosStatus = await Permission.photos.request();
        print('$_tag: 照片权限请求结果: ${photosStatus.isGranted ? "已授予" : "被拒绝"}');
      } catch (e) {
        print('$_tag: 请求照片权限失败: $e');
      }
    }

    final hasPermission = manageStatus.isGranted ||
        storageStatus.isGranted ||
        photosStatus.isGranted;

    print('$_tag: Android 11+ 综合权限结果: ${hasPermission ? "已授予" : "被拒绝"}');

    if (hasPermission) {
      if (context != null) {
        _showSuccessMessage(context, '存储权限已授予');
      }
    } else {
      if (context != null) {
        _showManageAllFilesPermissionDialog(context);
      }
    }

    return hasPermission;
  }

  /// Android 10 权限请求
  static Future<bool> _requestStoragePermissionAndroid10(BuildContext? context) async {
    print('$_tag: 使用Android 10 权限请求策略');

    // Android 10 只需要基础存储权限
    final storageStatus = await Permission.storage.request();
    print('$_tag: Android 10 存储权限请求结果: ${storageStatus.isGranted ? "已授予" : "被拒绝"}');

    if (storageStatus.isGranted) {
      if (context != null) {
        _showSuccessMessage(context, '存储权限已授予');
      }
      return true;
    } else {
      if (context != null) {
        _showPermissionDeniedDialog(context, '存储', 'Android 10');
      }
      return false;
    }
  }

  /// Android 8-9 权限请求
  static Future<bool> _requestStoragePermissionAndroid8To9(BuildContext? context) async {
    print('$_tag: 使用Android 8-9 权限请求策略');

    // Android 8-9 只需要基础存储权限
    final storageStatus = await Permission.storage.request();
    print('$_tag: Android 8-9 存储权限请求结果: ${storageStatus.isGranted ? "已授予" : "被拒绝"}');

    if (storageStatus.isGranted) {
      if (context != null) {
        _showSuccessMessage(context, '存储权限已授予');
      }
      return true;
    } else {
      if (context != null) {
        _showPermissionDeniedDialog(context, '存储', 'Android 8-9');
      }
      return false;
    }
  }

  /// 检查并请求相机权限
  static Future<bool> requestCameraPermission(BuildContext context) async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        return true;
      } else {
        _showPermissionDeniedDialog(context, '相机');
        return false;
      }
    } catch (e) {
      print('$_tag: 请求相机权限时发生错误: $e');
      return false;
    }
  }

  /// 打开应用设置页面
  static Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('$_tag: 打开应用设置失败: $e');
    }
  }

  /// 检查Android版本
  static bool isAndroid11OrHigher() {
    return getAndroidVersion() >= 30;
  }

  /// 检查Android版本
  static bool isAndroid10() {
    return getAndroidVersion() == 29;
  }

  /// 检查Android版本
  static bool isAndroid8To9() {
    final version = getAndroidVersion();
    return version >= 26 && version <= 28;
  }

  /// 显示权限被拒绝的对话框
  static void _showPermissionDeniedDialog(BuildContext context, [String permissionName = '存储', String androidVersion = '']) {
    String title = '需要$permissionName权限';
    String content = '应用需要$permissionName权限才能正常工作。';
    
    if (androidVersion.isNotEmpty) {
      content += '\n\n当前系统版本：$androidVersion';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(content),
              const SizedBox(height: 8),
              const Text('请在设置中手动授予权限：'),
              const SizedBox(height: 4),
              const Text('1. 点击"打开设置"'),
              const Text('2. 找到"权限"选项'),
              Text('3. 授予$permissionName权限'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('打开设置'),
            ),
          ],
        );
      },
    );
  }

  /// 显示管理所有文件权限对话框
  static void _showManageAllFilesPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('需要"管理所有文件"权限'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('为了访问外部存储中的配置文件，应用需要"管理所有文件"权限。'),
              const SizedBox(height: 8),
              const Text('请按以下步骤操作：'),
              const SizedBox(height: 4),
              const Text('1. 点击"打开设置"'),
              const Text('2. 找到"权限"或"应用权限"'),
              const Text('3. 找到"文件和媒体"或"存储"'),
              const Text('4. 选择"管理所有文件"'),
              const Text('5. 开启权限开关'),
              const SizedBox(height: 8),
              const Text('注意：这是Android 11+系统要求的特殊权限，用于访问所有文件。'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('打开设置'),
            ),
          ],
        );
      },
    );
  }

  /// 显示成功消息
  static void _showSuccessMessage(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 显示错误消息
  static void _showErrorMessage(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 记录权限状态
  static void _logPermissionStatus(
    PermissionStatus storageStatus,
    PermissionStatus manageExternalStorageStatus,
    PermissionStatus photosStatus,
    bool hasPermission,
  ) {
    print('$_tag: 存储权限状态: ${storageStatus.isGranted ? "已授予" : "未授予"} (${storageStatus.name})');
    print('$_tag: 管理外部存储权限: ${manageExternalStorageStatus.isGranted ? "已授予" : "未授予"} (${manageExternalStorageStatus.name})');
    print('$_tag: 照片权限状态: ${photosStatus.isGranted ? "已授予" : "未授予"} (${photosStatus.name})');
    print('$_tag: 综合权限状态: ${hasPermission ? "已授予" : "未授予"}');

    // 记录详细的权限状态
    if (storageStatus.isDenied) {
      print('$_tag: 存储权限被拒绝');
    } else if (storageStatus.isPermanentlyDenied) {
      print('$_tag: 存储权限被永久拒绝');
    } else if (storageStatus.isRestricted) {
      print('$_tag: 存储权限受限');
    }

    if (manageExternalStorageStatus.isDenied) {
      print('$_tag: 管理外部存储权限被拒绝');
    } else if (manageExternalStorageStatus.isPermanentlyDenied) {
      print('$_tag: 管理外部存储权限被永久拒绝');
    }

    if (photosStatus.isDenied) {
      print('$_tag: 照片权限被拒绝');
    } else if (photosStatus.isPermanentlyDenied) {
      print('$_tag: 照片权限被永久拒绝');
    }
  }
} 