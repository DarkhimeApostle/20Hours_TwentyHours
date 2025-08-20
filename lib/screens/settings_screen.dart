import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../main.dart';
import '../models/skill_model.dart';
import '../models/skill_group.dart';
import '../utils/group_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/permission_helper.dart';
import '../utils/file_access_helper.dart';
import '../utils/config_exporter.dart';
import '../utils/app_state_notifier.dart';

// 设置页面，支持自定义头像和侧边栏背景
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _avatarPath;
  String? _drawerBgPath;
  String _userName = '开发者';
  bool _hasStoragePermission = false;
  final TextEditingController _userNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadImagePaths();
    _loadUserName();
    _checkStoragePermission();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  // 加载图片路径
  Future<void> _loadImagePaths() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarPath = prefs.getString('user_avatar_path');
      _drawerBgPath = prefs.getString('drawer_bg_path');
    });
    print('加载图片路径:');
    print('  头像路径: $_avatarPath');
    print('  背景路径: $_drawerBgPath');
  }

  // 加载用户名
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name') ?? '开发者';
    setState(() {
      _userName = userName;
      _userNameController.text = userName;
    });
  }

  // 检查存储权限
  Future<void> _checkStoragePermission() async {
    try {
      final hasPermission = await PermissionHelper.hasStoragePermission();
      setState(() {
        _hasStoragePermission = hasPermission;
      });
    } catch (e) {
      print('检查存储权限时发生错误: $e');
      setState(() {
        _hasStoragePermission = false;
      });
    }
  }

  // 请求存储权限
  Future<void> _requestStoragePermission() async {
    try {
      final granted = await PermissionHelper.requestStoragePermission(context);
      setState(() {
        _hasStoragePermission = granted;
      });
    } catch (e) {
      print('请求存储权限时发生错误: $e');
    }
  }

  // 选择图片并保存到本地
  Future<void> _pickAndSaveImage({required bool isAvatar}) async {
    try {
      // 检查存储权限
      if (!await PermissionHelper.hasStoragePermission()) {
        final granted = await PermissionHelper.requestStoragePermission(context);
        if (!granted) {
          print('用户拒绝了存储权限，无法选择图片');
          return;
        }
      }

      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final imageFile = File(picked.path);
      if (!await imageFile.exists()) {
        throw Exception('选择的图片文件不存在');
      }

      // 保存图片到应用内部存储
      await _saveImageToLocal(imageFile, isAvatar);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isAvatar ? '头像' : '背景图片'}设置成功！'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('保存图片时发生错误: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('设置${isAvatar ? '头像' : '背景图片'}失败: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // 保存图片到本地
  Future<void> _saveImageToLocal(File imageFile, bool isAvatar) async {
    try {
      // 使用应用内部存储目录
      final appDir = await getApplicationDocumentsDirectory();
      String backupPath = '${appDir.path}/20timer_backup';
      print('使用应用内部存储目录: $backupPath');

      // 创建或清空备份目录
      final backupDir = Directory(backupPath);
      if (await backupDir.exists()) {
        // 如果目录存在，删除所有内容
        try {
          await backupDir.delete(recursive: true);
        } catch (e) {
          print('删除旧备份目录失败: $e');
          // 如果删除失败，尝试使用新的目录名
          backupPath = '${backupPath}_${DateTime.now().millisecondsSinceEpoch}';
          final newBackupDir = Directory(backupPath);
          await newBackupDir.create(recursive: true);
          print('使用新备份目录: $backupPath');
        }
      }

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // 保存图片
      final fileName = isAvatar ? 'avatar.png' : 'drawer_bg.jpg';
      final savedImagePath = '${backupDir.path}/$fileName';
      await imageFile.copy(savedImagePath);

      // 保存路径到SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final key = isAvatar ? 'user_avatar_path' : 'drawer_bg_path';
      await prefs.setString(key, savedImagePath);

      // 更新状态
      setState(() {
        if (isAvatar) {
          _avatarPath = savedImagePath;
        } else {
          _drawerBgPath = savedImagePath;
        }
      });

      print('备份目录: ${backupDir.path}');
    } catch (e) {
      print('保存图片时发生错误: $e');
      rethrow;
    }
  }

  // 自动导出配置
  Future<void> _autoExportConfig() async {
    try {
      // 调用ConfigExporter的自动导出方法
      await ConfigExporter.autoExportConfig();

      if (mounted && context.mounted && Navigator.of(context).mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('配置已成功导出到应用内部存储'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('导出配置时发生错误: $e');
      if (mounted && context.mounted && Navigator.of(context).mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // 手动导出配置
  Future<void> _manualExportConfig() async {
    try {
      // 检查存储权限
      if (!await PermissionHelper.hasStoragePermission()) {
        final granted = await PermissionHelper.requestStoragePermission(context);
        if (!granted) {
          throw Exception('需要存储权限才能导出配置');
        }
      }

      // 让用户选择导出目录
      final selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择导出目录',
        initialDirectory: '/storage/emulated/0/Download',
      );

      if (selectedDirectory == null || selectedDirectory.isEmpty) {
        throw Exception('未选择有效的导出目录');
      }

      print('用户选择的导出目录: $selectedDirectory');

      // 创建备份目录
      final backupPath = '$selectedDirectory/20timer_backup';
      final backupDir = Directory(backupPath);

      if (await backupDir.exists()) {
        // 如果目录存在，删除所有内容
        try {
          await backupDir.delete(recursive: true);
        } catch (e) {
          print('删除旧备份目录失败: $e');
          // 如果删除失败，尝试使用新的目录名
          final newBackupPath = '${backupPath}_${DateTime.now().millisecondsSinceEpoch}';
          final newBackupDir = Directory(newBackupPath);
          await newBackupDir.create(recursive: true);
          print('使用新备份目录: $newBackupPath');
        }
      }

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      print('备份目录: ${backupDir.path}');

      final prefs = await SharedPreferences.getInstance();

      // 收集配置数据
      final Map<String, dynamic> configData = {
        'version': '1.0',
        'exportTime': DateTime.now().toIso8601String(),
        'userInfo': {
          'userName': prefs.getString('user_name') ?? '开发者',
          'avatarPath': _avatarPath,
          'drawerBgPath': _drawerBgPath,
        },
        'skills': {'mainSkills': [], 'hallOfGlorySkills': []},
        'diaries': {},
        'congratulatedSkills': prefs.getStringList('congratulated_skill_ids') ?? [],
        'groups': [],
      };

      // 获取所有技能数据
      final List<String>? skillsAsString = prefs.getStringList('skills_list_key');
      if (skillsAsString != null && skillsAsString.isNotEmpty) {
        final List<Skill> allSkills = skillsAsString
            .map((e) => Skill.fromMap(Map<String, dynamic>.from(jsonDecode(e))))
            .toList();

        // 分离主页面和荣耀殿堂的技能
        for (final skill in allSkills) {
          final skillData = skill.toMap();
          if (skill.inHallOfGlory) {
            configData['skills']['hallOfGlorySkills'].add(skillData);
          } else {
            configData['skills']['mainSkills'].add(skillData);
          }

          // 获取技能日记
          final diaryKey = 'skill_diary_${skill.name}';
          final diaryList = prefs.getStringList(diaryKey);
          if (diaryList != null && diaryList.isNotEmpty) {
            configData['diaries'][skill.name] = diaryList;
          }
        }
      }

      // 获取技能分组数据
      final groups = await GroupStorage.loadGroups();
      configData['groups'] = groups.map((g) => g.toMap()).toList();

      // 复制头像和背景图片
      if (_avatarPath != null && _avatarPath!.isNotEmpty) {
        try {
          final avatarFile = File(_avatarPath!);
          if (await avatarFile.exists()) {
            // 保持原始文件扩展名
            final extension = _avatarPath!.split('.').last;
            final backupAvatarPath = '${backupDir.path}/avatar.$extension';
            await avatarFile.copy(backupAvatarPath);
            print('头像已复制: $backupAvatarPath (原格式: $extension)');
          } else {
            print('头像文件不存在: $_avatarPath');
          }
        } catch (e) {
          print('复制头像失败: $e');
        }
      } else {
        print('没有头像路径');
      }

      if (_drawerBgPath != null && _drawerBgPath!.isNotEmpty) {
        try {
          final bgFile = File(_drawerBgPath!);
          if (await bgFile.exists()) {
            // 保持原始文件扩展名
            final extension = _drawerBgPath!.split('.').last;
            final backupBgPath = '${backupDir.path}/drawer_bg.$extension';
            await bgFile.copy(backupBgPath);
            print('背景图片已复制: $backupBgPath (原格式: $extension)');
          } else {
            print('背景图片文件不存在: $_drawerBgPath');
          }
        } catch (e) {
          print('复制背景图片失败: $e');
        }
      } else {
        print('没有背景图片路径');
      }

      // 保存配置文件
      final configFile = File('${backupDir.path}/config.json');
      final configJson = jsonEncode(configData);
      await configFile.writeAsString(configJson);

      print('配置文件内容长度: ${configJson.length} 字符');
      print('配置文件已保存: ${configFile.path}');

      // 验证保存的文件
      final savedContent = await configFile.readAsString();
      if (savedContent != configJson) {
        throw Exception('配置文件保存验证失败');
      }

      print('保存的配置文件内容长度: ${savedContent.length} 字符');

      // 列出备份目录内容
      print('备份目录内容:');
      final files = await backupDir.list().toList();
      for (final file in files) {
        print('  - ${file.path.split('/').last}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('配置导出成功！'),
                Text('导出目录: ${backupDir.path}', style: const TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            dismissDirection: DismissDirection.horizontal,
          ),
        );
      }
    } catch (e) {
      print('保存配置文件时发生错误: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('导出失败'),
                Text(e.toString(), style: const TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            dismissDirection: DismissDirection.horizontal,
          ),
        );
      }
    }
  }

  // 导入配置
  Future<void> _importConfig() async {
    try {
      print('开始自动导入配置...');
      
      // 直接在应用内部存储目录查找配置文件
      final appDir = await getApplicationDocumentsDirectory();
      final backupPath = '${appDir.path}/20timer_backup';
      final configFile = File('$backupPath/config.json');
      
      print('查找配置文件: ${configFile.path}');
      
      if (!await configFile.exists()) {
        throw Exception('未找到自动备份配置文件\n请确保已导出配置或手动选择备份文件夹');
      }

      // 读取配置文件
      final configContent = await configFile.readAsString();
      if (configContent.isEmpty) {
        throw Exception('配置文件为空');
      }

      print('找到配置文件，大小: ${configContent.length} 字符');

      // 处理配置文件
      final backupDir = Directory(backupPath);
      await _processConfigFile(configContent, backupDir);

      if (mounted && context.mounted && Navigator.of(context).mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('自动导入配置成功！'),
                Text('配置文件: ${configFile.path}', style: const TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('自动导入配置时发生错误: $e');
      if (mounted && context.mounted && Navigator.of(context).mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('自动导入失败'),
                Text(e.toString(), style: const TextStyle(fontSize: 12)),
                const Text('请长按"导入配置"按钮手动选择备份文件夹', style: TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            dismissDirection: DismissDirection.horizontal,
          ),
        );
      }
    }
  }

  // 手动导入配置
  Future<void> _manualImportConfig() async {
    try {
      print('开始手动导入配置...');
      
      // 直接请求管理外部存储权限
      final granted = await PermissionHelper.requestStoragePermission(context);
      if (!granted) {
        throw Exception('需要存储权限才能选择文件夹\n请在设置中授予存储权限');
      }

      // 让用户选择文件夹
      final selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择备份文件夹',
        initialDirectory: '/storage/emulated/0/Download',
      );

      if (selectedDirectory == null || selectedDirectory.isEmpty) {
        throw Exception('未选择有效的备份文件夹');
      }

      print('用户选择的目录: $selectedDirectory');

      // 查找配置文件
      final configFile = File('$selectedDirectory/config.json');
      print('尝试访问配置文件: ${configFile.path}');

      if (!await configFile.exists()) {
        throw Exception('在选择的文件夹中未找到 config.json 文件\n请确保选择了正确的备份文件夹\n路径: ${configFile.path}');
      }

      // 直接读取配置文件
      String configContent;
      try {
        configContent = await configFile.readAsString();
        if (configContent.isEmpty) {
          throw Exception('配置文件为空');
        }
        print('配置文件大小: ${configContent.length} 字符');
      } catch (e) {
        print('读取配置文件失败: $e');
        if (e.toString().contains('Permission denied')) {
          throw Exception('权限被拒绝，无法读取配置文件\n\n请按以下步骤操作：\n1. 在设置中找到"权限"或"应用权限"\n2. 找到"文件和媒体"或"存储"\n3. 选择"管理所有文件"并开启\n\n错误详情: $e');
        } else {
          throw Exception('读取配置文件失败\n错误详情: $e');
        }
      }

      // 处理配置文件
      final backupDir = Directory(selectedDirectory);
      await _processConfigFile(configContent, backupDir);

      if (mounted && context.mounted && Navigator.of(context).mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('配置导入成功！'),
                Text('配置文件: ${configFile.path}', style: const TextStyle(fontSize: 12)),
                const Text('已加载，可能需重启', style: TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            dismissDirection: DismissDirection.horizontal,
          ),
        );
      }
    } catch (e) {
      print('手动导入配置时发生错误: $e');
      if (mounted && context.mounted && Navigator.of(context).mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('导入失败'),
                Text(e.toString(), style: const TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            dismissDirection: DismissDirection.horizontal,
          ),
        );
      }
    }
  }

  // 处理配置文件
  Future<void> _processConfigFile(String configContent, Directory backupDir) async {
    // 解析JSON
    Map<String, dynamic> configData;
    try {
      configData = jsonDecode(configContent) as Map<String, dynamic>;
      print('JSON解析成功，包含 ${configData.length} 个顶级字段');
    } catch (e) {
      if (e.toString().contains('Unexpected character')) {
        throw Exception('配置文件格式错误：包含无效字符\n请确保文件未被损坏');
      } else if (e.toString().contains('Unexpected end of input')) {
        throw Exception('配置文件不完整：文件可能被截断\n请重新导出配置');
      } else {
        throw Exception('配置文件格式错误: $e');
      }
    }

    // 验证版本
    final version = configData['version'] as String?;
    if (version == null) {
      throw Exception('配置文件缺少版本信息');
    }

    // 恢复用户信息
    final userInfo = configData['userInfo'] as Map<String, dynamic>?;
    if (userInfo != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', userInfo['userName'] ?? '开发者');

      // 恢复头像 - 支持多种格式
      final avatarFormats = ['avatar.png', 'avatar.jpg', 'avatar.jpeg', 'avatar.webp', 'avatar.gif'];
      String? avatarDestPath;
      
      for (final format in avatarFormats) {
        final avatarSourcePath = '${backupDir.path}/$format';
        final avatarSourceFile = File(avatarSourcePath);
        if (await avatarSourceFile.exists()) {
          try {
            // 创建应用内部存储的头像目录
            final appDir = await getApplicationDocumentsDirectory();
            final extension = format.split('.').last;
            avatarDestPath = '${appDir.path}/avatar.$extension';
            
            // 复制头像文件
            await avatarSourceFile.copy(avatarDestPath!);
            await prefs.setString('user_avatar_path', avatarDestPath);
            print('头像恢复成功: $avatarDestPath (原格式: $format)');
            break; // 找到第一个存在的文件就停止
          } catch (e) {
            print('恢复头像失败 ($format): $e');
          }
        }
      }
      
      if (avatarDestPath == null) {
        print('未找到任何格式的头像文件');
      }

      // 恢复背景图片 - 支持多种格式
      final bgFormats = ['drawer_bg.jpg', 'drawer_bg.jpeg', 'drawer_bg.png', 'drawer_bg.webp'];
      String? bgDestPath;
      
      for (final format in bgFormats) {
        final bgSourcePath = '${backupDir.path}/$format';
        final bgSourceFile = File(bgSourcePath);
        if (await bgSourceFile.exists()) {
          try {
            // 创建应用内部存储的背景图片目录
            final appDir = await getApplicationDocumentsDirectory();
            final extension = format.split('.').last;
            bgDestPath = '${appDir.path}/drawer_bg.$extension';
            
            // 复制背景图片文件
            await bgSourceFile.copy(bgDestPath!);
            await prefs.setString('drawer_bg_path', bgDestPath);
            print('背景图片恢复成功: $bgDestPath (原格式: $format)');
            break; // 找到第一个存在的文件就停止
          } catch (e) {
            print('恢复背景图片失败 ($format): $e');
          }
        }
      }
      
      if (bgDestPath == null) {
        print('未找到任何格式的背景图片文件');
      }
    }

    // 恢复技能数据
    final skillsData = configData['skills'] as Map<String, dynamic>?;
    if (skillsData != null) {
      final prefs = await SharedPreferences.getInstance();
      final List<Skill> allSkills = [];

      // 恢复主页面技能
      final mainSkills = skillsData['mainSkills'] as List<dynamic>?;
      if (mainSkills != null) {
        for (final skillData in mainSkills) {
          try {
            final skill = Skill.fromMap(Map<String, dynamic>.from(skillData));
            allSkills.add(skill);
          } catch (e) {
            print('解析主页面技能失败: $e');
          }
        }
      }

      // 恢复荣耀殿堂技能
      final hallOfGlorySkills = skillsData['hallOfGlorySkills'] as List<dynamic>?;
      if (hallOfGlorySkills != null) {
        for (final skillData in hallOfGlorySkills) {
          try {
            final skill = Skill.fromMap(Map<String, dynamic>.from(skillData));
            // skill.inHallOfGlory = true; // 这个属性可能不存在，暂时注释掉
            allSkills.add(skill);
          } catch (e) {
            print('解析荣耀殿堂技能失败: $e');
          }
        }
      }

      // 保存技能数据
      if (allSkills.isNotEmpty) {
        final skillsAsString = allSkills.map((skill) => jsonEncode(skill.toMap())).toList();
        await prefs.setStringList('skills_list_key', skillsAsString);
        print('成功恢复 ${allSkills.length} 个技能');
      }

      // 恢复技能日记
      final diaries = configData['diaries'] as Map<String, dynamic>?;
      if (diaries != null) {
        for (final entry in diaries.entries) {
          final skillName = entry.key;
          final diaryList = entry.value as List<dynamic>;
          try {
            await prefs.setStringList('skill_diary_$skillName', diaryList.cast<String>());
            print('恢复技能日记: $skillName (${diaryList.length} 条)');
          } catch (e) {
            print('恢复技能日记失败: ${entry.key} - $e');
          }
        }
      }
    }

    // 恢复祝贺记录
    final congratulatedSkills = configData['congratulatedSkills'] as List<dynamic>?;
    if (congratulatedSkills != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('congratulated_skill_ids', congratulatedSkills.cast<String>());
        print('恢复祝贺记录: ${congratulatedSkills.length} 个技能');
      } catch (e) {
        print('恢复祝贺记录失败: $e');
      }
    }

    // 恢复技能分组
    final groups = configData['groups'] as List<dynamic>?;
    if (groups != null) {
      try {
        final skillGroups = groups.map((g) => SkillGroup.fromMap(Map<String, dynamic>.from(g))).toList();
        await GroupStorage.saveGroups(skillGroups);
        print('恢复技能分组: ${groups.length} 个分组');
      } catch (e) {
        print('恢复技能分组失败: $e');
      }
    }

    // 更新UI状态
    setState(() {
      _loadImagePaths();
      _loadUserName();
    });

    // 通知整个应用刷新
    print('SettingsScreen: 准备发送配置导入通知');
    AppStateNotifier().notifyConfigImported();
    print('SettingsScreen: 配置导入通知已发送');
  }

  // 保存用户名
  Future<void> _saveUserName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? kCardDark : kCardLight,
        foregroundColor: Theme.of(context).brightness == Brightness.dark ? kTextMainDark : kTextMain,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 用户信息分组 - 压缩版
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: const Text('用户信息'),
              subtitle: Text('用户名：$_userName'),
              leading: const Icon(Icons.person),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showUserNameDialog(),
              ),
            ),
          ),

          // 个性化设置分组 - 压缩版
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                ListTile(
                  title: const Text('头像'),
                  subtitle: const Text('选择头像图片'),
                  leading: const Icon(Icons.account_circle),
                  onTap: () => _pickAndSaveImage(isAvatar: true),
                  dense: true,
                ),
                ListTile(
                  title: const Text('背景'),
                  subtitle: const Text('选择侧边栏背景'),
                  leading: const Icon(Icons.photo),
                  onTap: () => _pickAndSaveImage(isAvatar: false),
                  dense: true,
                ),
              ],
            ),
          ),

          // 权限管理分组 - 压缩版
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: const Text('存储权限'),
              subtitle: Text(_hasStoragePermission ? '已授予' : '未授予'),
              leading: Icon(
                _hasStoragePermission ? Icons.check_circle : Icons.error,
                color: _hasStoragePermission ? Colors.green : Colors.red,
              ),
              trailing: !_hasStoragePermission ? TextButton(
                onPressed: () async {
                  await _checkStoragePermission();
                  _requestStoragePermission();
                },
                child: const Text('申请'),
              ) : null,
            ),
          ),

          // 数据管理分组 - 压缩版
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                ListTile(
                  title: const Text('导出配置'),
                  subtitle: const Text('单击导出，长按选择备份地址\n长按备份地址建议：Download/自定义文件夹'),
                  leading: const Icon(Icons.upload),
                  onTap: _autoExportConfig,
                  onLongPress: _manualExportConfig,
                  dense: true,
                ),
                ListTile(
                  title: const Text('导入配置'),
                  subtitle: const Text('单击尝试自动导入，或长按选择文件夹'),
                  leading: const Icon(Icons.download),
                  onTap: _importConfig,
                  onLongPress: _manualImportConfig,
                  dense: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 显示用户名修改对话框
  void _showUserNameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('修改用户名'),
          content: TextField(
            controller: _userNameController,
            decoration: const InputDecoration(
              labelText: '用户名',
              hintText: '请输入用户名',
            ),
            onChanged: (value) => _userName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveUserName();
                Navigator.of(context).pop();
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }
}
