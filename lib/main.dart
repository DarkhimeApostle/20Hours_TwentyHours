import 'package:TwentyHours/screens/root_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:TwentyHours/secrets.dart';
import 'package:permission_handler/permission_handler.dart';

// 更深的现代清新风格主色
const Color kPrimaryColor = Color(0xFF2563EB); // 深蓝
const Color kBackgroundLight = Color(0xFFE5EAF2); // 深灰蓝背景
const Color kCardLight = Color(0xFFF6F8FC); // 卡片淡灰蓝
const Color kButtonLight = Color(0xFFD0E0FF); // 按钮深蓝灰
const Color kIconBgLight = Color(0xFFD0E0FF); // 图标圆背景
const Color kTextMain = Color(0xFF1A2233); // 主文本
const Color kTextSub = Color(0xFF6B7A90); // 辅助文本

const Color kBackgroundDark = Color(0xFF181F2A); // 深色背景
const Color kCardDark = Color(0xFF232B3B); // 深色卡片
const Color kButtonDark = Color(0xFF3973E5); // 深色按钮
const Color kIconBgDark = Color(0xFF2A3550); // 深色图标圆背景
const Color kTextMainDark = Color(0xFFF6F8FC); // 深色主文本
const Color kTextSubDark = Color(0xFFA0AEC0); // 深色辅助文本

// 应用程序入口
void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化Bugly（异步执行，不阻塞启动）
  FlutterBugly.init(
    androidAppId: 'ae931cda6f',
    appKey: buglyAppKey,
    debugMode: true,
  );

  // 异步请求存储权限，不阻塞启动
  Permission.storage.request();

  runApp(const TwentyHours());
}

// 应用主组件，负责全局主题和首页导航
class TwentyHours extends StatelessWidget {
  const TwentyHours({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TwentyHours',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: kPrimaryColor,
          background: kBackgroundLight,
          surface: kCardLight,
        ),
        scaffoldBackgroundColor: kBackgroundLight,
        cardColor: kCardLight,
        appBarTheme: AppBarTheme(
          backgroundColor: kBackgroundLight,
          elevation: 0,
          iconTheme: const IconThemeData(color: kPrimaryColor),
          titleTextStyle: const TextStyle(
            color: kTextMain,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        cardTheme: CardThemeData(
          color: kCardLight,
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kPrimaryColor,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kButtonLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
        iconTheme: const IconThemeData(size: 28, color: kPrimaryColor),
        dividerColor: Colors.grey.shade200,
        fontFamily: 'sans-serif',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: kButtonDark,
          background: kBackgroundDark,
          surface: kCardDark,
        ),
        scaffoldBackgroundColor: kBackgroundDark,
        cardColor: kCardDark,
        appBarTheme: AppBarTheme(
          backgroundColor: kBackgroundDark,
          elevation: 0,
          iconTheme: const IconThemeData(color: kButtonDark),
          titleTextStyle: const TextStyle(
            color: kTextMainDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kButtonDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        cardTheme: CardThemeData(
          color: kCardDark,
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kButtonDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kButtonDark,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kIconBgDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
        iconTheme: const IconThemeData(size: 28, color: kButtonDark),
        dividerColor: Colors.grey.shade800,
        fontFamily: 'sans-serif',
      ),
      themeMode: ThemeMode.system, // 跟随系统深浅色
      debugShowCheckedModeBanner: false,
      home: const RootScreen(),
    );
  }
}
