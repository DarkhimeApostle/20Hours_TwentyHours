import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TwentyHours/models/skill_model.dart';
import 'package:TwentyHours/widgets/skill_card.dart';
import 'package:TwentyHours/screens/skill_details_screen.dart';
import 'package:TwentyHours/screens/edit_skill_screen.dart';
import '../main.dart';
import 'dart:convert';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:uuid/uuid.dart';

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
  // 记录已弹窗的技能名，防止重复弹窗
  Set<String> congratulatedSkills = {};
  // 记录已弹窗的技能id，防止重复弹窗（持久化）
  Set<String> congratulatedSkillIds = {};
  // 用户名（如需动态可从用户信息获取）
  final String userName = '开狼';
  bool _hasCheckedCongratulation = false; // 防止重复弹窗

  @override
  void initState() {
    super.initState();
    _loadCongratulatedSkills();
    _loadSkills(); // 页面初始化时加载技能数据
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSkills();
  }

  // 从本地存储加载技能数据
  Future<void> _loadSkills() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? skillsAsString = prefs.getStringList('skills_list_key');
    if (skillsAsString != null && skillsAsString.isNotEmpty) {
      final List<Skill> loadedSkills = skillsAsString
          .map((e) => Skill.fromMap(Map<String, dynamic>.from(jsonDecode(e))))
          .toList();
      setState(() {
        skills = loadedSkills;
        _hasCheckedCongratulation = false; // 每次加载后允许重新检查
      });
    } else {
      setState(() {
        skills = [
          Skill(
            id: Uuid().v4(),
            name: '开始您的第一个技能吧！',
            totalTime: 0,
            icon: Icons.pan_tool_alt_outlined,
            progress: 0.0,
          ),
        ];
        _hasCheckedCongratulation = false;
      });
    }
    // 调试：打印本地技能存储内容
    print('skills_list_key: ' + (skillsAsString?.join('\n') ?? 'null'));
    _checkAndShowCongratulation();
  }

  // 保存技能数据到本地
  Future<void> saveSkills() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> skillsAsString = skills
        .map((skill) => jsonEncode(skill.toMap()))
        .toList();
    await prefs.setStringList('skills_list_key', skillsAsString);
  }

  // 删除指定索引的技能
  void _deleteSkill(int index) {
    setState(() {
      skills.removeAt(index);
    });
    saveSkills();
  }

  // 添加新技能
  void addSkill(String name) {
    setState(() {
      skills.add(
        Skill(
          id: Uuid().v4(),
          name: name,
          totalTime: 0,
          icon: Icons.star_border,
          progress: 0.0,
        ),
      );
    });
    saveSkills();
  }

  // 更新技能名称
  void _updateSkill(int index, String newName) {
    setState(() {
      skills[index] = skills[index].copyWith(name: newName);
    });
    saveSkills();
  }

  // 添加新方法：累加技能时长
  void addTimeToSkill(int index, int seconds) {
    if (index >= 0 && index < skills.length) {
      setState(() {
        final oldSkill = skills[index];
        final newTotalTime = oldSkill.totalTime + seconds;
        // 如果累计时间变化且已祝贺，重置祝贺状态
        skills[index] = oldSkill.copyWith(
          totalTime: newTotalTime,
          congratulated: (oldSkill.congratulated && newTotalTime != oldSkill.totalTime)
              ? false
              : oldSkill.congratulated,
        );
      });
      saveSkills();
    }
  }

  // 跳转到添加技能页面（只用EditSkillScreen）
  void _onAddSkillPressed() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditSkillScreen(
          skill: Skill(
            id: Uuid().v4(),
            name: '',
            totalTime: 0,
            icon: Icons.star_border,
            progress: 0.0,
            groupId: null,
          ),
          skillIndex: null,
        ),
      ),
    );
    if (result != null && result['action'] == 'save') {
      setState(() {
        skills.add(result['skill']);
      });
      saveSkills();
    }
  }

  void _showCongratulationCard(String skillName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber, size: 56),
                    const SizedBox(height: 12),
                    Text(
                      '恭喜你$userName',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '技能$skillName已达成20小时积累！\n可以左滑卡片加入荣耀殿堂~',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 18),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: 0.8 + 0.2 * value,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(Icons.star, color: Colors.amber, size: 40),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('我知道了'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadCongratulatedSkills() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('congratulated_skill_ids') ?? [];
    setState(() {
      congratulatedSkillIds = ids.toSet();
    });
  }

  Future<void> _addCongratulatedSkill(String skillId) async {
    congratulatedSkillIds.add(skillId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('congratulated_skill_ids', congratulatedSkillIds.toList());
  }

  // 检查并弹出贺卡，只弹一次
  void _checkAndShowCongratulation() {
    if (_hasCheckedCongratulation) return;
    final ungloriedSkills = skills.where((s) => s.inHallOfGlory != true).toList();
    for (final skill in ungloriedSkills) {
      if (skill.progressBasedOn20Hours >= 1.0 && !skill.congratulated) {
        _hasCheckedCongratulation = true;
        Future.delayed(Duration.zero, () async {
          _showCongratulationCard(skill.name);
          setState(() {
            final idx = skills.indexOf(skill);
            if (idx != -1) {
              skills[idx] = skill.copyWith(congratulated: true);
            }
          });
          await saveSkills();
        });
        break; // 只弹一次
      }
    }
    _hasCheckedCongratulation = true;
  }

  // 构建技能列表UI
  @override
  Widget build(BuildContext context) {
    // 只展示未进殿堂的技能
    final ungloriedSkills = skills
        .where((s) => s.inHallOfGlory != true)
        .toList();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.builder(
        itemCount: ungloriedSkills.length,
        itemBuilder: (context, index) {
          final skill = ungloriedSkills[index];
          final realIndex = skills.indexOf(skill);
          return Slidable(
            key: ValueKey(skill.name + skill.totalTime.toString()),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.28,
              children: [
                SlidableAction(
                  onPressed: (context) {
                    setState(() {
                      skills[realIndex] = skill.copyWith(inHallOfGlory: true);
                    });
                    saveSkills();
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('已移入荣耀殿堂')));
                  },
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  icon: Icons.emoji_events,
                  label: '移入殿堂',
                  borderRadius: BorderRadius.circular(30),
                  autoClose: true,
                  flex: 1,
                ),
              ],
            ),
            child: InkWell(
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
                          EditSkillScreen(skill: skill, skillIndex: realIndex),
                    ),
                  );
                  if (result != null) {
                    if (result['action'] == 'delete') {
                      _deleteSkill(result['skillIndex']);
                    } else if (result['action'] == 'save') {
                      setState(() {
                        final oldSkill = skills[result['skillIndex']];
                        final newSkill = result['skill'];
                        // 如果累计时间变化且已祝贺，重置祝贺状态
                        skills[result['skillIndex']] =
                            (oldSkill.totalTime != newSkill.totalTime && oldSkill.congratulated)
                                ? newSkill.copyWith(congratulated: false)
                                : newSkill;
                      });
                      saveSkills();
                    }
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
