import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
              // 数据恢复
              ListTile(
                leading: const Icon(Icons.restore, color: Colors.orange),
                title: const Text('数据恢复'),
                subtitle: const Text('如果技能数据丢失，可以尝试恢复'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _restoreSkillsData,
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
