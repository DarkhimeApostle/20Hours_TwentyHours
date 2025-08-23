import 'package:flutter/material.dart';
import 'package:t20/screens/home_screen.dart';
import 'package:t20/screens/generic_timer_screen.dart';
import 'package:t20/screens/instruction_screen.dart';
import '../main.dart';
import 'package:t20/screens/about_screen.dart';
import 'package:t20/screens/settings_screen.dart';
import 'package:t20/screens/statistics_screen.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skill_model.dart';
import '../screens/edit_skill_screen.dart';
import 'hall_of_glory_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:t20/utils/config_exporter.dart';
import '../utils/app_state_notifier.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

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
                color: Colors.black.withValues(alpha: 0.1),
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
                              ? kPrimaryColor.withValues(alpha: 0.85)
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
                          ? kPrimaryColor.withValues(alpha: 0.85)
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
            image: _getSafeImageProvider(),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.1),
              BlendMode.darken,
            ),
            onError: (exception, stackTrace) {
              print('侧边栏背景图片加载失败: $exception');
            },
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
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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

  // Helper to get a safe ImageProvider for DecorationImage
  ImageProvider _getSafeImageProvider() {
    if (drawerBgPath != null && drawerBgPath!.isNotEmpty) {
      try {
        final file = File(drawerBgPath!);
        if (file.existsSync()) {
          // 检查文件是否为空
          final fileSize = file.lengthSync();
          if (fileSize > 0) {
            print('使用自定义背景图片: $drawerBgPath (大小: ${fileSize} 字节)');
            return FileImage(file);
          } else {
            print('自定义背景图片文件为空: $drawerBgPath. 使用默认背景.');
            return const AssetImage('assets/images/drawer_bg.jpg')
                as ImageProvider;
          }
        } else {
          print('自定义抽屉背景文件不存在: $drawerBgPath. 使用默认背景.');
          return const AssetImage('assets/images/drawer_bg.jpg')
              as ImageProvider;
        }
      } catch (e) {
        print('自定义抽屉背景图片加载失败: $e. 使用默认背景.');
        return const AssetImage('assets/images/drawer_bg.jpg') as ImageProvider;
      }
    } else {
      print('使用默认背景图片: assets/images/drawer_bg.jpg');
      return const AssetImage('assets/images/drawer_bg.jpg') as ImageProvider;
    }
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
    if (mounted) {
      await _refreshUserImages();
      await _loadUserName();
    }
  }

  // 动画控制器
  late AnimationController _animationController;
  late AnimationController _stripeAnimationController;

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

    // 监听应用状态变化
    AppStateNotifier().addListener(_onAppStateChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在didChangeDependencies中加载用户数据，避免阻塞AppBar渲染
    if (!_isDataLoaded) {
      _loadUserImages();
      _loadUserName();
    }
  }

  // 应用状态变化处理
  void _onAppStateChanged() {
    // 只在必要时刷新数据，避免频繁重置背景图片设置
    _loadUserName().then((_) {
      if (mounted) {
        setState(() {
          // 强制重建UI以更新头像和侧边栏
        });
        // 刷新主页面技能数据
        if (_selectedIndex == 0) {
          _homeScreenKey.currentState?.loadSkills();
        }
      }
    });
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
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _avatarPath = prefs.getString('user_avatar_path');
          _drawerBgPath = prefs.getString('drawer_bg_path');
        });

        // 立即设置数据加载完成，不等待背景图片验证
        if (mounted) {
          setState(() {
            _isDataLoaded = true;
          });
        }

        // 异步验证并保护背景图片路径（不阻塞UI）
        _validateAndProtectDrawerBgPath();
      }
    } catch (e) {
      print('加载用户图片失败: $e');
      // 即使出错也要设置数据加载完成
      if (mounted) {
        setState(() {
          _isDataLoaded = true;
        });
      }
    }
  }

  // 验证并保护侧边栏背景图片路径
  Future<void> _validateAndProtectDrawerBgPath() async {
    if (_drawerBgPath == null || _drawerBgPath!.isEmpty) {
      return;
    }

    try {
      final file = File(_drawerBgPath!);
      if (file.existsSync()) {
        print('自定义背景图片路径有效: $_drawerBgPath');
        // 确保背景图片在安全位置
        await _ensureBackgroundImageSafety();
        // 创建额外备份
        await _createBackgroundBackup();
        return;
      }

      print('自定义背景图片文件不存在: $_drawerBgPath');

      // 尝试从多个位置恢复背景图片
      final recovered = await _attemptBackgroundRecovery();
      if (!recovered) {
        print('无法恢复背景图片，保留用户设置');
        // 创建一个默认的背景图片副本
        await _createDefaultBackgroundCopy();
      }
    } catch (e) {
      print('验证背景路径时出错: $e');
    }
  }

  // 创建背景图片的额外备份
  Future<void> _createBackgroundBackup() async {
    try {
      if (_drawerBgPath == null || _drawerBgPath!.isEmpty) return;

      final sourceFile = File(_drawerBgPath!);
      if (!await sourceFile.exists()) return;

      final appDir = await getApplicationDocumentsDirectory();
      final backupPath = '${appDir.path}/t20_backup';

      // 创建多个备份副本
      final backupFiles = [
        '$backupPath/drawer_bg_backup1.jpg',
        '$backupPath/drawer_bg_backup2.jpg',
        '$backupPath/drawer_bg_backup3.jpg',
      ];

      for (final backupFile in backupFiles) {
        try {
          await sourceFile.copy(backupFile);
        } catch (e) {
          print('创建备份失败 $backupFile: $e');
        }
      }

      print('背景图片备份创建完成');
    } catch (e) {
      print('创建背景图片备份时出错: $e');
    }
  }

  // 尝试从多个位置恢复背景图片
  Future<bool> _attemptBackgroundRecovery() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final backupPath = '${appDir.path}/t20_backup';

      // 尝试从备份文件恢复
      final backupFiles = [
        '$backupPath/drawer_bg_backup1.jpg',
        '$backupPath/drawer_bg_backup2.jpg',
        '$backupPath/drawer_bg_backup3.jpg',
        '$backupPath/drawer_bg.jpg',
      ];

      for (final backupFile in backupFiles) {
        final file = File(backupFile);
        if (await file.exists()) {
          print('找到备份文件，正在恢复: $backupFile');

          // 恢复到主文件位置
          final mainPath = '$backupPath/drawer_bg.jpg';
          await file.copy(mainPath);

          // 更新路径设置
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('drawer_bg_path', mainPath);

          if (mounted) {
            setState(() {
              _drawerBgPath = mainPath;
            });
          }

          print('背景图片恢复成功: $mainPath');
          return true;
        }
      }

      print('未找到可用的备份文件');
      return false;
    } catch (e) {
      print('恢复背景图片时出错: $e');
      return false;
    }
  }

  // 创建默认背景图片的副本
  Future<void> _createDefaultBackgroundCopy() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final backupPath = '${appDir.path}/t20_backup';
      final backupDir = Directory(backupPath);

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // 从assets复制默认背景图片
      final byteData = await rootBundle.load('assets/images/drawer_bg.jpg');
      final buffer = byteData.buffer;
      final defaultBgPath = '$backupPath/drawer_bg.jpg';

      await File(defaultBgPath).writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );

      // 更新设置
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('drawer_bg_path', defaultBgPath);

      if (mounted) {
        setState(() {
          _drawerBgPath = defaultBgPath;
        });
      }

      print('创建默认背景图片副本: $defaultBgPath');
    } catch (e) {
      print('创建默认背景图片副本时出错: $e');
    }
  }

  // 确保背景图片在安全位置
  Future<void> _ensureBackgroundImageSafety() async {
    try {
      // 如果背景图片不在应用内部的安全目录，复制到安全位置
      if (!_drawerBgPath!.contains('t20_backup')) {
        print('检测到外部背景图片，正在复制到安全位置');
        await _copyBackgroundToSafeLocation();
      }
    } catch (e) {
      print('确保背景图片安全时出错: $e');
    }
  }

  // 复制背景图片到安全位置
  Future<void> _copyBackgroundToSafeLocation() async {
    try {
      final sourceFile = File(_drawerBgPath!);
      if (!await sourceFile.exists()) {
        print('源背景图片文件不存在，跳过复制');
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final safePath = '${appDir.path}/t20_backup';
      final safeDir = Directory(safePath);

      if (!await safeDir.exists()) {
        await safeDir.create(recursive: true);
      }

      final safeFilePath = '$safePath/drawer_bg.jpg';
      final safeFile = File(safeFilePath);

      // 复制文件
      await sourceFile.copy(safeFilePath);

      // 更新路径设置
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('drawer_bg_path', safeFilePath);

      if (mounted) {
        setState(() {
          _drawerBgPath = safeFilePath;
        });
      }

      print('背景图片已复制到安全位置: $safeFilePath');
    } catch (e) {
      print('复制背景图片到安全位置时出错: $e');
    }
  }

  // 刷新用户头像和背景
  Future<void> _refreshUserImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _avatarPath = prefs.getString('user_avatar_path');
          _drawerBgPath = prefs.getString('drawer_bg_path');
        });
      }
    } catch (e) {
      print('刷新用户图片失败: $e');
    }
  }

  // 加载用户名
  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _userName = prefs.getString('user_name') ?? '开狼';
          // _isDataLoaded 现在在 _loadUserImages 中设置
        });
      }
    } catch (e) {
      print('加载用户名失败: $e');
      if (mounted) {
        setState(() {
          _userName = '开狼';
          // _isDataLoaded 现在在 _loadUserImages 中设置
        });
      }
    }
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
            ? kPrimaryColor.withValues(alpha: 0.85)
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
        title: _selectedIndex == 0 && _isDataLoaded
            ? MainAppBarTitle(avatarPath: _avatarPath, userName: _userName)
            : (_selectedIndex == 0 && !_isDataLoaded
                  ? const Text('TwentyHours')
                  : _selectedIndex == 1
                  ? const Text('什么是20小时理论')
                  : _selectedIndex == 2
                  ? const Text('关于')
                  : const Text('T20')),
        centerTitle: _selectedIndex == 1, // 当显示"什么是20小时理论"时居中
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

      drawer: _selectedIndex == 0 && _isDataLoaded
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
              label: '使用说明',
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
    _autoExportTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) {
        ConfigExporter.autoExportConfig();
      } else {}
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stripeAnimationController.dispose();
    if (_autoExportTimer != null) {
      _autoExportTimer!.cancel();
    }
    AppStateNotifier().removeListener(_onAppStateChanged); // 移除监听器
    super.dispose();
  }
}
