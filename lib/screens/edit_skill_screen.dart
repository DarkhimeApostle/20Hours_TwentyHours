import 'package:flutter/material.dart';
import 'package:TwentyHours/models/skill_model.dart';

// 编辑技能页面
class EditSkillScreen extends StatefulWidget {
  // [核心] 这个页面需要知道它正在编辑的是哪个技能
  // 所以我们通过构造函数将整个 Skill 对象传递进来
  final Skill skillToEdit;

  const EditSkillScreen({super.key, required this.skillToEdit});

  @override
  State<EditSkillScreen> createState() => _EditSkillScreenState();
}

class _EditSkillScreenState extends State<EditSkillScreen> {
  // 使用 TextEditingController 来管理输入框的文本
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // [核心] 当页面初始化时，用传入技能的当前名称来初始化输入框
    _nameController = TextEditingController(text: widget.skillToEdit.name);
  }

  @override
  void dispose() {
    // 及时释放资源，防止内存泄漏
    _nameController.dispose();
    super.dispose();
  }

  // 一个用于显示删除确认对话框的异步方法
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

  // 当用户点击“删除此技能”按钮时调用的方法
  void _deleteAndExit() async {
    final confirmed = await _showDeleteConfirmationDialog();
    // 只有当用户在对话框中明确点击了“确认删除”
    if (confirmed && mounted) {
      // 'mounted' 检查确保组件仍然在屏幕上
      // 我们约定，返回一个特殊的字符串 "DELETE" 来通知主屏幕
      Navigator.pop(context, "DELETE");
    }
  }

  //build 方法

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑技能'),
        // [核心新增] 在 AppBar 右侧添加“保存”按钮
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: '保存更改',
            onPressed: () {
              // [核心新增] 当点击保存时，关闭当前页面，并返回输入框中的最新文本
              Navigator.pop(context, _nameController.text);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '技能名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            // [核心] 这是我们放置“删除”按钮的理想位置
            ElevatedButton.icon(
              onPressed: _deleteAndExit,
              icon: const Icon(Icons.delete_forever_outlined),
              label: const Text('删除此技能'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50), // 让按钮横向填满
              ),
            ),
          ],
        ),
      ),
    );
  }
}
