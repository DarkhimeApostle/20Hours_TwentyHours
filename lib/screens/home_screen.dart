import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TwentyHours/models/skill_model.dart';
import 'package:TwentyHours/widgets/skill_card.dart';
import 'package:TwentyHours/screens/skill_details_screen.dart';
import 'package:TwentyHours/screens/edit_skill_screen.dart';
import 'dart:convert';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:uuid/uuid.dart';
import 'package:TwentyHours/utils/config_exporter.dart';

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
  bool _isInitialized = false; // 防止重复初始化

  @override
  void initState() {
    super.initState();
    _loadCongratulatedSkills();
    loadSkills(); // 页面初始化时加载技能数据
    _validateDataIntegrity(); // 验证数据完整性
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 只在首次加载时执行，避免重复加载导致技能列表被清除
    if (!_isInitialized) {
      _isInitialized = true;
    } else {
      // 如果不是首次加载，重新加载数据以确保同步
      loadSkills();
    }
  }

  // 从本地存储加载技能数据
  Future<void> loadSkills() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? skillsAsString = prefs.getStringList(
        'skills_list_key',
      );

      // 调试：打印本地技能存储内容
      print('skills_list_key: ${skillsAsString?.join('\n') ?? 'null'}');

      if (skillsAsString != null && skillsAsString.isNotEmpty) {
        try {
          final List<Skill> loadedSkills = skillsAsString
              .map(
                (e) => Skill.fromMap(Map<String, dynamic>.from(jsonDecode(e))),
              )
              .toList();

          // 验证加载的技能数据
          if (loadedSkills.isNotEmpty) {
            // 加载永久祝贺记录
            await _loadCongratulatedSkills();

            // 检查每个技能是否已经永久祝贺过
            for (int i = 0; i < loadedSkills.length; i++) {
              if (congratulatedSkillIds.contains(loadedSkills[i].id)) {
                // 如果技能ID在永久祝贺记录中，设置为已祝贺
                loadedSkills[i] = loadedSkills[i].copyWith(congratulated: true);
              }
            }

            setState(() {
              skills = loadedSkills;
              _hasCheckedCongratulation = false; // 每次加载后允许重新检查
            });
            print('成功加载 ${loadedSkills.length} 个技能');
          } else {
            throw Exception('加载的技能列表为空');
          }
        } catch (parseError) {
          print('解析技能数据失败: $parseError');
          // 如果解析失败，尝试从备份恢复
          await _restoreFromBackup();
          if (skills.isEmpty) {
            _createDefaultSkill();
          }
        }
      } else {
        print('没有找到技能数据，尝试从备份恢复');
        await _restoreFromBackup();
        if (skills.isEmpty) {
          _createDefaultSkill();
        }
      }
    } catch (e) {
      print('加载技能数据时发生错误: $e');
      // 发生错误时尝试从备份恢复
      await _restoreFromBackup();
      if (skills.isEmpty) {
        _createDefaultSkill();
      }
    }

    await _checkAndShowCongratulation();
  }

  // 创建默认技能
  void _createDefaultSkill() {
    setState(() {
      skills = [
        Skill(
          id: Uuid().v4(),
          name: '开始您的第一个技能吧！',
          totalTime: 0,
          iconCodePoint: Icons.pan_tool_alt_outlined.codePoint,
          progress: 0.0,
        ),
      ];
      _hasCheckedCongratulation = false;
    });
  }

  // 保存技能数据到本地
  Future<void> saveSkills() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> skillsAsString = skills
          .map((skill) => jsonEncode(skill.toMap()))
          .toList();

      // 验证数据完整性
      if (skillsAsString.isNotEmpty) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        // 先保存备份
        await prefs.setStringList('skills_list_key_backup', skillsAsString);
        await prefs.setInt('skills_list_key_backup_timestamp', timestamp);

        // 再保存主数据
        await prefs.setStringList('skills_list_key', skillsAsString);
        await prefs.setInt('skills_list_key_timestamp', timestamp);

        print('成功保存 ${skills.length} 个技能到本地存储');
        
        // 技能保存后自动导出配置
        await ConfigExporter.autoExportConfig();
      } else {
        print('警告：尝试保存空的技能列表');
      }
    } catch (e) {
      print('保存技能数据时发生错误: $e');
      // 可以在这里添加用户提示
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存技能数据失败: $e')));
      }
    }
  }

  // 从备份恢复数据
  Future<void> _restoreFromBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupData = prefs.getStringList('skills_list_key_backup');

      if (backupData != null && backupData.isNotEmpty) {
        final List<Skill> restoredSkills = backupData
            .map((e) => Skill.fromMap(Map<String, dynamic>.from(jsonDecode(e))))
            .toList();

        setState(() {
          skills = restoredSkills;
        });

        // 恢复主数据
        await prefs.setStringList('skills_list_key', backupData);

        print('从备份恢复了 ${restoredSkills.length} 个技能');
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('已从备份恢复技能数据')));
        }
      }
    } catch (e) {
      print('从备份恢复数据失败: $e');
    }
  }

  // 删除指定索引的技能
  void _deleteSkill(int index) async {
    final skillToDelete = skills[index];
    setState(() {
      skills.removeAt(index);
    });
    await saveSkills();

    // 从永久祝贺记录中移除该技能
    if (congratulatedSkillIds.contains(skillToDelete.id)) {
      congratulatedSkillIds.remove(skillToDelete.id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'congratulated_skill_ids',
        congratulatedSkillIds.toList(),
      );
      print('已从永久祝贺记录中移除技能: ${skillToDelete.name}');
    }
  }

  // 添加新技能
  void addSkill(String name) {
    setState(() {
      skills.add(
        Skill(
          id: Uuid().v4(),
          name: name,
          totalTime: 0,
          iconCodePoint: Icons.star_border.codePoint,
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
        // 保持原有的祝贺状态，不再重置
        skills[index] = oldSkill.copyWith(totalTime: newTotalTime);
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
            iconCodePoint: Icons.star_border.codePoint,
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
    print('加载永久祝贺记录: ${congratulatedSkillIds.length} 个技能');
    for (final id in congratulatedSkillIds) {
      print('永久祝贺技能ID: $id');
    }
  }

  Future<void> _addCongratulatedSkill(String skillId) async {
    congratulatedSkillIds.add(skillId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'congratulated_skill_ids',
      congratulatedSkillIds.toList(),
    );
    print('已添加技能到永久祝贺记录: $skillId');
  }

  // 检查并弹出贺卡，只弹一次
  Future<void> _checkAndShowCongratulation() async {
    if (_hasCheckedCongratulation) return;
    final ungloriedSkills = skills
        .where((s) => s.inHallOfGlory != true)
        .toList();
    for (final skill in ungloriedSkills) {
      if (skill.progressBasedOn20Hours >= 1.0 && !skill.congratulated) {
        _hasCheckedCongratulation = true;
        _showCongratulationCard(skill.name);
        // 标记为已祝贺，永久保存
        setState(() {
          final idx = skills.indexOf(skill);
          if (idx != -1) {
            skills[idx] = skill.copyWith(congratulated: true);
          }
        });
        await saveSkills();
        // 保存到永久祝贺记录
        await _addCongratulatedSkill(skill.id);
        break; // 只弹一次
      }
    }
    _hasCheckedCongratulation = true;
  }

  // 验证数据完整性
  Future<void> _validateDataIntegrity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mainData = prefs.getStringList('skills_list_key');
      final backupData = prefs.getStringList('skills_list_key_backup');

      // 检查主数据和备份数据的一致性
      if (mainData != null && backupData != null) {
        if (mainData.length != backupData.length) {
          print('警告：主数据和备份数据长度不一致');
          // 使用较新的数据
          final mainTime = prefs.getInt('skills_list_key_timestamp') ?? 0;
          final backupTime =
              prefs.getInt('skills_list_key_backup_timestamp') ?? 0;

          if (backupTime > mainTime) {
            print('使用备份数据恢复');
            await prefs.setStringList('skills_list_key', backupData);
            await prefs.setInt('skills_list_key_timestamp', backupTime);
          }
        }
      }
    } catch (e) {
      print('数据完整性检查失败: $e');
    }
  }

  // 构建技能列表UI
  @override
  Widget build(BuildContext context) {
    // 只展示未进殿堂的技能
    final ungloriedSkills = skills
        .where((s) => s.inHallOfGlory != true)
        .toList();

    // 调试信息
    print('主界面：总技能数 ${skills.length}，未进殿堂技能数 ${ungloriedSkills.length}');
    for (final skill in skills) {
      print('技能: ${skill.name}, inHallOfGlory: ${skill.inHallOfGlory}');
    }

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
                  onPressed: (context) async {
                    try {
                      // 更新技能状态
                      setState(() {
                        skills[realIndex] = skill.copyWith(inHallOfGlory: true);
                      });

                      // 保存到本地存储
                      await saveSkills();

                      // 使用更安全的方式显示消息
                      if (mounted && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('已移入荣耀殿堂'),
                            backgroundColor: Colors.amber,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      print('移入殿堂时发生错误: $e');
                      if (mounted && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('移入失败: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  icon: Icons.emoji_events,
                  label: '移入',
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
                        // 保持原有的祝贺状态，不再重置
                        skills[result['skillIndex']] = newSkill;
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
