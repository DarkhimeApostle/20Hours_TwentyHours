import 'package:flutter/material.dart';
import 'package:TwentyHours/screens/home_screen.dart';
import 'package:TwentyHours/screens/generic_timer_screen.dart';
import 'package:TwentyHours/screens/instruction_screen.dart';
import '../main.dart';
import 'package:TwentyHours/screens/about_screen.dart';
import 'package:TwentyHours/screens/settings_screen.dart';
import 'package:TwentyHours/screens/statistics_screen.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TwentyHours/models/skill_model.dart';
import 'package:TwentyHours/screens/edit_skill_screen.dart';
import 'hall_of_glory_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:TwentyHours/utils/config_exporter.dart';
import 'dart:async';

// 主页面专属AppBar title组件
class MainAppBarTitle extends StatelessWidget {
  final String? avatarPath;
  final String userName;
  const MainAppBarTitle({
    super.key,
    required this.avatarPath,
    required this.userName,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 用户自定义头像展示框
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: avatarPath != null && avatarPath!.isNotEmpty
                ? Image.file(
                    File(avatarPath!),
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? kPrimaryColor.withOpacity(0.85)
                              : kPrimaryColor,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 16,
                        ),
                      );
                    },
                  )
                : Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? kPrimaryColor.withOpacity(0.85)
                          : kPrimaryColor,
                    ),
                    child: Icon(Icons.person, color: Colors.white, size: 16),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          userName.isNotEmpty ? userName : '开狼',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? kTextMainDark
                : kTextMain,
          ),
        ),
      ],
    );
  }
}

