import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/skill_model.dart';
import '../widgets/skill_card.dart';
import 'dart:math';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/icon_map.dart';

enum GlorySortType { timeDesc, nameAsc, custom }

class HallOfGloryScreen extends StatefulWidget {
  const HallOfGloryScreen({Key? key}) : super(key: key);

  @override
  State<HallOfGloryScreen> createState() => _HallOfGloryScreenState();
}

class _HallOfGloryScreenState extends State<HallOfGloryScreen>
    with SingleTickerProviderStateMixin {
  List<Skill> skills = [];
  GlorySortType _sortType = GlorySortType.timeDesc;
  List<Skill> reorderList = [];
  late AnimationController _trophyController;
  late Animation<double> _trophyScale;

  @override
  void initState() {
    super.initState();
    _loadSkills();
    _trophyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _trophyScale = CurvedAnimation(
      parent: _trophyController,
      curve: Curves.elasticOut,
    );
    _trophyController.forward();
    // _loadCustomOrder(); // 由_loadSkills里调用
  }

  @override
  void dispose() {
    _trophyController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 当依赖项改变时（比如从其他页面返回），重新加载数据
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? skillsAsString = prefs.getStringList(
        'skills_list_key',
      );

      if (skillsAsString != null && skillsAsString.isNotEmpty) {
        try {
          final List<Skill> loadedSkills = skillsAsString
              .map(
                (e) => Skill.fromMap(Map<String, dynamic>.from(jsonDecode(e))),
              )
              .toList();

          setState(() {
            // 只显示已进入荣耀殿堂的技能
            skills = loadedSkills
                .where((s) => s.inHallOfGlory == true)
                .toList();
          });

          print('荣耀殿堂加载了 ${skills.length} 个技能');
        } catch (parseError) {
          print('解析荣耀殿堂技能数据失败: $parseError');
          setState(() {
            skills = [];
          });
        }
      } else {
        setState(() {
          skills = [];
        });
        print('没有找到技能数据');
      }
    } catch (e) {
      print('加载荣耀殿堂技能时发生错误: $e');
      setState(() {
        skills = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 排序逻辑
    List<Skill> sortedSkills = List.from(skills);
    if (_sortType == GlorySortType.timeDesc) {
      sortedSkills.sort((a, b) => b.totalTime.compareTo(a.totalTime));
    } else if (_sortType == GlorySortType.nameAsc) {
      sortedSkills.sort((a, b) => a.name.compareTo(b.name));
    }

    // 调试信息
    print('荣耀殿堂：技能数 ${skills.length}');
    for (final skill in skills) {
      print('荣耀殿堂技能: ${skill.name}, inHallOfGlory: ${skill.inHallOfGlory}');
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 8,
              left: 12,
              right: 12,
              bottom: 4,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 28,
                  color: Colors.amber.shade700,
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.amber.shade200,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '荣耀殿堂技能',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.brown.shade900,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.amber.shade100,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<GlorySortType>(
                  icon: const Icon(Icons.sort, color: Colors.brown, size: 26),
                  onSelected: (type) async {
                    setState(() {
                      _sortType = type;
                    });
                    if (type == GlorySortType.custom && skills.isNotEmpty) {
                      setState(() {
                        reorderList = List.from(skills);
                      });
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: GlorySortType.timeDesc,
                      child: Text('按累积时间从大到小'),
                    ),
                    const PopupMenuItem(
                      value: GlorySortType.nameAsc,
                      child: Text('按名称排序'),
                    ),
                    const PopupMenuItem(
                      value: GlorySortType.custom,
                      child: Text('自定义排序'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _sortType == GlorySortType.custom
          ? FloatingActionButton.extended(
              onPressed: () async {
                setState(() {
                  skills = List.from(reorderList);
                  _sortType = GlorySortType.timeDesc;
                });
                // 保存顺序到本地
                final prefs = await SharedPreferences.getInstance();
                final List<String> skillsAsString = skills
                    .map((s) => jsonEncode(s.toMap()))
                    .toList();
                await prefs.setStringList('skills_list_key', skillsAsString);
              },
              icon: Icon(Icons.check),
              label: Text('完成排序'),
            )
          : null,
      body: Stack(
        children: [
          // 渐变背景
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFDE68A),
                  Color(0xFFF59E42),
                  Color(0xFFB98036),
                ],
              ),
            ),
          ),
          // 粒子特效（简单星星）
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _GloryParticlesPainter()),
            ),
          ),
          // 内容
          SafeArea(
            child: Column(
              children: [
                // 技能卡片区始终可流畅上下滑动
                Expanded(
                  child: (_sortType == GlorySortType.custom
                      ? ReorderableListView(
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex--;
                              final item = reorderList.removeAt(oldIndex);
                              reorderList.insert(newIndex, item);
                            });
                          },
                          children: [
                            for (
                              int index = 0;
                              index < reorderList.length;
                              index++
                            )
                              Padding(
                                key: ValueKey(reorderList[index].id),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: StaticSkillCard(
                                  skill: reorderList[index],
                                ),
                              ),
                          ],
                        )
                      : (sortedSkills.isEmpty
                            ? _buildEmptyGlory(context)
                            : ListView.builder(
                                itemCount: sortedSkills.length,
                                itemBuilder: (context, index) {
                                  final skill = sortedSkills[index];
                                  final realIndex = skills.indexOf(skill);
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Slidable(
                                      key: ValueKey(
                                        skill.name + skill.totalTime.toString(),
                                      ),
                                      endActionPane: ActionPane(
                                        motion: const DrawerMotion(),
                                        extentRatio: 0.28,
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) async {
                                              try {
                                                // 移出殿堂
                                                final prefs =
                                                    await SharedPreferences.getInstance();

                                                // 加载完整的技能列表
                                                final List<String>?
                                                allSkillsAsString = prefs
                                                    .getStringList(
                                                      'skills_list_key',
                                                    );
                                                if (allSkillsAsString == null ||
                                                    allSkillsAsString.isEmpty) {
                                                  throw Exception('无法加载技能数据');
                                                }

                                                // 解析完整的技能列表
                                                final List<Skill> allSkills =
                                                    allSkillsAsString
                                                        .map(
                                                          (e) => Skill.fromMap(
                                                            Map<
                                                              String,
                                                              dynamic
                                                            >.from(
                                                              jsonDecode(e),
                                                            ),
                                                          ),
                                                        )
                                                        .toList();

                                                // 找到对应的技能并更新状态
                                                final skillIndex = allSkills
                                                    .indexWhere(
                                                      (s) => s.id == skill.id,
                                                    );
                                                if (skillIndex == -1) {
                                                  throw Exception('找不到对应的技能');
                                                }

                                                // 更新技能状态
                                                allSkills[skillIndex] = skill
                                                    .copyWith(
                                                      inHallOfGlory: false,
                                                    );

                                                // 准备保存数据
                                                final List<String>
                                                skillsAsString = allSkills
                                                    .map(
                                                      (s) =>
                                                          jsonEncode(s.toMap()),
                                                    )
                                                    .toList();

                                                // 先保存备份
                                                await prefs.setStringList(
                                                  'skills_list_key_backup',
                                                  skillsAsString,
                                                );
                                                await prefs.setInt(
                                                  'skills_list_key_backup_timestamp',
                                                  DateTime.now()
                                                      .millisecondsSinceEpoch,
                                                );

                                                // 再保存主数据
                                                await prefs.setStringList(
                                                  'skills_list_key',
                                                  skillsAsString,
                                                );
                                                await prefs.setInt(
                                                  'skills_list_key_timestamp',
                                                  DateTime.now()
                                                      .millisecondsSinceEpoch,
                                                );

                                                // 更新当前页面的技能列表
                                                setState(() {
                                                  skills = allSkills
                                                      .where(
                                                        (s) =>
                                                            s.inHallOfGlory ==
                                                            true,
                                                      )
                                                      .toList();
                                                });

                                                // 检查widget是否仍然挂载
                                                if (mounted &&
                                                    context.mounted) {
                                                  // 显示成功消息
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('已移出荣耀殿堂'),
                                                      backgroundColor:
                                                          Colors.green,
                                                      duration: Duration(
                                                        seconds: 2,
                                                      ),
                                                    ),
                                                  );
                                                }

                                                // 显示成功消息，用户手动返回
                                                if (mounted &&
                                                    context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        '已移出荣耀殿堂，返回主界面查看',
                                                      ),
                                                      backgroundColor:
                                                          Colors.green,
                                                      duration: Duration(
                                                        seconds: 3,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                print('移出殿堂时发生错误: $e');
                                                if (mounted &&
                                                    context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text('移出失败: $e'),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            backgroundColor: Colors.grey,
                                            foregroundColor: Colors.white,
                                            icon: Icons.undo,
                                            label: '移出',
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            autoClose: true,
                                            flex: 1,
                                          ),
                                        ],
                                      ),
                                      child: SkillCard(
                                        skill: skill,
                                        onCardTapped: () {},
                                        onCardLongPressed: () {},
                                      ),
                                    ),
                                  );
                                },
                              ))),
                ),
                if (skills.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      '荣耀属于坚持不懈的你！',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.amber.shade800,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.amber.shade100,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGlory(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Colors.amber.shade200,
          ),
          const SizedBox(height: 16),
          Text(
            '还没有技能进入荣耀殿堂',
            style: TextStyle(
              fontSize: 20,
              color: Colors.brown.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '继续努力，解锁属于你的荣耀吧！',
            style: TextStyle(fontSize: 16, color: Colors.brown.shade400),
          ),
        ],
      ),
    );
  }
}

// 简单粒子特效Painter（星星）
class _GloryParticlesPainter extends CustomPainter {
  final Random _random = Random();
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 30; i++) {
      final dx = _random.nextDouble() * size.width;
      final dy = _random.nextDouble() * size.height;
      final radius = _random.nextDouble() * 1.8 + 0.7;
      final paint = Paint()
        ..color = Colors.amber.withOpacity(_random.nextDouble() * 0.5 + 0.2);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 静态卡片（无动画、无TickerProvider）
class StaticSkillCard extends StatelessWidget {
  final Skill skill;
  const StaticSkillCard({super.key, required this.skill});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconBg =
        theme.iconTheme.color?.withOpacity(0.12) ?? Colors.grey.shade200;
    final textMain = theme.textTheme.bodyLarge?.color ?? Colors.black;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              padding: const EdgeInsets.all(10),
              child: Icon(
                skillIconMap[skill.iconCodePoint] ?? Icons.help_outline,
                color: theme.iconTheme.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                skill.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textMain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
