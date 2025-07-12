import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TwentyHours/models/skill_model.dart';
import 'package:TwentyHours/widgets/skill_card.dart';
import 'package:TwentyHours/screens/skill_details_screen.dart';
import 'package:TwentyHours/screens/edit_skill_screen.dart';
import '../main.dart';

// 计时主页面，显示技能列表
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

// HomeScreen的状态管理
class HomeScreenState extends State<HomeScreen> {
  // 技能列表
  List<Skill> _skills = [];

  @override
  void initState() {
    super.initState();
    _loadSkills(); // 页面初始化时加载技能数据
  }

  // 从本地存储加载技能数据
  Future<void> _loadSkills() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? skillsAsString = prefs.getStringList('skills_list_key');

    if (skillsAsString != null && skillsAsString.isNotEmpty) {
      // 有数据时，解码为技能对象列表
      final List<Skill> loadedSkills = skillsAsString.map((skillString) {
        final parts = skillString.split('|');
        return Skill(
          name: parts[0],
          totalTime: parts[1],
          icon: IconData(int.parse(parts[2]), fontFamily: 'MaterialIcons'),
          progress: double.parse(parts[3]),
        );
      }).toList();

      setState(() {
        _skills = loadedSkills;
      });
    } else {
      // 没有数据时，显示默认欢迎技能
      setState(() {
        _skills = [
          Skill(
            name: '开始您的第一个技能吧！',
            totalTime: '点击下方+号添加',
            icon: Icons.pan_tool_alt_outlined,
            progress: 0.1,
          ),
        ];
      });
    }
  }

  // 保存技能数据到本地
  Future<void> _saveSkills() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> skillsAsString = _skills.map((skill) {
      return '${skill.name}|${skill.totalTime}|${skill.icon.codePoint}|${skill.progress}';
    }).toList();
    await prefs.setStringList('skills_list_key', skillsAsString);
  }

  // 删除指定索引的技能
  void _deleteSkill(int index) {
    setState(() {
      _skills.removeAt(index);
    });
    _saveSkills();
  }

  // 添加新技能
  void addSkill(String name) {
    setState(() {
      _skills.add(
        Skill(
          name: name,
          totalTime: '0小时 0分钟',
          icon: Icons.star_border,
          progress: 0.0,
        ),
      );
    });
    _saveSkills();
  }

  // 更新技能名称
  void _updateSkill(int index, String newName) {
    setState(() {
      _skills[index] = _skills[index].copyWith(name: newName);
    });
    _saveSkills();
  }

  // 构建技能列表UI
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.builder(
        itemCount: _skills.length,
        itemBuilder: (context, index) {
          final skill = _skills[index];
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SkillDetailsScreen(skill: skill),
                ),
              );
            },
            child: SkillCard(
              skill: skill,
              onCardTapped: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SkillDetailsScreen(skill: skill),
                  ),
                );
              },
              onCardLongPressed: () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditSkillScreen(skillToEdit: skill),
                  ),
                );
                if (result != null) {
                  if (result == "DELETE") {
                    _deleteSkill(index);
                  } else if (result.isNotEmpty) {
                    _updateSkill(index, result);
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }
}