// 主页面专属Drawer组件
class MainDrawer extends StatelessWidget {
  final String userName;
  final String? avatarPath;
  final String? drawerBgPath;
  final VoidCallback onSettingsTap;
  final VoidCallback? onRefreshHome; // 添加刷新回调
  const MainDrawer({
    super.key,
    required this.userName,
    required this.avatarPath,
    required this.drawerBgPath,
    required this.onSettingsTap,
    this.onRefreshHome, // 添加刷新回调参数
  });
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).cardColor,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: drawerBgPath != null && drawerBgPath!.isNotEmpty
                ? FileImage(File(drawerBgPath!))
                : const AssetImage('assets/images/drawer_bg.jpg')
                      as ImageProvider,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.1),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          children: [
            // 中间空白区域 - 让背景图片充分展示
            Expanded(child: Container()),

            // 底部功能按钮区域 - 大幅下移
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                children: [
                  // 荣耀殿堂按钮
                  _buildActionButton(
                    context,
                    icon: Icons.star,
                    iconColor: Colors.amber,
                    label: '荣耀殿堂',
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HallOfGloryScreen(),
                        ),
                      );
                      onRefreshHome?.call();
                    },
                  ),

                  const SizedBox(height: 8),

                  // 统计按钮
                  _buildActionButton(
                    context,
                    icon: Icons.analytics,
                    iconColor: Theme.of(context).brightness == Brightness.dark
                        ? kTextMainDark
                        : kPrimaryColor,
                    label: '技能统计',
                    onTap: () {
                      Navigator.pop(context); // 关闭抽屉
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StatisticsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // 设置按钮
                  _buildActionButton(
                    context,
                    icon: Icons.settings,
                    iconColor: Theme.of(context).brightness == Brightness.dark
                        ? kTextMainDark
                        : kPrimaryColor,
                    label: '设置',
                    onTap: onSettingsTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建操作按钮
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextMainDark
                    : kTextMain,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 应用主页面，包含底部导航栏和页面切换逻辑
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

// RootScreen的状态管理
class _RootScreenState extends State<RootScreen> with TickerProviderStateMixin {
  // 当前选中的底部导航栏索引
  int _selectedIndex = 0;

  // 用于操作HomeScreen的方法
  final GlobalKey<HomeScreenState> _homeScreenKey =
      GlobalKey<HomeScreenState>();

  // 添加Scaffold的GlobalKey
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 页面列表 - 使用IndexedStack保持状态
  late final List<Widget> _pages;

  // 跳转到设置页面并监听返回结果
  Future<void> _onSettingsTapped() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    // 设置页面返回后刷新头像、背景和用户名
    await _refreshUserImages();
    await _loadUserName();
  }

  // 动画控制器
  late AnimationController _animationController;
  late AnimationController _stripeAnimationController;

  // 条纹动画的偏移量
  final double _stripeOffset = 0.0;

  // 条纹间距
  final double stripeSpacing = 10.0;

  String? _avatarPath;
  String? _drawerBgPath;
  String _userName = '开狼';
  bool _isDataLoaded = false;
  Timer? _autoExportTimer; // 自动导出定时器

  // 初始化页面列表
  @override
  void initState() {
    super.initState();

    // 初始化页面列表 - 只创建一次，避免重新创建
    _pages = [
      HomeScreen(key: _homeScreenKey),
      const InstructionScreen(),
      const AboutScreen(),
    ];

    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 条纹动画控制器（持续循环）
    _stripeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 立即启动动画，避免延迟
    if (mounted) {
      // 只在主页面时启动动画
      _controlAnimationsForPage(_selectedIndex);
    }

    // 启动10秒后自动导出配置
    _startAutoExportTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在didChangeDependencies中加载用户数据，避免阻塞AppBar渲染
    _loadUserImages();
    _loadUserName();
  }

  // 添加页面激活监听
  @override
  void didUpdateWidget(RootScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当widget更新时，如果当前在主界面，刷新数据
    if (_selectedIndex == 0) {
      _homeScreenKey.currentState?.loadSkills();
    }
  }

  // 加载自定义头像和背景路径
  Future<void> _loadUserImages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarPath = prefs.getString('user_avatar_path');
      _drawerBgPath = prefs.getString('drawer_bg_path');
      _isDataLoaded = true;
    });
  }

  // 刷新用户头像和背景
  Future<void> _refreshUserImages() async {
    await _loadUserImages();
  }

  // 加载用户名
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? '开狼';
      _isDataLoaded = true;
    });
  }

  // 切换底部导航栏页面
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // 如果切换到主界面，刷新数据
    if (index == 0) {
      _homeScreenKey.currentState?.loadSkills();
    }

    // 根据页面切换控制动画
    _controlAnimationsForPage(index);
  }

  // 根据页面控制动画
  void _controlAnimationsForPage(int pageIndex) {
    // 只在主页面（index 0）时启动根页面的动画
    if (pageIndex == 0) {
      if (!_animationController.isAnimating) {
        _animationController.forward();
      }
      if (!_stripeAnimationController.isAnimating) {
        _stripeAnimationController.repeat();
      }
    } else {
      // 其他页面时停止根页面的动画
      _animationController.stop();
      _stripeAnimationController.stop();
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
          ),
          skillIndex: null,
        ),
      ),
    );
    if (result != null && result['action'] == 'save') {
      _homeScreenKey.currentState?.setState(() {
        _homeScreenKey.currentState?.skills.add(result['skill']);
      });
      _homeScreenKey.currentState?.saveSkills(); // 调用公有方法
    }
  }

  // 跳转到通用计时页面
  void _onTimerButtonPressed() async {
    // 跳转计时页并传递技能列表
    final skills = _homeScreenKey.currentState?.skills;
    if (skills == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GenericTimerScreen(),
        settings: RouteSettings(arguments: skills),
      ),
    );
    // 计时页返回后处理归属结果
    if (result is Map &&
        result['skillIndex'] != null &&
        result['duration'] != null) {
      final int idx = result['skillIndex'];
      final int seconds = result['duration'];
      _homeScreenKey.currentState?.addTimeToSkill(idx, seconds);
    }
  }

  Widget buildUserAvatar(String? avatarPath, {double radius = 40}) {
    if (avatarPath != null && avatarPath.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: FileImage(File(avatarPath)),
        radius: radius,
        onBackgroundImageError: (exception, stackTrace) {
          // 图片加载失败时使用默认头像
        },
      );
    } else {
      return CircleAvatar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? kPrimaryColor.withOpacity(0.85)
            : kPrimaryColor,
        radius: radius,
        child: Icon(Icons.person, color: Colors.white, size: radius),
      );
    }
  }

  // 构建页面UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // 添加key
      appBar: AppBar(
        title: _selectedIndex == 0
            ? MainAppBarTitle(
                avatarPath: _isDataLoaded ? _avatarPath : null,
                userName: _userName,
              )
            : (_selectedIndex == 1
                  ? const Text('使用说明')
                  : _selectedIndex == 2
                  ? const Text('关于')
                  : const Text('TwentyHours')),
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _onAddSkillPressed,
                  tooltip: '添加新技能',
                ),
              ]
            : null,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        toolbarHeight: _selectedIndex == 0 ? 80 : kToolbarHeight,
      ),

      // 页面内容和悬浮按钮
      body: _selectedIndex == 0
          ? GestureDetector(
              onHorizontalDragEnd: (details) {
                // 检测右滑手势
                if (details.primaryVelocity! > 0) {
                  _scaffoldKey.currentState?.openDrawer();
                }
              },
              child: Stack(
                children: [
                  // 主页面使用IndexedStack保持状态
                  IndexedStack(index: 0, children: [_pages[0]]),
                  // 只在计时页面显示悬浮按钮
                  AnimatedOpacity(
                    opacity: _selectedIndex == 0 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      transform: Matrix4.translationValues(
                        0,
                        _selectedIndex == 0 ? 0 : 50,
                        0,
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? kButtonDark
                                  : kButtonLight,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(
                                    31,
                                    255,
                                    255,
                                    255,
                                  ),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: RawMaterialButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              onPressed: _onTimerButtonPressed,
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? kIconBgDark
                                      : kIconBgLight,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(18),
                                child: Icon(
                                  Icons.timer_outlined,
                                  size: 43,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? kTextMainDark
                                      : kPrimaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : _selectedIndex == 1
          ? const InstructionScreen() // 说明界面直接创建新实例
          : const AboutScreen(), // 关于界面直接创建新实例

      drawer: _selectedIndex == 0
          ? MainDrawer(
              userName: _userName,
              avatarPath: _avatarPath,
              drawerBgPath: _drawerBgPath,
              onSettingsTap: () async {
                await _onSettingsTapped();
                Navigator.pop(context);
              },
              onRefreshHome: () {
                _homeScreenKey.currentState?.loadSkills();
              },
            )
          : null,

      // 底部导航栏，切换不同页面
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? kCardDark
              : kCardLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kIconBgDark
                      : kIconBgLight,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.timer,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kTextMainDark
                      : kPrimaryColor,
                ),
              ),
              label: '计时',
            ),

            BottomNavigationBarItem(
              icon: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kIconBgDark
                      : kIconBgLight,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.book,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kTextMainDark
                      : kPrimaryColor,
                ),
              ),
              label: '说明',
            ),
            BottomNavigationBarItem(
              icon: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kIconBgDark
                      : kIconBgLight,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: Transform.rotate(
                  angle: 45 * 3.14159 / 180, // 45度转换为弧度
                  child: Icon(
                    Icons.flight,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? kTextMainDark
                        : kPrimaryColor,
                  ),
                ),
              ),
              label: '关于',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: kTextSub,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
        ),
      ),
    );
  }

  // 启动自动导出定时器
  void _startAutoExportTimer() {
    _autoExportTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        ConfigExporter.autoExportConfig();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stripeAnimationController.dispose();
    _autoExportTimer?.cancel(); // 取消自动导出定时器
    super.dispose();
  }
}
