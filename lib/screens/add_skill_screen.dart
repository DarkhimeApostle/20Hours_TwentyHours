import 'package:flutter/material.dart';

//需要一个TextEditingController来记住用户的输入
class AddSkillScreen extends StatefulWidget {
  const AddSkillScreen({super.key});

  @override
  State<AddSkillScreen> createState() => _AddSkillScreenState();
}

class _AddSkillScreenState extends State<AddSkillScreen> {
  // 1. 创建一个专门用于控制TextField的“遥控器”
  final _textController = TextEditingController();

  // 2. 在State被销毁时，销毁这个Controller，以释放资源
  @override
  void dispose() {
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
            // 将遥控器，与这个TextField进行绑定
            TextField(
              controller: _textController,
              // autofocus: true 可以让页面打开时，输入框自动获得焦点
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '技能名称',
                hintText: '例如：学习英语',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 当“保存”被点击时，获取输入框中的文本
                final newSkillName = _textController.text;
                // 检查文本是否不为空
                if (newSkillName.isNotEmpty) {
                  // 调用Navigator.pop，关闭当前页面，并将新技能名称作为“结果”返回
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
