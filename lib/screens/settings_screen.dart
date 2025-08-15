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
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  // 加载本地保存的图片路径
  Future<void> _loadImagePaths() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarPath = prefs.getString('user_avatar_path');
      _drawerBgPath = prefs.getString('drawer_bg_path');
    });
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('用户名不能为空')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName.trim());

    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('保存用户名成功'),
          duration: Duration(seconds: 2),
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
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('保存头像成功'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        await prefs.setString('drawer_bg_path', file.path);
        setState(() => _drawerBgPath = file.path);
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('保存侧边栏背景成功'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('保存图片时发生错误: $e');
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 导出配置
  Future<void> _exportConfig() async {
    try {
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

      // 复制图片文件到导出目录
      final exportDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory(
        '${exportDir.path}/backup_${DateTime.now().millisecondsSinceEpoch}',
      );
      await backupDir.create(recursive: true);

      // 复制头像
      if (_avatarPath != null && File(_avatarPath!).existsSync()) {
        final avatarFile = File(_avatarPath!);
        final backupAvatarPath = '${backupDir.path}/avatar.png';
        await avatarFile.copy(backupAvatarPath);
        configData['userInfo']['avatarPath'] = 'avatar.png';
      }

      // 复制侧边栏背景
      if (_drawerBgPath != null && File(_drawerBgPath!).existsSync()) {
        final bgFile = File(_drawerBgPath!);
        final backupBgPath = '${backupDir.path}/drawer_bg.png';
        await bgFile.copy(backupBgPath);
        configData['userInfo']['drawerBgPath'] = 'drawer_bg.png';
      }

      // 保存配置文件
      final configFile = File('${backupDir.path}/config.json');
      await configFile.writeAsString(jsonEncode(configData));

      // 创建压缩包（这里我们创建一个包含所有文件的目录）
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupName = '20timer_backup_$timestamp';
      final finalBackupDir = Directory('${exportDir.path}/$backupName');

      if (await backupDir.exists()) {
        await backupDir.rename(finalBackupDir.path);
      }

      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('配置已导出到: ${finalBackupDir.path}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: '复制路径',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: finalBackupDir.path));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('路径已复制到剪贴板')));
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('导出配置时发生错误: $e');
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 导入配置
  Future<void> _importConfig() async {
    try {
      // 选择备份目录
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择备份目录',
      );

      if (selectedDirectory == null) return;

      final backupDir = Directory(selectedDirectory);
      if (!await backupDir.exists()) {
        throw Exception('选择的目录不存在');
      }

      // 查找配置文件
      final configFile = File('${backupDir.path}/config.json');
      if (!await configFile.exists()) {
        throw Exception('在选择的目录中未找到配置文件');
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

      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('配置导入成功，请重启应用以应用更改'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('导入配置时发生错误: $e');
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              // 导出配置
              ListTile(
                leading: const Icon(Icons.file_download, color: Colors.green),
                title: const Text('导出配置'),
                subtitle: const Text('备份所有技能数据和设置'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: _exportConfig,
              ),
              const Divider(height: 1),
              // 导入配置
              ListTile(
                leading: const Icon(Icons.file_upload, color: Colors.blue),
                title: const Text('导入配置'),
                subtitle: const Text('从备份文件恢复数据'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: _importConfig,
              ),
              const Divider(height: 1),
              // 数据恢复
              ListTile(
                leading: const Icon(Icons.restore, color: Colors.orange),
                title: const Text('数据恢复'),
                subtitle: const Text('如果技能数据丢失，可以尝试恢复'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('邮箱已复制到剪贴板'),
                      duration: Duration(seconds: 2),
                    ),
                  );
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

        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('技能数据已恢复，请重启应用'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('没有找到备份数据'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('恢复失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
