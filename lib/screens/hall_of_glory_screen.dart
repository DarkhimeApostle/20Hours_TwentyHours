import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/skill_model.dart';
import '../widgets/skill_card.dart';
import 'dart:math';
import 'package:flutter_slidable/flutter_slidable.dart';

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

  Future<void> _loadSkills() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? skillsAsString = prefs.getStringList('skills_list_key');
    if (skillsAsString != null && skillsAsString.isNotEmpty) {
      final List<Skill> loadedSkills = skillsAsString
          .map((e) => Skill.fromMap(Map<String, dynamic>.from(jsonDecode(e))))
          .toList();
      setState(() {
        skills = loadedSkills.where((s) => s.inHallOfGlory == true).toList();
      });
      // 不再自动调用_loadCustomOrder，避免死循环
    } else {
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
                                              // 移出殿堂
                                              final prefs =
                                                  await SharedPreferences.getInstance();
                                              setState(() {
                                                skills[realIndex] = skill
                                                    .copyWith(
                                                      inHallOfGlory: false,
                                                    );
                                              });
                                              // 更新本地存储
                                              final List<String>
                                              skillsAsString = skills
                                                  .map(
                                                    (s) =>
                                                        jsonEncode(s.toMap()),
                                                  )
                                                  .toList();
                                              await prefs.setStringList(
                                                'skills_list_key',
                                                skillsAsString,
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text('已移出荣耀殿堂'),
                                                ),
                                              );
                                              // 重新加载技能，确保主页面也能刷新
                                              _loadSkills();
                                            },
                                            backgroundColor: Colors.grey,
                                            foregroundColor: Colors.white,
                                            icon: Icons.undo,
                                            label: '移出殿堂',
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
              child: Icon(skill.icon, color: theme.iconTheme.color, size: 24),
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
