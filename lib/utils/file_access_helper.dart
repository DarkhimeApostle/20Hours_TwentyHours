import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'permission_helper.dart';

/// 文件访问助手类
/// 专门处理Android 11+的文件访问问题
class FileAccessHelper {
  static const String _tag = 'FileAccessHelper';

  /// 获取可访问的备份目录列表
  static Future<List<String>> getAccessibleBackupDirectories() async {
    final List<String> directories = [];

    try {
      // 1. 应用内部存储目录（无需权限）
      final appDir = await getApplicationDocumentsDirectory();
      final internalBackupDir = '${appDir.path}/20timer_backup';
      directories.add(internalBackupDir);
      print('$_tag: 添加内部存储目录: $internalBackupDir');

      // 2. 外部存储目录（需要权限）
      if (await PermissionHelper.hasStoragePermission()) {
        try {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            final externalBackupDir = '${externalDir.path}/20timer_backup';
            directories.add(externalBackupDir);
            print('$_tag: 添加外部存储目录: $externalBackupDir');
          }
        } catch (e) {
          print('$_tag: 获取外部存储目录失败: $e');
        }

        // 3. 尝试访问Download目录
        try {
          final downloadDir = '/storage/emulated/0/Download/20timer_backup';
          if (await Directory(downloadDir).exists()) {
            directories.add(downloadDir);
            print('$_tag: 添加Download目录: $downloadDir');
          }
        } catch (e) {
          print('$_tag: 访问Download目录失败: $e');
        }
      }

      // 4. 尝试访问Documents目录
      try {
        final documentsDir = '/storage/emulated/0/Documents/20timer_backup';
        if (await Directory(documentsDir).exists()) {
          directories.add(documentsDir);
          print('$_tag: 添加Documents目录: $documentsDir');
        }
      } catch (e) {
        print('$_tag: 访问Documents目录失败: $e');
      }

    } catch (e) {
      print('$_tag: 获取可访问目录时发生错误: $e');
    }

    print('$_tag: 找到 ${directories.length} 个可访问的备份目录');
    return directories;
  }

  /// 自动查找配置文件
  static Future<String?> findConfigFile() async {
    try {
      final directories = await getAccessibleBackupDirectories();
      
      for (final dir in directories) {
        try {
          final configFile = File('$dir/config.json');
          if (await configFile.exists()) {
            print('$_tag: 找到配置文件: ${configFile.path}');
            return configFile.path;
          }
        } catch (e) {
          print('$_tag: 检查目录 $dir 失败: $e');
        }
      }
      
      print('$_tag: 未找到配置文件');
      return null;
    } catch (e) {
      print('$_tag: 查找配置文件时发生错误: $e');
      return null;
    }
  }

  /// 安全读取文件
  static Future<String> safeReadFile(String filePath) async {
    try {
      print('$_tag: 尝试读取文件: $filePath');
      
      // 检查文件是否存在
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在: $filePath');
      }

      // 检查文件大小
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('文件为空: $filePath');
      }
      
      if (fileSize > 10 * 1024 * 1024) { // 10MB限制
        throw Exception('文件过大: ${fileSize} bytes');
      }

      print('$_tag: 文件大小: $fileSize bytes');

      // 尝试读取文件
      String content;
      try {
        content = await file.readAsString();
      } catch (e) {
        print('$_tag: 直接读取失败，尝试使用权限: $e');
        
        // 如果直接读取失败，尝试请求权限
        if (await PermissionHelper.requestStoragePermission(null)) {
          content = await file.readAsString();
        } else {
          throw Exception('无法读取文件，权限不足: $e');
        }
      }

      if (content.isEmpty) {
        throw Exception('文件内容为空');
      }

      print('$_tag: 成功读取文件，内容长度: ${content.length}');
      return content;
    } catch (e) {
      print('$_tag: 读取文件失败: $e');
      rethrow;
    }
  }

  /// 安全写入文件
  static Future<void> safeWriteFile(String filePath, String content) async {
    try {
      print('$_tag: 尝试写入文件: $filePath');
      
      final file = File(filePath);
      final directory = file.parent;
      
      // 确保目录存在
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        print('$_tag: 创建目录: ${directory.path}');
      }

      // 写入文件
      await file.writeAsString(content);
      print('$_tag: 成功写入文件: $filePath');
    } catch (e) {
      print('$_tag: 写入文件失败: $e');
      rethrow;
    }
  }

  /// 测试文件访问权限
  static Future<bool> testFileAccess(String path) async {
    try {
      print('$_tag: 测试文件访问权限: $path');
      
      final directory = Directory(path);
      
      // 检查目录是否存在
      if (!await directory.exists()) {
        print('$_tag: 目录不存在: $path');
        return false;
      }

      // 尝试列出目录内容
      try {
        await directory.list().take(1).toList();
        print('$_tag: 目录访问成功: $path');
        return true;
      } catch (e) {
        print('$_tag: 目录访问失败: $path, 错误: $e');
        return false;
      }
    } catch (e) {
      print('$_tag: 测试文件访问权限时发生错误: $e');
      return false;
    }
  }

  /// 获取文件信息
  static Future<Map<String, dynamic>> getFileInfo(String filePath) async {
    try {
      final file = File(filePath);
      final stat = await file.stat();
      
      return {
        'exists': await file.exists(),
        'size': stat.size,
        'modified': stat.modified,
        'accessed': stat.accessed,
        'changed': stat.changed,
      };
    } catch (e) {
      print('$_tag: 获取文件信息失败: $e');
      return {
        'exists': false,
        'error': e.toString(),
      };
    }
  }

  /// 创建备份目录
  static Future<String> createBackupDirectory() async {
    try {
      // 优先使用应用内部存储
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = '${appDir.path}/20timer_backup';
      
      final directory = Directory(backupDir);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        print('$_tag: 创建备份目录: $backupDir');
      }
      
      return backupDir;
    } catch (e) {
      print('$_tag: 创建备份目录失败: $e');
      rethrow;
    }
  }

  /// 复制文件
  static Future<void> copyFile(String sourcePath, String targetPath) async {
    try {
      print('$_tag: 复制文件: $sourcePath -> $targetPath');
      
      final sourceFile = File(sourcePath);
      final targetFile = File(targetPath);
      
      if (!await sourceFile.exists()) {
        throw Exception('源文件不存在: $sourcePath');
      }
      
      // 确保目标目录存在
      final targetDir = targetFile.parent;
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
      
      await sourceFile.copy(targetPath);
      print('$_tag: 文件复制成功');
    } catch (e) {
      print('$_tag: 复制文件失败: $e');
      rethrow;
    }
  }

  /// 删除文件或目录
  static Future<void> deleteFileOrDirectory(String path) async {
    try {
      print('$_tag: 删除: $path');
      
      final entity = FileSystemEntity.typeSync(path) == FileSystemEntityType.directory
          ? Directory(path)
          : File(path);
      
      if (await entity.exists()) {
        if (entity is Directory) {
          await entity.delete(recursive: true);
        } else {
          await entity.delete();
        }
        print('$_tag: 删除成功: $path');
      } else {
        print('$_tag: 文件或目录不存在: $path');
      }
    } catch (e) {
      print('$_tag: 删除失败: $e');
      rethrow;
    }
  }
} 