# 腾讯Bugly集成配置说明

## 概述
本项目已成功集成腾讯Bugly崩溃监控服务，用于收集应用崩溃信息和性能数据。

## 配置步骤

### 1. 获取Bugly应用密钥
1. 登录 [腾讯Bugly官网](https://bugly.qq.com/)
2. 创建新应用或选择现有应用
3. 在应用设置中获取 `App Key`

### 2. 配置应用密钥
1. 打开 `lib/secrets.dart` 文件
2. 将 `YOUR_APP_KEY_HERE` 替换为您的真实App Key：

```dart
const String buglyAppKey = 'your_real_app_key_here';
```

### 3. 安全注意事项
- `lib/secrets.dart` 文件已被添加到 `.gitignore` 中，不会被提交到版本控制系统
- 请确保不要将真实的App Key提交到公共代码仓库
- 建议在团队内部安全地共享真实的App Key

## 当前配置
- **Android App ID**: `ae931cda6f`
- **调试模式**: 动态配置（`debugMode: kDebugMode`）
- **初始化位置**: `lib/main.dart` 的 `main()` 函数中
- **智能切换**: 自动根据编译模式设置调试状态

## 功能特性
- 自动收集应用崩溃信息
- 性能监控
- 调试模式下会显示详细的崩溃信息

## 测试集成
运行以下命令验证集成是否成功：
```bash
flutter build apk --debug
```

如果构建成功且没有错误，说明Bugly集成正常。

## 智能配置说明

### 动态调试模式
项目使用了Flutter的 `kDebugMode` 常量，实现自动切换：

- **Debug构建** (`flutter run` 或 `flutter build --debug`)：
  - `kDebugMode` = `true`
  - 启用详细调试信息
  - 适合开发和测试

- **Release构建** (`flutter build --release`)：
  - `kDebugMode` = `false`
  - 启用生产模式
  - 适合正式发布

### 无需手动切换
现在您不需要手动修改 `debugMode` 设置，系统会根据编译模式自动选择最合适的配置。

## 注意事项
- 定期检查Bugly控制台以监控应用稳定性
- 根据Bugly提供的崩溃报告及时修复问题
- 发布前请使用 `flutter build --release` 确保生产模式配置正确 