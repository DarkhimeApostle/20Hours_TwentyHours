// 引入依赖文件

import 'package:TwentyHours/screens/home_screen.dart';
import 'package:flutter/material.dart';

import 'package:TwentyHours/screens/generic_timer_screen.dart';

// --- 两个临时的、空白的占位页面 ---

// 统计页面
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('这里是统计页面')));
  }
}

// 设置页面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('这里是设置页面')));
  }
}
// --- 占位页面创建结束 ---

// ===========================================================================
// RootScreen: 应用根页面，管理全局UI框架和导航
// ===========================================================================
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  // --- 1. 状态变量 ---

  // 用于记录当前选中的是哪个页面的索引 (0: 计时, 1: 统计, 2: 设置)
  int _selectedIndex = 0;

  // 定义一个页面列表，与我们的导航入口一一对应
  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(), // 索引 0
    const StatsScreen(), // 索引 1
    const SettingsScreen(), // 索引 2
  ];

  // --- 2. 核心逻辑 ---
  // 当侧边栏的某个入口被点击时，这个方法会被调用
  void _onItemTapped(int index) {
    // 使用 setState 来更新我们选中的索引
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- 3. UI构建 ---
  @override
  Widget build(BuildContext context) {
    // 返回一个 Scaffold，作为整个应用的“骨架”
    return Scaffold(
      // 全局的顶栏 AppBar
      appBar: AppBar(
        // AppBar 的标题，会根据当前选中的页面动态改变
        title: Text(
          _selectedIndex == 0 ? 'α计时' : (_selectedIndex == 1 ? '统计' : '设置'),
        ),
      ),

      // 全局的侧边栏 Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text(
                "开狼 (林子琰)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text("kailang@example.dev"),
              currentAccountPicture: CircleAvatar(
                child: Text("K", style: TextStyle(fontSize: 40.0)),
              ),
              decoration: BoxDecoration(color: Color(0xFF2C3E50)),
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('计时'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context); // 关闭侧边栏
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_outlined),
              title: const Text('统计'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('设置'),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      // 页面的主体内容，会根据 _selectedIndex 动态地从列表中选择
      body: _widgetOptions.elementAt(_selectedIndex),

      // 悬浮操作按钮
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          // 跳转到“添加技能”页面
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const GenericTimerScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),

      // 悬浮按钮的位置:居中浮动
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
