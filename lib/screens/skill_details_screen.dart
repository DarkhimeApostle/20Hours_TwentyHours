import 'package:flutter/material.dart';
import 'package:TwentyHours/models/skill_model.dart';

// 技能详情页面，显示技能的详细信息和历史记录
class SkillDetailsScreen extends StatefulWidget {
  // 需要传入要显示的技能对象
  final Skill skill;
  SkillDetailsScreen({super.key, required this.skill});

  @override
  State<SkillDetailsScreen> createState() => _SkillDetailsScreenState();
}

// SkillDetailsScreen的状态管理
class _SkillDetailsScreenState extends State<SkillDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 动态显示技能名称作为标题
        title: Text(widget.skill.name),
      ),
      body: Center(
        // 这里将来可以显示技能的心情日记等内容
        child: Text('“${widget.skill.name}” 的心情日记列表'),
      ),
    );
  }
}
