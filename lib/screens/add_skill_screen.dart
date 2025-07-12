import 'package:flutter/material.dart';

// 添加新技能页面，允许用户输入技能名称
class AddSkillScreen extends StatefulWidget {
  const AddSkillScreen({super.key});

  @override
  State<AddSkillScreen> createState() => _AddSkillScreenState();
}

// AddSkillScreen的状态管理
class _AddSkillScreenState extends State<AddSkillScreen> {
  // 输入框控制器
  final _textController = TextEditingController();

  @override
  void dispose() {
    // 页面销毁时释放资源
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('添加新技能')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 技能名称输入框
            TextField(
              controller: _textController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '技能名称',
                hintText: '例如：学习英语',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // 保存按钮
            ElevatedButton(
              onPressed: () {
                final newSkillName = _textController.text;
                if (newSkillName.isNotEmpty) {
                  Navigator.of(context).pop(newSkillName);
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
