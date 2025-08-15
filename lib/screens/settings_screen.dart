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
      final status = await Permission.storage.status;
      setState(() {
        _hasStoragePermission = status.isGranted;
      });
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
      final status = await Permission.storage.request();
      setState(() {
        _hasStoragePermission = status.isGranted;
      });

      if (status.isGranted) {
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
            const SnackBar(
              content: Text('需要存储权限才能导出配置到外部存储'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('请求存储权限时发生错误: $e');
      if (mounted && context.mounted && Navigator.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('权限请求失败: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
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
      // 尝试使用公共下载目录
      String backupPath;
      try {
        // 尝试访问公共下载目录
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          backupPath = '${downloadDir.path}/20timer_backup';
          print('使用公共下载目录: $backupPath');
        } else {
          throw Exception('下载目录不存在');
        }
      } catch (e) {
        print('无法访问公共目录，使用应用目录: $e');
        // 如果无法访问公共目录，回退到应用目录
        final externalDir = await getExternalStorageDirectory();
        if (externalDir == null) {
          throw Exception('无法获取外部存储目录');
        }
        backupPath = '${externalDir.path}/20timer_backup';
      }

      // 创建或清空备份目录
      final backupDir = Directory(backupPath);
      if (await backupDir.exists()) {
        // 如果目录存在，删除所有内容
        await backupDir.delete(recursive: true);
      }
      await backupDir.create(recursive: true);

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
                    const Text('配置已成功导出到下载文件夹'),
                    Text(backupDir.path, style: const TextStyle(fontSize: 12)),
                    const Text('导入时请选择此文件夹', style: TextStyle(fontSize: 12)),
                  ],
                ),
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                dismissDirection: DismissDirection.horizontal,
                action: SnackBarAction(
                  label: '复制路径',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: backupDir.path));
                    // 显示简短的复制成功提示
                    if (mounted &&
                        context.mounted &&
                        Navigator.of(context).mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('路径已复制到剪贴板'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.blue,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
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

  // 导入配置
  Future<void> _importConfig() async {
    try {
      // 选择备份文件夹
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择备份文件夹',
        initialDirectory: '/storage/emulated/0/',
      );

      if (selectedDirectory == null) return;

      final backupDir = Directory(selectedDirectory);
      if (!await backupDir.exists()) {
        throw Exception('选择的文件夹不存在');
      }

      // 查找配置文件
      final configFile = File('${backupDir.path}/config.json');
      if (!await configFile.exists()) {
        throw Exception('在选择的文件夹中未找到 config.json 文件');
      }

      // 读取配置文件
      final configContent = await configFile.readAsString();
      final configData = jsonDecode(configContent) as Map<String, dynamic>;

      // 验证版本
      final version = configData['version'] as String?;
      if (version == null || !version.startsWith('1.')) {
        throw Exception('不支持的配置文件版本');
      }

      final prefs = await SharedPreferences.getInstance();

      // 恢复用户信息
      final userInfo = configData['userInfo'] as Map<String, dynamic>;
      await prefs.setString('user_name', userInfo['userName'] ?? '开狼');

      // 恢复图片文件
      final appDir = await getApplicationDocumentsDirectory();

      // 恢复头像
      if (userInfo['avatarPath'] != null) {
        final avatarSourcePath = '${backupDir.path}/${userInfo['avatarPath']}';
        if (await File(avatarSourcePath).exists()) {
          final avatarDestPath =
              '${appDir.path}/user_avatar_${DateTime.now().millisecondsSinceEpoch}.png';
          await File(avatarSourcePath).copy(avatarDestPath);
          await prefs.setString('user_avatar_path', avatarDestPath);
          setState(() => _avatarPath = avatarDestPath);
        }
      }

      // 恢复侧边栏背景
      if (userInfo['drawerBgPath'] != null) {
        final bgSourcePath = '${backupDir.path}/${userInfo['drawerBgPath']}';
        if (await File(bgSourcePath).exists()) {
          final bgDestPath =
              '${appDir.path}/drawer_bg_${DateTime.now().millisecondsSinceEpoch}.png';
          await File(bgSourcePath).copy(bgDestPath);
          await prefs.setString('drawer_bg_path', bgDestPath);
          setState(() => _drawerBgPath = bgDestPath);
        }
      }

      // 恢复技能数据
      final skillsData = configData['skills'] as Map<String, dynamic>;
      final List<Skill> allSkills = [];

      // 恢复主页面技能
      final mainSkills = skillsData['mainSkills'] as List<dynamic>;
      for (final skillData in mainSkills) {
        final skill = Skill.fromMap(Map<String, dynamic>.from(skillData));
        allSkills.add(skill);
      }

      // 恢复荣耀殿堂技能
      final hallSkills = skillsData['hallOfGlorySkills'] as List<dynamic>;
      for (final skillData in hallSkills) {
        final skill = Skill.fromMap(Map<String, dynamic>.from(skillData));
        allSkills.add(skill);
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
      }

      // 恢复技能日记
      final diaries = configData['diaries'] as Map<String, dynamic>;
      for (final entry in diaries.entries) {
        final skillName = entry.key;
        final diaryList = entry.value as List<dynamic>;
        final diaryKey = 'skill_diary_$skillName';
        await prefs.setStringList(diaryKey, diaryList.cast<String>());
      }

      // 恢复祝贺记录
      final congratulatedSkills =
          configData['congratulatedSkills'] as List<dynamic>;
      if (congratulatedSkills.isNotEmpty) {
        await prefs.setStringList(
          'congratulated_skill_ids',
          congratulatedSkills.cast<String>(),
        );
      }

      // 恢复技能分组数据
      final groupsData = configData['groups'] as List<dynamic>;
      if (groupsData.isNotEmpty) {
        final groups = groupsData
            .map((g) => SkillGroup.fromMap(Map<String, dynamic>.from(g)))
            .toList();
        await GroupStorage.saveGroups(groups);
      }

      // 更新用户名显示
      await _loadUserName();

      if (mounted && context.mounted && Navigator.of(context).mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('配置导入成功，请重启应用以应用更改'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('导入配置时发生错误: $e');
      if (mounted && context.mounted && Navigator.of(context).mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导入失败: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
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
                icon: Icon(
                  _hasStoragePermission ? Icons.check_circle : Icons.info,
                  color: _hasStoragePermission ? Colors.green : Colors.blue,
                ),
                title: const Text('存储权限'),
                subtitle: const Text('用于访问外部存储，当前使用应用目录'),
                isFirst: true,
                isLast: false,
                onTap: _requestStoragePermission,
              ),
              const Divider(height: 1),
              // 数据管理分组 - 导出配置
              _buildConnectedListTile(
                icon: const Icon(Icons.file_download, color: Colors.green),
                title: const Text('导出配置'),
                subtitle: const Text(
                  '位置：Download/20timer_backup（覆盖保存）',
                  style: TextStyle(fontSize: 10),
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
                subtitle: const Text(
                  '选择20timer_backup文件夹加载数据',
                  style: TextStyle(fontSize: 10),
                ),
                isFirst: false,
                isLast: false,
                onTap: _importConfig,
              ),
              const Divider(height: 1),
              // 数据管理分组 - 数据恢复
              _buildConnectedListTile(
                icon: const Icon(Icons.restore, color: Colors.orange),
                title: const Text('数据恢复'),
                subtitle: const Text('如果技能数据丢失，可以尝试恢复'),
                isFirst: false,
                isLast: true,
                onTap: _restoreSkillsData,
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

  // 恢复技能数据
  Future<void> _restoreSkillsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupData = prefs.getStringList('skills_list_key_backup');

      if (backupData != null && backupData.isNotEmpty) {
        // 恢复主数据
        await prefs.setStringList('skills_list_key', backupData);
        await prefs.setInt(
          'skills_list_key_timestamp',
          prefs.getInt('skills_list_key_backup_timestamp') ??
              DateTime.now().millisecondsSinceEpoch,
        );

        if (mounted && context.mounted && Navigator.of(context).mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('技能数据已恢复，请重启应用'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted && context.mounted && Navigator.of(context).mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('没有找到备份数据'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && context.mounted && Navigator.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('恢复失败: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
