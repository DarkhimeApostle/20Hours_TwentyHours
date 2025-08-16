import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../models/skill_model.dart';
import '../models/skill_group.dart';
import '../utils/group_storage.dart';
import 'package:permission_handler/permission_handler.dart';

// 设置页面，支持自定义头像和侧边栏背景
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _avatarPath;
  String? _drawerBgPath;
  String _userName = '';
  final TextEditingController _userNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadImagePaths();
    _loadUserName();
    _checkStoragePermission();

    // 延迟检查权限，确保UI已完全加载
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _checkStoragePermission();
      }
    });
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // 加载本地保存的图片路径
  Future<void> _loadImagePaths() async {
    final prefs = await SharedPreferences.getInstance();
    final avatarPath = prefs.getString('user_avatar_path');
    final drawerBgPath = prefs.getString('drawer_bg_path');

    print('加载图片路径:');
    print('  头像路径: $avatarPath');
    print('  背景路径: $drawerBgPath');

    setState(() {
      _avatarPath = avatarPath;
      _drawerBgPath = drawerBgPath;
    });
  }

  bool _hasStoragePermission = false;

  // 检查存储权限
  Future<void> _checkStoragePermission() async {
    try {
      print('正在检查存储权限...');

      // 检查多种权限状态
      final storageStatus = await Permission.storage.status;
      final manageExternalStorageStatus =
          await Permission.manageExternalStorage.status;
      final photosStatus = await Permission.photos.status;

      // 对于Android 11+，需要检查管理外部存储权限或照片权限
      final hasPermission =
          storageStatus.isGranted ||
          manageExternalStorageStatus.isGranted ||
          photosStatus.isGranted;

      setState(() {
        _hasStoragePermission = hasPermission;
      });

      print(
        '存储权限状态: ${storageStatus.isGranted ? "已授予" : "未授予"} (${storageStatus.name})',
      );
      print(
        '管理外部存储权限: ${manageExternalStorageStatus.isGranted ? "已授予" : "未授予"} (${manageExternalStorageStatus.name})',
      );
      print(
        '照片权限状态: ${photosStatus.isGranted ? "已授予" : "未授予"} (${photosStatus.name})',
      );
      print('综合权限状态: ${hasPermission ? "已授予" : "未授予"}');

      // 如果权限被拒绝，记录详细信息
      if (storageStatus.isDenied) {
        print('存储权限被拒绝，用户需要手动授予');
      } else if (storageStatus.isPermanentlyDenied) {
        print('存储权限被永久拒绝，需要用户在设置中手动开启');
      } else if (storageStatus.isRestricted) {
        print('存储权限受限，可能是系统限制');
      }

      if (manageExternalStorageStatus.isDenied) {
        print('管理外部存储权限被拒绝');
      } else if (manageExternalStorageStatus.isPermanentlyDenied) {
        print('管理外部存储权限被永久拒绝');
      }

      if (photosStatus.isDenied) {
        print('照片权限被拒绝');
      } else if (photosStatus.isPermanentlyDenied) {
        print('照片权限被永久拒绝');
      }
    } catch (e) {
      print('检查存储权限时发生错误: $e');
      // 如果权限检查失败，假设没有权限
      setState(() {
        _hasStoragePermission = false;
      });
    }
  }

  // 请求存储权限
  Future<void> _requestStoragePermission() async {
    try {
      print('正在请求存储权限...');

      // 先尝试请求存储权限
      final storageStatus = await Permission.storage.request();
      print('存储权限请求结果: ${storageStatus.isGranted ? "已授予" : "被拒绝"}');

      // 如果存储权限被拒绝，尝试请求管理外部存储权限（Android 11+）
      PermissionStatus manageStatus = PermissionStatus.denied;
      if (!storageStatus.isGranted) {
        try {
          manageStatus = await Permission.manageExternalStorage.request();
          print('管理外部存储权限请求结果: ${manageStatus.isGranted ? "已授予" : "被拒绝"}');
        } catch (e) {
          print('请求管理外部存储权限失败: $e');
        }
      }

      // 如果还是被拒绝，尝试请求照片权限（Android 13+）
      PermissionStatus photosStatus = PermissionStatus.denied;
      if (!storageStatus.isGranted && !manageStatus.isGranted) {
        try {
          photosStatus = await Permission.photos.request();
          print('照片权限请求结果: ${photosStatus.isGranted ? "已授予" : "被拒绝"}');
        } catch (e) {
          print('请求照片权限失败: $e');
        }
      }

      final hasPermission =
          storageStatus.isGranted ||
          manageStatus.isGranted ||
          photosStatus.isGranted;
      setState(() {
        _hasStoragePermission = hasPermission;
      });

      print('综合权限结果: ${hasPermission ? "已授予" : "被拒绝"}');

      if (hasPermission) {
        if (mounted && context.mounted && Navigator.of(context).mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('存储权限已授予'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted && context.mounted && Navigator.of(context).mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('需要存储权限'),
                  const Text('请在系统设置中手动授予存储权限', style: TextStyle(fontSize: 12)),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              dismissDirection: DismissDirection.horizontal,
            ),
          );
        }
      }
    } catch (e) {
      print('请求存储权限时发生错误: $e');
      if (mounted && context.mounted && Navigator.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('权限请求失败'),
                Text(e.toString(), style: const TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            dismissDirection: DismissDirection.horizontal,
          ),
        );
      }
    }
  }

  // 加载用户名
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name') ?? '开狼';
    setState(() {
      _userName = userName;
      _userNameController.text = userName;
    });
  }

  // 保存用户名
  Future<void> _saveUserName() async {
    if (_userName.trim().isEmpty) {
      if (mounted && context.mounted && Navigator.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('用户名不能为空'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName.trim());

    if (mounted && context.mounted && Navigator.of(context).mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('保存用户名成功'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // 选择图片并保存到本地
  Future<void> _pickAndSaveImage({required bool isAvatar}) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final fileName = isAvatar
          ? 'user_avatar_${DateTime.now().millisecondsSinceEpoch}.png'
          : 'drawer_bg_${DateTime.now().millisecondsSinceEpoch}.png';
      final savePath = '${dir.path}/$fileName';

      // 复制文件
      final file = await File(picked.path).copy(savePath);

      // 验证文件是否成功创建
      if (!await file.exists()) {
        throw Exception('文件保存失败');
      }

      final prefs = await SharedPreferences.getInstance();
      if (isAvatar) {
        await prefs.setString('user_avatar_path', file.path);
        setState(() => _avatarPath = file.path);
        if (mounted && context.mounted && Navigator.of(context).mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('保存头像成功'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        await prefs.setString('drawer_bg_path', file.path);
        setState(() => _drawerBgPath = file.path);
        if (mounted && context.mounted && Navigator.of(context).mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('保存侧边栏背景成功'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('保存图片时发生错误: $e');
      if (mounted && context.mounted && Navigator.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // 导出配置
  Future<void> _exportConfig() async {
    try {
      // 使用应用内部存储目录，无需任何权限
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

      print('备份目录: ${backupDir.path}');

      final prefs = await SharedPreferences.getInstance();

      // 收集所有数据
      final Map<String, dynamic> configData = {
        'version': '1.0',
        'exportTime': DateTime.now().toIso8601String(),
        'userInfo': {
          'userName': prefs.getString('user_name') ?? '开狼',
          'avatarPath': prefs.getString('user_avatar_path'),
          'drawerBgPath': prefs.getString('drawer_bg_path'),
        },
        'skills': {'mainSkills': [], 'hallOfGlorySkills': []},
        'diaries': {},
        'congratulatedSkills':
            prefs.getStringList('congratulated_skill_ids') ?? [],
        'groups': [],
      };

      // 获取所有技能数据
      final List<String>? skillsAsString = prefs.getStringList(
        'skills_list_key',
      );
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

      // 复制头像
      if (_avatarPath != null && _avatarPath!.isNotEmpty) {
        try {
          final avatarFile = File(_avatarPath!);
          if (await avatarFile.exists()) {
            final backupAvatarPath = '${backupDir.path}/avatar.png';
            await avatarFile.copy(backupAvatarPath);
            configData['userInfo']['avatarPath'] = 'avatar.png';
            print('头像已复制: $backupAvatarPath');
          } else {
            print('头像文件不存在: $_avatarPath');
            configData['userInfo']['avatarPath'] = null;
          }
        } catch (e) {
          print('复制头像失败: $e');
          configData['userInfo']['avatarPath'] = null;
        }
      } else {
        print('没有头像路径');
        configData['userInfo']['avatarPath'] = null;
      }

      // 复制侧边栏背景
      if (_drawerBgPath != null && _drawerBgPath!.isNotEmpty) {
        try {
          final bgFile = File(_drawerBgPath!);
          if (await bgFile.exists()) {
            final backupBgPath = '${backupDir.path}/drawer_bg.png';
            await bgFile.copy(backupBgPath);
            configData['userInfo']['drawerBgPath'] = 'drawer_bg.png';
            print('背景图片已复制: $backupBgPath');
          } else {
            print('背景图片文件不存在: $_drawerBgPath');
            configData['userInfo']['drawerBgPath'] = null;
          }
        } catch (e) {
          print('复制背景图片失败: $e');
          configData['userInfo']['drawerBgPath'] = null;
        }
      } else {
        print('没有背景图片路径');
        configData['userInfo']['drawerBgPath'] = null;
      }

      // 保存配置文件
      try {
        final configFile = File('${backupDir.path}/config.json');
        final configJson = jsonEncode(configData);
        await configFile.writeAsString(configJson);

        print('配置文件内容长度: ${configJson.length} 字符');
        print('配置文件已保存: ${configFile.path}');

        // 验证文件是否成功创建
        if (!await configFile.exists()) {
          throw Exception('配置文件创建失败');
        }

        // 验证文件内容
        final savedContent = await configFile.readAsString();
        print('保存的配置文件内容长度: ${savedContent.length} 字符');

        print('备份目录内容:');
        final files = await backupDir.list().toList();
        for (final file in files) {
          print('  - ${file.path.split('/').last}');
        }
      } catch (e) {
        print('保存配置文件时发生错误: $e');
        throw Exception('保存配置文件失败: $e');
      }

      if (mounted && context.mounted) {
        // 先清除所有现有的SnackBar
        ScaffoldMessenger.of(context).clearSnackBars();

        // 延迟一下再显示新的SnackBar，确保清除完成
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && context.mounted && Navigator.of(context).mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('配置已成功导出'),
                    const Text('导入时将自动查找备份文件', style: TextStyle(fontSize: 12)),
                    const Text('无需手动选择文件夹', style: TextStyle(fontSize: 12)),
                  ],
                ),
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                dismissDirection: DismissDirection.horizontal,
              ),
            );
          }
        });
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

  // 测试文件访问权限
  Future<bool> _testFileAccess(String directoryPath) async {
    try {
      final testDir = Directory(directoryPath);
      if (!await testDir.exists()) {
        print('测试目录不存在: $directoryPath');
        return false;
      }

      // 尝试列出目录内容
      await testDir.list().toList();
      print('目录访问测试成功: $directoryPath');
      return true;
    } catch (e) {
      print('目录访问测试失败: $directoryPath - $e');
      return false;
    }
  }

  // 导入配置
  Future<void> _importConfig() async {
    try {
      // 自动查找备份文件夹
      String? backupPath;

      // 首先尝试在应用内部存储中查找
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final internalBackupPath = '${appDir.path}/20timer_backup';
        final internalBackupDir = Directory(internalBackupPath);

        if (await internalBackupDir.exists()) {
          // 检查是否包含配置文件
          final configFile = File('$internalBackupPath/config.json');
          if (await configFile.exists()) {
            backupPath = internalBackupPath;
            print('找到内部备份: $backupPath');
          }
        }
      } catch (e) {
        print('检查内部备份失败: $e');
      }

      // 如果内部没有找到，尝试外部存储
      if (backupPath == null) {
        try {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            final externalBackupPath = '${externalDir.path}/20timer_backup';
            final externalBackupDir = Directory(externalBackupPath);

            if (await externalBackupDir.exists()) {
              final configFile = File('$externalBackupPath/config.json');
              if (await configFile.exists()) {
                backupPath = externalBackupPath;
                print('找到外部备份: $backupPath');
              }
            }
          }
        } catch (e) {
          print('检查外部备份失败: $e');
        }
      }

      // 如果自动查找失败，让用户手动选择
      if (backupPath == null) {
        print('未找到自动备份，请求用户手动选择');

        // 显示对话框询问用户
        final shouldManualSelect = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('未找到备份文件'),
            content: const Text('系统未找到自动备份文件，是否手动选择备份文件夹？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('手动选择'),
              ),
            ],
          ),
        );

        if (shouldManualSelect != true) {
          return; // 用户取消
        }

        // 用户选择手动选择
        final appDir = await getApplicationDocumentsDirectory();
        final selectedDirectory = await FilePicker.platform.getDirectoryPath(
          dialogTitle: '选择备份文件夹',
          initialDirectory: appDir.path,
        );

        if (selectedDirectory == null || selectedDirectory.isEmpty) {
          throw Exception('未选择有效的备份文件夹');
        }

        backupPath = selectedDirectory;
        print('用户手动选择的目录: $backupPath');
      }

      if (backupPath == null || backupPath.isEmpty) {
        throw Exception('未找到有效的备份文件夹');
      }

      final backupDir = Directory(backupPath);
      print('选择的备份目录: ${backupDir.path}');

      // 测试目录访问权限
      final canAccess = await _testFileAccess(backupPath);
      if (!canAccess) {
        throw Exception('无法访问选择的文件夹，可能是权限问题\n路径: $backupPath');
      }

      if (!await backupDir.exists()) {
        throw Exception('选择的文件夹不存在: $backupPath');
      }

      // 查找配置文件
      final configFile = File('${backupDir.path}/config.json');
      print('尝试访问配置文件: ${configFile.path}');

      // 检查目录内容
      try {
        final files = await backupDir.list().toList();
        print('目录内容:');
        for (final file in files) {
          print('  - ${file.path.split('/').last}');
        }
      } catch (e) {
        print('无法列出目录内容: $e');
      }

      if (!await configFile.exists()) {
        throw Exception('在选择的文件夹中未找到 config.json 文件\n路径: ${configFile.path}');
      }

      // 读取配置文件
      String configContent;
      try {
        print('开始读取配置文件...');
        configContent = await configFile.readAsString();
        if (configContent.isEmpty) {
          throw Exception('配置文件为空');
        }
        print('配置文件大小: ${configContent.length} 字符');
        print(
          '配置文件前100个字符: ${configContent.substring(0, configContent.length > 100 ? 100 : configContent.length)}',
        );
      } catch (e) {
        print('读取配置文件时发生错误: $e');
        print('错误类型: ${e.runtimeType}');
        print('错误详情: ${e.toString()}');

        if (e.toString().contains('Permission denied')) {
          throw Exception('权限被拒绝，无法读取配置文件\n请检查文件权限或重新选择文件夹\n错误详情: $e');
        } else if (e.toString().contains('No such file')) {
          throw Exception('配置文件不存在\n请确保选择了正确的备份文件夹\n错误详情: $e');
        } else if (e.toString().contains('Access denied')) {
          throw Exception('访问被拒绝，可能是权限问题\n请尝试重新选择文件夹或检查权限设置\n错误详情: $e');
        } else {
          throw Exception('读取配置文件失败\n错误详情: $e');
        }
      }

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
      if (version == null || !version.startsWith('1.')) {
        throw Exception('不支持的配置文件版本: $version');
      }

      final prefs = await SharedPreferences.getInstance();

      // 恢复用户信息
      final userInfo = configData['userInfo'] as Map<String, dynamic>?;
      if (userInfo != null) {
        await prefs.setString('user_name', userInfo['userName'] ?? '开狼');
      }

      // 恢复图片文件
      final appDir = await getApplicationDocumentsDirectory();

      // 恢复头像
      if (userInfo?['avatarPath'] != null) {
        try {
          final avatarSourcePath =
              '${backupDir.path}/${userInfo!['avatarPath']}';
          final avatarFile = File(avatarSourcePath);
          if (await avatarFile.exists()) {
            final avatarDestPath =
                '${appDir.path}/user_avatar_${DateTime.now().millisecondsSinceEpoch}.png';
            await avatarFile.copy(avatarDestPath);
            await prefs.setString('user_avatar_path', avatarDestPath);
            setState(() => _avatarPath = avatarDestPath);
            print('头像恢复成功: $avatarDestPath');
          } else {
            print('头像文件不存在: $avatarSourcePath');
          }
        } catch (e) {
          print('恢复头像失败: $e');
        }
      }

      // 恢复侧边栏背景
      if (userInfo?['drawerBgPath'] != null) {
        try {
          final bgSourcePath = '${backupDir.path}/${userInfo!['drawerBgPath']}';
          final bgFile = File(bgSourcePath);
          if (await bgFile.exists()) {
            final bgDestPath =
                '${appDir.path}/drawer_bg_${DateTime.now().millisecondsSinceEpoch}.png';
            await bgFile.copy(bgDestPath);
            await prefs.setString('drawer_bg_path', bgDestPath);
            setState(() => _drawerBgPath = bgDestPath);
            print('背景图片恢复成功: $bgDestPath');
          } else {
            print('背景图片文件不存在: $bgSourcePath');
          }
        } catch (e) {
          print('恢复背景图片失败: $e');
        }
      }

      // 恢复技能数据
      final skillsData = configData['skills'] as Map<String, dynamic>?;
      if (skillsData != null) {
        final List<Skill> allSkills = [];

        // 恢复主页面技能
        final mainSkills = skillsData['mainSkills'] as List<dynamic>? ?? [];
        for (final skillData in mainSkills) {
          try {
            final skill = Skill.fromMap(Map<String, dynamic>.from(skillData));
            allSkills.add(skill);
          } catch (e) {
            print('解析主页面技能失败: $e');
          }
        }

        // 恢复荣耀殿堂技能
        final hallSkills =
            skillsData['hallOfGlorySkills'] as List<dynamic>? ?? [];
        for (final skillData in hallSkills) {
          try {
            final skill = Skill.fromMap(Map<String, dynamic>.from(skillData));
            allSkills.add(skill);
          } catch (e) {
            print('解析荣耀殿堂技能失败: $e');
          }
        }

        // 保存技能数据
        if (allSkills.isNotEmpty) {
          final skillsAsString = allSkills
              .map((s) => jsonEncode(s.toMap()))
              .toList();
          await prefs.setStringList('skills_list_key', skillsAsString);
          await prefs.setInt(
            'skills_list_key_timestamp',
            DateTime.now().millisecondsSinceEpoch,
          );
          print('成功恢复 ${allSkills.length} 个技能');
        }
      }

      // 恢复技能日记
      final diaries = configData['diaries'] as Map<String, dynamic>?;
      if (diaries != null) {
        for (final entry in diaries.entries) {
          try {
            final skillName = entry.key;
            final diaryList = entry.value as List<dynamic>? ?? [];
            final diaryKey = 'skill_diary_$skillName';
            await prefs.setStringList(diaryKey, diaryList.cast<String>());
            print('恢复技能日记: $skillName (${diaryList.length} 条)');
          } catch (e) {
            print('恢复技能日记失败: ${entry.key} - $e');
          }
        }
      }

      // 恢复祝贺记录
      final congratulatedSkills =
          configData['congratulatedSkills'] as List<dynamic>?;
      if (congratulatedSkills != null && congratulatedSkills.isNotEmpty) {
        try {
          await prefs.setStringList(
            'congratulated_skill_ids',
            congratulatedSkills.cast<String>(),
          );
          print('恢复祝贺记录: ${congratulatedSkills.length} 个技能');
        } catch (e) {
          print('恢复祝贺记录失败: $e');
        }
      }

      // 恢复技能分组数据
      final groupsData = configData['groups'] as List<dynamic>?;
      if (groupsData != null && groupsData.isNotEmpty) {
        try {
          final groups = groupsData
              .map((g) => SkillGroup.fromMap(Map<String, dynamic>.from(g)))
              .toList();
          await GroupStorage.saveGroups(groups);
          print('恢复技能分组: ${groups.length} 个分组');
        } catch (e) {
          print('恢复技能分组失败: $e');
        }
      }

      // 更新用户名显示
      await _loadUserName();

      if (mounted && context.mounted && Navigator.of(context).mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('配置导入成功！'),
                const Text('请重启应用以应用所有更改', style: TextStyle(fontSize: 12)),
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
      print('导入配置时发生错误: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 离开设置界面时清除所有SnackBar
            try {
              ScaffoldMessenger.of(context).clearSnackBars();
            } catch (e) {
              // 忽略错误
            }
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            const Icon(Icons.settings, size: 24),
            const SizedBox(width: 8),
            const Text('设置'),
          ],
        ),
      ),
      body: ListView(
        children: [
          // 设置选项列表
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // 编辑用户名
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.grey),
                title: const Text('编辑用户名'),
                subtitle: Text('当前用户名：$_userName'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: _showEditProfileDialog,
              ),
              const Divider(height: 1),
              // 更换头像
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.grey),
                title: const Text('更换头像'),
                subtitle: const Text('自定义您的个人头像'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () => _pickAndSaveImage(isAvatar: true),
              ),
              const Divider(height: 1),
              // 更换背景
              ListTile(
                leading: const Icon(
                  Icons.wallpaper_outlined,
                  color: Colors.grey,
                ),
                title: const Text('更换背景'),
                subtitle: const Text('自定义侧边栏背景图片'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () => _pickAndSaveImage(isAvatar: false),
              ),
              const Divider(height: 1),
              // 数据管理分组 - 存储权限
              _buildConnectedListTile(
                icon: Icon(Icons.check_circle, color: Colors.green),
                title: const Text('存储权限'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '已授予 - 使用应用内部存储',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                    Text(
                      '无需任何权限即可导出配置',
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                  ],
                ),
                isFirst: true,
                isLast: false,
                onTap: () async {
                  await _checkStoragePermission();
                  _requestStoragePermission();
                },
              ),
              const Divider(height: 1),
              // 数据管理分组 - 导出配置
              _buildConnectedListTile(
                icon: const Icon(Icons.file_download, color: Colors.green),
                title: const Text('导出配置'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '备份所有数据到应用内部存储',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '位置：应用内部/20timer_backup',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
                isFirst: false,
                isLast: false,
                onTap: _exportConfig,
              ),
              const Divider(height: 1),
              // 数据管理分组 - 导入配置
              _buildConnectedListTile(
                icon: const Icon(Icons.file_upload, color: Colors.blue),
                title: const Text('导入配置'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '自动查找并恢复备份数据',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '无需手动选择文件夹',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
                isFirst: false,
                isLast: true, // 改为最后一个
                onTap: _importConfig,
              ),
              const Divider(height: 1),
              // 意见反馈邮箱
              ListTile(
                leading: const Icon(Icons.email_outlined, color: Colors.blue),
                title: const Text('反馈邮箱'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '1139748471@qq.com',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.copy, size: 16, color: Colors.grey),
                  ],
                ),
                onTap: () {
                  // 复制邮箱到剪贴板
                  Clipboard.setData(
                    const ClipboardData(text: '1139748471@qq.com'),
                  );
                  if (mounted &&
                      context.mounted &&
                      Navigator.of(context).mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('邮箱已复制到剪贴板'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 显示编辑用户信息对话框
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑用户信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _userNameController,
              onChanged: (value) => _userName = value,
              decoration: const InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
      ),
    );
  }

  // 构建带连接线的ListTile
  Widget _buildConnectedListTile({
    required Widget icon,
    required Widget title,
    required Widget subtitle,
    required bool isFirst,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    const connectionColor = Colors.orange;
    const connectionWidth = 8.0;
    const leftPadding = 8.0; // 减少左移动距离

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: connectionColor, width: connectionWidth),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(
          left: leftPadding + 2, // 只移动一点点
          right: 16,
        ),
        leading: icon,
        title: title,
        subtitle: subtitle,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
