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

  @override
  void initState() {
    super.initState();
    _loadImagePaths();
    _loadUserName();
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
    setState(() {
      _userName = prefs.getString('user_name') ?? '开狼';
    });
  }

  // 保存用户名
  Future<void> _saveUserName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName.trim());
    if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
    }
  }

  // 选择图片并保存到本地
  Future<void> _pickAndSaveImage({required bool isAvatar}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final fileName = isAvatar
        ? 'user_avatar_${DateTime.now().millisecondsSinceEpoch}.png'
        : 'drawer_bg.png';
    final savePath = '${dir.path}/$fileName';
    final file = await File(picked.path).copy(savePath);
    final prefs = await SharedPreferences.getInstance();
    if (isAvatar) {
      await prefs.setString('user_avatar_path', file.path);
      setState(() => _avatarPath = file.path);
    } else {
      await prefs.setString('drawer_bg_path', file.path);
      setState(() => _drawerBgPath = file.path);
    }
    // 通知主界面刷新
    if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // 用户名设置
          Center(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: '用户名',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: _userName),
                  onChanged: (v) => _userName = v,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _saveUserName,
                  child: const Text('保存用户名'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          // 头像设置
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: _avatarPath != null
                      ? FileImage(File(_avatarPath!))
                      : const AssetImage('assets/images/avatar.png')
                            as ImageProvider,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _pickAndSaveImage(isAvatar: true),
                  child: const Text('更换头像'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          // 侧边栏背景设置
          Center(
            child: Column(
              children: [
                Container(
                  width: 180,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: _drawerBgPath != null
                          ? FileImage(File(_drawerBgPath!))
                          : const AssetImage('assets/images/drawer_bg.jpg')
                                as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _pickAndSaveImage(isAvatar: false),
                  child: const Text('更换侧边栏背景'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
