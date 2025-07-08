import 'package:flutter/material.dart';
import 'package:TwentyHours/models/skill_model.dart';

// 这个页面用于显示一个特定技能的详情和历史记录
class SkillDetailsScreen extends StatefulWidget {
  // 正在为哪个技能显示详情
  final Skill skill;

  // 构造函数，要求必须传入一个Skill对象
  SkillDetailsScreen({super.key, required this.skill});

  @override
  State<SkillDetailsScreen> createState() => _SkillDetailsScreenState();
}

class _SkillDetailsScreenState extends State<SkillDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 标题动态地显示当前技能的名称
        title: Text(widget.skill.name),
      ),
      body: Center(
        // TODO: 心情日记
        child: Text('“${widget.skill.name}” 的心情日记列表'),
      ),
    );
  }
}
