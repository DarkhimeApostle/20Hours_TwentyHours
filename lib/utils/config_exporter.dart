import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skill_model.dart';
import '../utils/group_storage.dart';

// 配置导出工具类
class ConfigExporter {
  // 自动导出配置功能已禁用
  static Future<void> autoExportConfig() async {
    // 完全禁用自动导出功能，避免干扰用户文件
    print('自动导出功能已禁用');
  }
}
