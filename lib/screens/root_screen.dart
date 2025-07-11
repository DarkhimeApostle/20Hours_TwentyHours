import 'package:flutter/material.dart';
import 'package:TwentyHours/screens/home_screen.dart';
import 'package:TwentyHours/screens/add_skill_screen.dart';
import 'package:TwentyHours/screens/generic_timer_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('统计页面（待开发）'));
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('设置页面（待开发）'));
  }
}

// --- RootScreen Widget 定义 ---
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

// --- RootScreen State 定义 ---
class _RootScreenState extends State<RootScreen> {
  // 1. 状态变量
  int _selectedIndex = 0;
  final GlobalKey<HomeScreenState> _homeScreenKey =
      GlobalKey<HomeScreenState>();
  late final List<Widget> _widgetOptions;

  // 2. 初始化
  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomeScreen(key: _homeScreenKey),
      const StatsScreen(),
      const SettingsScreen(),
    ];
  }

  // 3. 核心逻辑方法
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onAddSkillPressed() async {
    final newSkillName = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const AddSkillScreen()),
    );
    if (newSkillName != null && newSkillName.isNotEmpty) {
      _homeScreenKey.currentState?.addSkill(newSkillName);
    }
  }

  void _onTimerButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GenericTimerScreen()),
    );
  }

  // 4. UI 构建
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'α计时' : (_selectedIndex == 1 ? '统计' : '设置'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _onAddSkillPressed,
            tooltip: '添加新技能',
          ),
        ],
      ),
      body: _widgetOptions[_selectedIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text("开狼"),
              accountEmail: const Text("linziyan@example.com"),
              currentAccountPicture: CircleAvatar(
                //child: ClipOval(child: Image.asset('assets/images/avatar.png')),
              ),
              decoration: const BoxDecoration(
                color: Colors.blue,
                //image: DecorationImage(
                 // image: AssetImage('assets/images/drawer_bg.jpg'),
                 // fit: BoxFit.cover,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('计时'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('统计'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('设置'),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: '计时'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '统计'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: _onTimerButtonPressed,
        child: const Icon(Icons.timer_outlined, size: 48),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
