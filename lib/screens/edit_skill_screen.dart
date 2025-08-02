import 'package:flutter/material.dart';
import 'package:TwentyHours/models/skill_model.dart';
import 'package:TwentyHours/main.dart';
import '../models/skill_group.dart';
import '../utils/group_storage.dart';
import 'package:uuid/uuid.dart';

// 预设分组颜色（与分组管理页保持一致）
const List<Color> kGroupColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  Colors.amber,
  Colors.pink,
  Colors.brown,
];

class EditSkillScreen extends StatefulWidget {
  final Skill skill;
  final int? skillIndex;

  const EditSkillScreen({super.key, required this.skill, this.skillIndex});

  @override
  State<EditSkillScreen> createState() => _EditSkillScreenState();
}

class _EditSkillScreenState extends State<EditSkillScreen>
    with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;

  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // 图标库
  final List<IconData> _availableIcons = [
    Icons.timer,
    Icons.school,
    Icons.work,
    Icons.fitness_center,
    Icons.music_note,
    Icons.book,
    Icons.code,
    Icons.brush,
    Icons.sports_esports,
    Icons.kitchen,
    Icons.directions_run,
    Icons.psychology,
    Icons.language,
    Icons.science,
    Icons.architecture,
    Icons.medical_services,
    Icons.computer,
    Icons.phone_android,
    Icons.camera_alt,
    Icons.videocam,
    Icons.headphones,
    Icons.gamepad,
    Icons.sports_soccer,
    Icons.sports_basketball,
    Icons.sports_tennis,
    Icons.sports_volleyball,
    Icons.sports_cricket,
    Icons.sports_hockey,
    Icons.sports_rugby,
    Icons.sports_martial_arts,
    Icons.sports_kabaddi,
    Icons.sports_motorsports,
    Icons.sports_esports,
    Icons.palette,
    Icons.coffee,
    Icons.restaurant,
    Icons.flight,
    Icons.train,
    Icons.directions_bike,
    Icons.nature,
    Icons.pets,
    Icons.child_care,
    Icons.emoji_nature,
    Icons.emoji_objects,
    Icons.emoji_people,
    Icons.emoji_food_beverage,
    Icons.emoji_transportation,
    Icons.emoji_emotions,
    Icons.emoji_symbols,
    Icons.emoji_flags,
    Icons.star,
    Icons.favorite,
    Icons.lightbulb,
    Icons.eco,
    Icons.public,
    Icons.wb_sunny,
    Icons.nights_stay,
    Icons.park,
    Icons.spa,
    Icons.pool,
    Icons.beach_access,
    Icons.icecream,
    Icons.cake,
    Icons.local_florist,
    Icons.local_cafe,
    Icons.local_bar,
    Icons.local_dining,
    Icons.local_pizza,
    Icons.local_play,
    Icons.movie,
    Icons.tv,
    Icons.radio,
    Icons.bookmark,
    Icons.library_books,
    Icons.menu_book,
    Icons.auto_stories,
    Icons.sports_golf,
    Icons.sports_handball,
    Icons.sports_baseball,
    Icons.sports_football,
    Icons.sports,
    Icons.surfing,
    Icons.hiking,
    Icons.bolt,
    Icons.bubble_chart,
    Icons.casino,
    Icons.color_lens,
    Icons.extension,
    Icons.face,
    Icons.flash_on,
    Icons.gesture,
    Icons.golf_course,
    Icons.hdr_strong,
    Icons.light_mode,
    Icons.nightlight,
    Icons.rocket,
    Icons.sailing,
    Icons.snowboarding,
    Icons.snowshoeing,
    Icons.sports_bar,
    Icons.sports_gymnastics,
    Icons.sports_mma,
    Icons.theater_comedy,
    Icons.toys,
    Icons.travel_explore,
    Icons.volunteer_activism,
    Icons.water,
    Icons.waves,
    Icons.wind_power,
  ];

  // 6种主色
  final List<Color> _iconColors = [
    Color(0xFF2563EB), // 蓝
    Color(0xFFF59E42), // 橙
    Color(0xFF10B981), // 绿
    Color(0xFFEF4444), // 红
    Color(0xFF8B5CF6), // 紫
    Color(0xFF14B8A6), // 青
  ];
  Color _selectedIconColor = Color(0xFF2563EB);

  int _selectedIconCodePoint = Icons.timer.codePoint;
  bool _isLoading = false;
  // 不恢复 _inHallOfGlory 变量，直接在按钮点击时赋值

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.skill.name);
    _selectedIconCodePoint = widget.skill.iconCodePoint;
    _selectedIconColor = Color(widget.skill.iconColor);

    // 将总秒数转换为小时、分钟
    final totalSeconds = widget.skill.totalTime;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    _hoursController = TextEditingController(text: hours.toString());
    _minutesController = TextEditingController(text: minutes.toString());
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // 启动动画
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fadeAnimationController.forward();
        _slideAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  // 保存编辑
  void _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('技能名称不能为空');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 计算总秒数
      final hours = int.tryParse(_hoursController.text) ?? 0;
      final minutes = int.tryParse(_minutesController.text) ?? 0;
      final totalSeconds = hours * 3600 + minutes * 60;

      // 创建更新后的技能
      final updatedSkill = Skill(
        id: widget.skill.id.isNotEmpty ? widget.skill.id : Uuid().v4(),
        name: _nameController.text.trim(),
        totalTime: totalSeconds,
        iconCodePoint: _selectedIconCodePoint,
        progress: widget.skill.progress, // 保持原有进度
        inHallOfGlory: widget.skill.inHallOfGlory,
        iconColor: _selectedIconColor.value,
      );

      // 返回更新结果
      Navigator.of(context).pop({
        'action': 'save',
        'skillIndex': widget.skillIndex,
        'skill': updatedSkill,
      });
    } catch (e) {
      _showErrorSnackBar('保存失败，请重试');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 删除技能
  void _deleteSkill() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除技能"${widget.skill.name}"吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).pop({'action': 'delete', 'skillIndex': widget.skillIndex});
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // 获取格式化的时间显示（时-分）
  String _getFormattedTime() {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  // 获取滑块当前值
  double _getSliderValue() {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final totalSeconds = hours * 3600 + minutes * 60;
    return totalSeconds.toDouble().clamp(0, 72000);
  }

  // 从滑块更新时间
  void _updateTimeFromSlider(double value) {
    final totalSeconds = value.toInt();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    _hoursController.text = hours.toString();
    _minutesController.text = minutes.toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.skillIndex == null ? '添加技能' : '编辑技能'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              // 技能图标选择区域
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.palette,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '选择图标和颜色',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? kTextMainDark
                                : kTextMain,
                          ),
                        ),
                      ],
                    ),
                    initiallyExpanded: false,
                    children: [
                      // 颜色选择器
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: _iconColors.map((color) {
                          final isSelected = _selectedIconColor == color;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedIconColor = color),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 8,
                              ),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(width: 3, color: Colors.black)
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      // 图标选择网格
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: _availableIcons.length,
                        itemBuilder: (context, index) {
                          final icon = _availableIcons[index];
                          final isSelected =
                              _selectedIconCodePoint == icon.codePoint;
                          return GestureDetector(
                            onTap: () => setState(
                              () => _selectedIconCodePoint = icon.codePoint,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _selectedIconColor
                                    : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? kIconBgDark
                                          : kIconBgLight),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? _selectedIconColor
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Icon(
                                icon,
                                color: isSelected
                                    ? Colors.white
                                    : _selectedIconColor,
                                size: 24,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 技能名称编辑区域
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '技能名称',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? kTextMainDark
                                  : kTextMain,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: '输入技能名称',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              // 时间编辑区域
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '累计时间',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? kTextMainDark
                                  : kTextMain,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 时间显示区域
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? kIconBgDark
                              : kIconBgLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getFormattedTime(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? kTextMainDark
                                    : kTextMain,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 滑块控制
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '快速调整',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? kTextMainDark
                                      : kTextMain,
                                ),
                              ),
                              Text(
                                '0-20小时',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? kTextSubDark
                                      : kTextSub,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              inactiveTrackColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? kIconBgDark
                                  : kIconBgLight,
                              thumbColor: Theme.of(context).colorScheme.primary,
                              overlayColor: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2),
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
                            ),
                            child: Slider(
                              value: _getSliderValue(),
                              min: 0,
                              max: 72000, // 20小时 = 72000秒
                              divisions: 240, // 每5分钟一个刻度
                              onChanged: (value) {
                                _updateTimeFromSlider(value);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 精确输入区域
                      Text(
                        '精确调整',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? kTextMainDark
                              : kTextMain,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _hoursController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: '小时',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _minutesController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: '分钟',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 底部按钮区域
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _deleteSkill,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '删除技能',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveChanges,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  '保存更改',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 恢复底部“完成技能并移入荣耀殿堂”按钮
              // SliverToBoxAdapter(
              //   child: Container(
              //     margin: const EdgeInsets.all(16),
              //     child: ElevatedButton.icon(
              //       icon: const Icon(Icons.emoji_events, color: Colors.amber),
              //       label: const Text('完成技能并移入荣耀殿堂'),
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.amber,
              //         foregroundColor: Colors.white,
              //         minimumSize: const Size.fromHeight(44),
              //       ),
              //       onPressed: () async {
              //         // 保存技能并返回，inHallOfGlory 设为 true
              //         final updatedSkill = Skill(
              //           name: _nameController.text,
              //           totalTime: _getSliderValue().toInt(),
              //           icon: _selectedIcon,
              //           progress: widget.skill.progress,
              //           inHallOfGlory: true,
              //         );
              //         Navigator.of(context).pop({
              //           'action': 'save',
              //           'skillIndex': widget.skillIndex,
              //           'skill': updatedSkill,
              //         });
              //       },
              //     ),
              //   ),
              // ),

              // 底部间距
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}
