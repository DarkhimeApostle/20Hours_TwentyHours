import 'package:flutter/material.dart';
import 'package:TwentyHours/screens/home_screen.dart';
import 'package:TwentyHours/screens/generic_timer_screen.dart';
import 'package:TwentyHours/screens/promotion_screen.dart';
import '../main.dart';
import 'package:TwentyHours/screens/settings_screen.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TwentyHours/models/skill_model.dart';
import 'package:TwentyHours/screens/edit_skill_screen.dart';
import 'hall_of_glory_screen.dart';
import 'package:uuid/uuid.dart';

// 主页面专属AppBar title组件
class MainAppBarTitle extends StatelessWidget {
  final String? avatarPath;
  final String userName;
  const MainAppBarTitle({
    Key? key,
    required this.avatarPath,
    required this.userName,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).brightness == Brightness.dark
                ? kPrimaryColor.withOpacity(0.85)
                : kPrimaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:
              (avatarPath != null &&
                  avatarPath!.isNotEmpty &&
                  File(avatarPath!).existsSync())
              ? CircleAvatar(
                  backgroundImage: FileImage(File(avatarPath!)),
                  radius: 20,
                )
              : CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              userName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextMainDark
                    : kTextMain,
              ),
            ),
            Text(
              'linziyan@example.com',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextSubDark
                    : kTextSub,
              ),
            ),
          ],
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
  final VoidCallback onStatsTap;
  final VoidCallback onSettingsTap;
  final VoidCallback? onRefreshHome; // 添加刷新回调
  const MainDrawer({
    Key? key,
    required this.userName,
    required this.avatarPath,
    required this.drawerBgPath,
    required this.onStatsTap,
    required this.onSettingsTap,
    this.onRefreshHome, // 添加刷新回调参数
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).cardColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: const Text(
              "linziyan@example.com",
              style: TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child:
                  (avatarPath != null &&
                      avatarPath!.isNotEmpty &&
                      File(avatarPath!).existsSync())
                  ? CircleAvatar(
                      backgroundImage: FileImage(File(avatarPath!)),
                      radius: 40,
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(Icons.person, color: Colors.white, size: 40),
                    ),
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                image:
                    drawerBgPath != null &&
                        drawerBgPath!.isNotEmpty &&
                        File(drawerBgPath!).existsSync()
                    ? FileImage(File(drawerBgPath!))
                    : const AssetImage('assets/images/drawer_bg.jpg')
                          as ImageProvider,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.35),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: const Text('荣耀殿堂'),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HallOfGloryScreen(),
                ),
              );
              // 从荣耀殿堂返回后，刷新主界面数据
              onRefreshHome?.call();
            },
          ),
          ListTile(
            leading: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? kIconBgDark
                    : kIconBgLight,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.bar_chart,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextMainDark
                    : kPrimaryColor,
              ),
            ),
            title: const Text('统计'),
            onTap: onStatsTap,
          ),
          ListTile(
            leading: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? kIconBgDark
                    : kIconBgLight,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.settings,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextMainDark
                    : kPrimaryColor,
              ),
            ),
            title: const Text('设置'),
            onTap: onSettingsTap,
          ),
        ],
      ),
    );
  }
}

// 统计页面，暂未实现具体功能
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('统计页面（待开发）'));
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
    // 移除自动刷新逻辑，用户需要手动重启应用
  }

  // 动画控制器
  late AnimationController _animationController;
  late AnimationController _stripeAnimationController;

  // 条纹动画的偏移量
  double _stripeOffset = 0.0;

  // 条纹间距
  final double stripeSpacing = 10.0;

  String? _avatarPath;
  String? _drawerBgPath;
  String _userName = '开狼';

  // 初始化页面列表
  @override
  void initState() {
    super.initState();

    // 初始化页面列表 - 只创建一次，避免重新创建
    _pages = [
      HomeScreen(key: _homeScreenKey),
      const PromotionScreen(),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onSettingsTapped,
        child: const SettingsScreen(),
      ),
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

    // 启动动画
    _animationController.forward();
    _stripeAnimationController.repeat(); // 条纹动画持续循环
    _loadUserImages();
    _loadUserName();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserImages();
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
    });
  }

  // 加载用户名
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? '开狼';
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
    if (avatarPath != null &&
        avatarPath.isNotEmpty &&
        File(avatarPath).existsSync()) {
      return CircleAvatar(
        backgroundImage: FileImage(File(avatarPath)),
        radius: radius,
      );
    } else {
      return CircleAvatar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? kPrimaryColor.withOpacity(0.85)
            : kPrimaryColor,
        child: Icon(Icons.person, color: Colors.white, size: radius),
        radius: radius,
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
            ? MainAppBarTitle(avatarPath: _avatarPath, userName: _userName)
            : (_selectedIndex == 1
                  ? const Text('统计')
                  : _selectedIndex == 2
                  ? const Text('设置')
                  : null),
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
                  // 使用IndexedStack保持页面状态，避免重新创建
                  IndexedStack(index: _selectedIndex, children: _pages),
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
                                  color: Colors.black12,
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
          : Stack(
              children: [
                // 使用IndexedStack保持页面状态，避免重新创建
                IndexedStack(index: _selectedIndex, children: _pages),
              ],
            ),

      drawer: _selectedIndex == 0
          ? MainDrawer(
              userName: _userName,
              avatarPath: _avatarPath,
              drawerBgPath: _drawerBgPath,
              onStatsTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
              onSettingsTap: () async {
                await _onSettingsTapped();
                _onItemTapped(2);
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
                  Icons.bar_chart,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kTextMainDark
                      : kPrimaryColor,
                ),
              ),
              label: '统计',
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
                  Icons.settings,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kTextMainDark
                      : kPrimaryColor,
                ),
              ),
              label: '设置',
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
}
