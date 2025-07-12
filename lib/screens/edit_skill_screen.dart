import 'package:flutter/material.dart';
import 'package:TwentyHours/models/skill_model.dart';

// 编辑技能页面，允许用户修改或删除技能
class EditSkillScreen extends StatefulWidget {
  // 需要传入要编辑的技能对象
  final Skill skillToEdit;
  const EditSkillScreen({super.key, required this.skillToEdit});

  @override
  State<EditSkillScreen> createState() => _EditSkillScreenState();
}

// EditSkillScreen的状态管理
class _EditSkillScreenState extends State<EditSkillScreen> {
  // 输入框控制器，用于管理技能名称输入
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // 初始化输入框内容为当前技能名称
    _nameController = TextEditingController(text: widget.skillToEdit.name);
  }

  @override
  void dispose() {
    // 页面销毁时释放资源
    _nameController.dispose();
    super.dispose();
  }

  // 显示删除确认对话框
  Future<bool> _showDeleteConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('您确定要永久删除【${widget.skillToEdit.name}】吗？此操作无法撤销。'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('确认删除'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  // 删除技能并返回主页面
  void _deleteAndExit() async {
    final confirmed = await _showDeleteConfirmationDialog();
    if (confirmed && mounted) {
      Navigator.pop(context, "DELETE");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑技能'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: '保存更改',
            onPressed: () {
              // 保存后返回输入框内容
              Navigator.pop(context, _nameController.text);
            },
          ),
        ],
      ),

      // 页面内容区域
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 技能名称输入框
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '技能名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),

            // 删除技能按钮
            ElevatedButton.icon(
              onPressed: _deleteAndExit,
              icon: const Icon(Icons.delete_forever_outlined),
              label: const Text('删除此技能'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
