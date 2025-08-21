import 'package:flutter/material.dart';

/// 应用状态通知器
/// 用于在配置导入后通知整个应用刷新
class AppStateNotifier extends ChangeNotifier {
  static final AppStateNotifier _instance = AppStateNotifier._internal();
  factory AppStateNotifier() => _instance;
  AppStateNotifier._internal();

  /// 通知配置已导入，需要刷新整个应用
  void notifyConfigImported() {
    notifyListeners();
  }

  /// 通知头像已更新
  void notifyAvatarUpdated() {
    notifyListeners();
  }

  /// 通知背景图片已更新
  void notifyBackgroundUpdated() {
    notifyListeners();
  }

  /// 通知用户名已更新
  void notifyUserNameUpdated() {
    notifyListeners();
  }
}
