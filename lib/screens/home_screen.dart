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
  List<Skill> skills = [];

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
          totalTime: int.tryParse(parts[1]) ?? 0,
          icon: IconData(int.parse(parts[2]), fontFamily: 'MaterialIcons'),
          progress: double.parse(parts[3]),
        );
      }).toList();

      setState(() {
        skills = loadedSkills;
      });
    } else {
      // 没有数据时，显示默认欢迎技能
      setState(() {
        skills = [
          Skill(
            name: '开始您的第一个技能吧！',
            totalTime: 0,
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
    final List<String> skillsAsString = skills.map((skill) {
      return '${skill.name}|${skill.totalTime}|${skill.icon.codePoint}|${skill.progress}';
    }).toList();
    await prefs.setStringList('skills_list_key', skillsAsString);
  }

  // 删除指定索引的技能
  void _deleteSkill(int index) {
    setState(() {
      skills.removeAt(index);
    });
    _saveSkills();
  }

  // 添加新技能
  void addSkill(String name) {
    setState(() {
      skills.add(
        Skill(name: name, totalTime: 0, icon: Icons.star_border, progress: 0.0),
      );
    });
    _saveSkills();
  }

  // 更新技能名称
  void _updateSkill(int index, String newName) {
    setState(() {
      skills[index] = skills[index].copyWith(name: newName);
    });
    _saveSkills();
  }

  // 添加新方法：累加技能时长
  void addTimeToSkill(int index, int seconds) {
    if (index >= 0 && index < skills.length) {
      setState(() {
        skills[index] = skills[index].addTime(seconds);
      });
      _saveSkills();
    }
  }

  // 构建技能列表UI
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.builder(
        itemCount: skills.length,
        itemBuilder: (context, index) {
          final skill = skills[index];
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
                final result = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditSkillScreen(skill: skill, skillIndex: index),
                  ),
                );
                if (result != null) {
                  if (result['action'] == 'delete') {
                    _deleteSkill(result['skillIndex']);
                  } else if (result['action'] == 'save') {
                    setState(() {
                      skills[result['skillIndex']] = result['skill'];
                    });
                    _saveSkills();
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
