import 'package:flutter/material.dart';
import 'package:TwentyHours/screens/home_screen.dart';
import 'package:TwentyHours/screens/add_skill_screen.dart';
import 'package:TwentyHours/screens/generic_timer_screen.dart';
import 'package:TwentyHours/screens/promotion_screen.dart';
import '../main.dart';

// 统计页面，暂未实现具体功能
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('统计页面（待开发）'));
  }
}

// 设置页面，暂未实现具体功能
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('设置页面（待开发）'));
  }
}

// 应用主页面，包含底部导航栏和页面切换逻辑
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

// RootScreen的状态管理
class _RootScreenState extends State<RootScreen> {
  // 当前选中的底部导航栏索引
  int _selectedIndex = 0;

  // 用于操作HomeScreen的方法
  final GlobalKey<HomeScreenState> _homeScreenKey =
      GlobalKey<HomeScreenState>();

  // 页面列表
  late final List<Widget> _widgetOptions;

  // 初始化页面列表
  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomeScreen(key: _homeScreenKey),
      const PromotionScreen(),
      const SettingsScreen(),
    ];
  }

  // 切换底部导航栏页面
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 跳转到添加技能页面
  void _onAddSkillPressed() async {
    final newSkillName = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const AddSkillScreen()),
    );
    if (newSkillName != null && newSkillName.isNotEmpty) {
      _homeScreenKey.currentState?.addSkill(newSkillName);
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

  // 构建页面UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'α计时' : (_selectedIndex == 1 ? '宣传' : '设置'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _onAddSkillPressed,
            tooltip: '添加新技能',
          ),
        ],
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),

      // 页面内容和悬浮按钮
      body: Stack(
        children: [
          _widgetOptions[_selectedIndex],
          // 只在计时页面显示悬浮按钮
          if (_selectedIndex == 0)
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
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
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
                                Theme.of(context).brightness == Brightness.dark
                                ? kIconBgDark
                                : kIconBgLight,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Icon(
                            Icons.timer_outlined,
                            size: 43,
                            color:
                                Theme.of(context).brightness == Brightness.dark
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

      // 侧边抽屉菜单
      drawer: Drawer(
        backgroundColor: Theme.of(context).cardColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text(
                "开狼",
                style: TextStyle(
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
                child: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? kPrimaryColor.withOpacity(0.85)
                      : kPrimaryColor,
                  child: Icon(Icons.person, color: Colors.white, size: 40),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                image: DecorationImage(
                  image: AssetImage('assets/images/drawer_bg.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.35),
                    BlendMode.darken,
                  ),
                ),
              ),
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
                  Icons.timer,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kTextMainDark
                      : kPrimaryColor,
                ),
              ),
              title: const Text('计时'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
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
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
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
                  Icons.settings,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kTextMainDark
                      : kPrimaryColor,
                ),
              ),
              title: const Text('设置'),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

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
