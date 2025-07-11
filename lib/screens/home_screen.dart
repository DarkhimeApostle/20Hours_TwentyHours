import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TwentyHours/models/skill_model.dart'; // 引入“Skill”数据模型的定义
import 'package:TwentyHours/widgets/skill_card.dart'; // 引入“SkillCard”UI组件的定义
import 'package:TwentyHours/screens/skill_details_screen.dart';
import 'package:TwentyHours/screens/edit_skill_screen.dart';

// ===========================================================================
// HomeScreen: “计时”主页面，显示技能列表
// ===========================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  //  1. 状态变量
  List<Skill> _skills = []; // 初始化一个空列表

  //  2. 生命周期
  @override
  void initState() {
    super.initState();
    _loadSkills(); // 立刻从硬盘加载数据
  }

  // 3. 核心逻辑方法
  Future<void> _loadSkills() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? skillsAsString = prefs.getStringList('skills_list_key');

    if (skillsAsString != null && skillsAsString.isNotEmpty) {
      // 如果有数据，就解码回一个 List<Skill>
      final List<Skill> loadedSkills = skillsAsString.map((skillString) {
        final parts = skillString.split('|');
        return Skill(
          name: parts[0],
          totalTime: parts[1],
          icon: IconData(int.parse(parts[2]), fontFamily: 'MaterialIcons'),
          progress: double.parse(parts[3]),
        );
      }).toList();

      // 更新状态变量
      setState(() {
        _skills = loadedSkills;
      });
    } else {
      //一个默认的、欢迎性质的技能列表
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

  Future<void> _saveSkills() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> skillsAsString = _skills.map((skill) {
      return '${skill.name}|${skill.totalTime}|${skill.icon.codePoint}|${skill.progress}';
    }).toList();
    await prefs.setStringList('skills_list_key', skillsAsString);
  }

  void _deleteSkill(int index) {
    setState(() {
      _skills.removeAt(index);
    });
    _saveSkills();
  }

  // 处理 添加 的逻辑
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

  void _updateSkill(int index, String newName) {
    setState(() {
      // 使用 copyWith 方法来创建一个新的 Skill 对象
      // 这样可以保持 Skill 对象的不可变性
      _skills[index] = _skills[index].copyWith(name: newName);
    });
    // 保存更新后的列表
    _saveSkills();
  }

  // 4. UI构建方法
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _skills.length,
      itemBuilder: (context, index) {
        final skill = _skills[index];
        return InkWell(
          onTap: () {
            // 点击卡片，跳转到详情页
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SkillDetailsScreen(skill: skill),
              ),
            );
          },
          child: SkillCard(
            skill: skill,

            onCardTapped: () {
              print('点击了卡片: ${_skills[index].name}');
              // 点击卡片，跳转到详情页
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SkillDetailsScreen(skill: skill),
                ),
              );
            },
            onCardLongPressed: () async {
              // 返回值的类型现在可能是 String 或 null
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditSkillScreen(skillToEdit: skill),
                ),
              );

              //  检查返回的结果
              if (result != null) {
                // 如果返回
                if (result == "DELETE") {
                  _deleteSkill(index);
                }
                // 否则，如果它是一个非空的字符串，说明是“更新”
                else if (result.isNotEmpty) {
                  _updateSkill(index, result);
                }
              }
            },
          ),
        );
      },
    );
  }
}
