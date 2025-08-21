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
  const HallOfGloryScreen({super.key});

  @override
  State<HallOfGloryScreen> createState() => _HallOfGloryScreenState();
}

class _HallOfGloryScreenState extends State<HallOfGloryScreen>
    with TickerProviderStateMixin {
  List<Skill> skills = [];
  GlorySortType _sortType = GlorySortType.timeDesc;
  List<Skill> reorderList = [];
  late AnimationController _trophyController;
  late AnimationController _particlesController;

  @override
  void initState() {
    super.initState();
    _loadSkills();
    _trophyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _trophyController.forward();

    // 初始化粒子动画控制器
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    // _loadCustomOrder(); // 由_loadSkills里调用
  }

  @override
  void dispose() {
    _trophyController.dispose();
    _particlesController.dispose();
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
        } catch (parseError) {
          setState(() {
            skills = [];
          });
        }
      } else {
        setState(() {
          skills = [];
        });
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
                    '荣耀殿堂',
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
          // 简洁渐变背景
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFEF3C7), // 浅金色
                  Color(0xFFF59E0B), // 橙色
                  Color(0xFFB98036), // 深棕色
                ],
              ),
            ),
          ),
          // 飘动的金色粒子特效
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _particlesController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _GloryParticlesPainter(_particlesController),
                  );
                },
              ),
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
                                                      content: Text('已移出'),
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
                                        onTap: () {},
                                        onLongPress: () {},
                                      ),
                                    ),
                                  );
                                },
                              ))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGlory(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// 飘动的金色粒子特效Painter
class _GloryParticlesPainter extends CustomPainter {
  final Animation<double> animation;

  _GloryParticlesPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;

    for (int i = 0; i < 30; i++) {
      // 使用固定的种子生成随机数
      final random = Random(i * 1000);

      // 基础位置 - 限制在下半屏幕
      final baseX = random.nextDouble() * size.width;
      final baseY =
          size.height * 0.5 + random.nextDouble() * (size.height * 0.5);

      // 飘动动画 - 减小幅度
      final waveX = sin(progress * 2 * pi + i * 0.5) * 8;
      final waveY = cos(progress * 2 * pi + i * 0.3) * 6;

      // 最终位置
      final x = baseX + waveX;
      final y = baseY + waveY;

      // 粒子大小和透明度动画 - 更小更自然
      final sizeProgress = (sin(progress * 4 * pi + i) + 1) / 2;
      final radius = 0.8 + sizeProgress * 1.2;
      final opacity = 0.2 + sizeProgress * 0.3;

      // 绘制粒子 - 移除光晕，更自然
      final paint = Paint()..color = Colors.amber.withValues(alpha: opacity);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 静态卡片（无动画、无TickerProvider）
class StaticSkillCard extends StatelessWidget {
  final Skill skill;
  const StaticSkillCard({super.key, required this.skill});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconBg =
        theme.iconTheme.color?.withValues(alpha: 0.12) ?? Colors.grey.shade200;
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
              padding: const EdgeInsets.all(12),
              child: Icon(
                skillIconMap[skill.iconCodePoint] ?? Icons.help_outline,
                color: Color(skill.iconColor),
                size: 28,
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
