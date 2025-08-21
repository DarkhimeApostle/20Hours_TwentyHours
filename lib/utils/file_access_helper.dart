import 'dart:io';
import 'package:path_provider/path_provider.dart';
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
      final internalBackupDir = '${appDir.path}/t20_backup';
      directories.add(internalBackupDir);

      // 2. 外部存储目录（需要权限）
      if (await PermissionHelper.hasStoragePermission()) {
        try {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            final externalBackupDir = '${externalDir.path}/t20_backup';
            directories.add(externalBackupDir);
          }
        } catch (e) {}

        // 3. 尝试访问Download目录
        try {
          final downloadDir = '/storage/emulated/0/Download/t20_backup';
          if (await Directory(downloadDir).exists()) {
            directories.add(downloadDir);
          }
        } catch (e) {}
      }

      // 4. 尝试访问Documents目录
      try {
        final documentsDir = '/storage/emulated/0/Documents/t20_backup';
        if (await Directory(documentsDir).exists()) {
          directories.add(documentsDir);
        }
      } catch (e) {}
    } catch (e) {}

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
            return configFile.path;
          }
        } catch (e) {}
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 安全读取文件
  static Future<String> safeReadFile(String filePath) async {
    try {
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

      if (fileSize > 10 * 1024 * 1024) {
        // 10MB限制
        throw Exception('文件过大: $fileSize bytes');
      }

      // 尝试读取文件
      String content;
      try {
        content = await file.readAsString();
      } catch (e) {
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

      return content;
    } catch (e) {
      rethrow;
    }
  }

  /// 安全写入文件
  static Future<void> safeWriteFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      final directory = file.parent;

      // 确保目录存在
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 写入文件
      await file.writeAsString(content);
    } catch (e) {
      rethrow;
    }
  }

  /// 测试文件访问权限
  static Future<bool> testFileAccess(String path) async {
    try {
      final directory = Directory(path);

      // 检查目录是否存在
      if (!await directory.exists()) {
        return false;
      }

      // 尝试列出目录内容
      try {
        await directory.list().take(1).toList();

        return true;
      } catch (e) {
        return false;
      }
    } catch (e) {
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
      return {'exists': false, 'error': e.toString()};
    }
  }

  /// 创建备份目录
  static Future<String> createBackupDirectory() async {
    try {
      // 优先使用应用内部存储
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = '${appDir.path}/t20_backup';

      final directory = Directory(backupDir);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      return backupDir;
    } catch (e) {
      rethrow;
    }
  }

  /// 复制文件
  static Future<void> copyFile(String sourcePath, String targetPath) async {
    try {
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
    } catch (e) {
      rethrow;
    }
  }

  /// 删除文件或目录
  static Future<void> deleteFileOrDirectory(String path) async {
    try {
      final entity =
          FileSystemEntity.typeSync(path) == FileSystemEntityType.directory
          ? Directory(path)
          : File(path);

      if (await entity.exists()) {
        if (entity is Directory) {
          await entity.delete(recursive: true);
        } else {
          await entity.delete();
        }
      } else {}
    } catch (e) {
      rethrow;
    }
  }
}
