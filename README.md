# T20 计时软件

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.19.0-blue?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.3.0-blue?style=for-the-badge&logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-lightgrey?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**基于20小时理论的学习计时应用**

[![Download APK](https://img.shields.io/badge/Download-APK-orange?style=for-the-badge&logo=android)](https://github.com/your-username/t20/releases)
[![Star](https://img.shields.io/github/stars/your-username/t20?style=for-the-badge)](https://github.com/your-username/t20/stargazers)
[![Fork](https://img.shields.io/github/forks/your-username/t20?style=for-the-badge)](https://github.com/your-username/t20/network/members)

</div>

---

## 📋 目录

- [🎯 项目简介](#-项目简介)
- [💡 理论说明](#-理论说明)
- [🚀 功能介绍](#-功能介绍)
- [📱 应用截图](#-应用截图)
- [🛠️ 技术栈](#️-技术栈)
- [📦 安装说明](#-安装说明)
- [🎮 使用指南](#-使用指南)
- [🤝 贡献指南](#-贡献指南)
- [📄 许可证](#-许可证)

---

## 🎯 项目简介

传统10000小时（一万小时）学习理论，指的是成为传奇般的专家所需要的实际练习时间。而TED 演讲者 Josh Kaufman 发现，从客观掌握一项技能来看，大概只需要20 小时的练习时间。

比如说，如果从零开始刚好用了20小时ppt，那么你大概率已经掌握ppt这项技能了。T20就是这样一个专门计算20小时的软件。

### 📺 相关视频

> **Josh Kaufman的TED演讲：** [点击复制链接](https://www.bilibili.com/video/BV144411b7Uk/?spm_id_from=333.337.search-card.all.click&vd_source=83088a58ad42455867fdcaa59412bf93)

---

## 💡 理论说明

### 在原视频中，20小时的意思是：

1. **找3-5个你选定的优质学习资源**
2. **学习它们**
3. **实际练习**（☚Josh 的意思是从这里开始计算20小时）

### 我的看法是

1. **找3-5个你选定的优质学习资源**
2. **学习它们**（☚从这里就可以开始计算20小时）
3. **实际练习**

> 💡 **减轻心理门槛：** 这样减轻了起步的心理门槛，况且对于大多数技能（比如：如何煮汤）来说，可能学3-6小时就完全懂了。对于像建模和编程这类技能，20小时也足够跨越完全不懂的阶段啦。

> 💡 **灵活计时：** 不必被精确限制，比如大概学了30分钟，但是忘记计时了，可以长按技能手动补上30分钟。

---

## 🚀 功能介绍

### 功能1：开始计时
![功能1演示](assets/images/instructions/a1.webp)

### 功能2：长按调整时间与图标
![功能2演示](assets/images/instructions/a2.webp)

### 功能3：单击技能可以写小日记
![功能3演示](assets/images/instructions/a3.webp)

### 功能4：右上角有新建技能的按钮
![功能4演示](assets/images/instructions/a4.webp)

### 功能5：滑动技能可以移入移出殿堂
> *荣耀殿堂是一个专门放那些已完成技能的地方。*
![功能5演示](assets/images/instructions/a5.webp)

### 功能6：可以自定义侧边栏背景与头像，ID
![功能6演示](assets/images/instructions/a6.webp)

### 功能7：设置中可以导出当前配置
![功能7演示](assets/images/instructions/a7.webp)

---

## 📱 应用截图

<div align="center">

| 主界面 | 计时界面 | 荣耀殿堂 |
|--------|----------|----------|
| ![主界面](screenshots/main.png) | ![计时界面](screenshots/timer.png) | ![荣耀殿堂](screenshots/glory.png) |

| 设置界面 | 统计界面 | 技能详情 |
|----------|----------|----------|
| ![设置界面](screenshots/settings.png) | ![统计界面](screenshots/stats.png) | ![技能详情](screenshots/details.png) |

</div>

---

## 🛠️ 技术栈

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.19.0-02569B?style=flat-square&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.3.0-0175C2?style=flat-square&logo=dart)
![Android](https://img.shields.io/badge/Android-API%2021+-3DDC84?style=flat-square&logo=android)
![iOS](https://img.shields.io/badge/iOS-12.0+-000000?style=flat-square&logo=ios)

</div>

### 主要依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
  permission_handler: ^11.0.1
  flutter_slidable: ^3.0.1
  uuid: ^4.0.0
```

---

## 📦 安装说明

### 从源码构建

```bash
# 克隆项目
git clone https://github.com/your-username/t20.git
cd t20

# 安装依赖
flutter pub get

# 运行项目
flutter run
```

### 构建APK

```bash
# 构建发布版本APK
flutter build apk --release

# 构建分架构APK（推荐）
flutter build apk --split-per-abi --release
```

### 系统要求

- **Android:** API 21+ (Android 5.0+)
- **iOS:** iOS 12.0+
- **Flutter:** 3.19.0+
- **Dart:** 3.3.0+

---

## 🎮 使用指南

### 快速开始

1. **添加技能**
   - 点击右上角的"+"按钮
   - 输入技能名称
   - 选择技能图标

2. **开始计时**
   - 点击主界面的"开始计时"按钮
   - 选择要练习的技能
   - 开始专注学习

3. **查看进度**
   - 在主界面查看每个技能的进度条
   - 点击技能卡片查看详细信息
   - 在统计页面查看总体数据

### 高级功能

- **长按技能**：调整练习时间和图标
- **滑动技能**：移入/移出荣耀殿堂
- **单击技能**：添加学习日记
- **设置页面**：自定义头像、背景和导出配置

---

## 🤝 贡献指南

我们欢迎所有形式的贡献！

### 如何贡献

1. **Fork** 这个项目
2. **创建** 你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. **提交** 你的更改 (`git commit -m 'Add some AmazingFeature'`)
4. **推送** 到分支 (`git push origin feature/AmazingFeature`)
5. **打开** 一个 Pull Request

### 贡献类型

- 🐛 Bug 修复
- ✨ 新功能
- 📝 文档改进
- 🎨 UI/UX 优化
- ⚡ 性能优化
- 🔧 代码重构

### 开发环境设置

```bash
# 确保使用正确的Flutter版本
flutter --version

# 运行测试
flutter test

# 代码格式化
dart format .

# 静态分析
flutter analyze
```

---

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

---

<div align="center">

**如果这个项目对你有帮助，请给它一个 ⭐️**

[![GitHub stars](https://img.shields.io/github/stars/your-username/t20?style=social)](https://github.com/your-username/t20/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/your-username/t20?style=social)](https://github.com/your-username/t20/network/members)
[![GitHub issues](https://img.shields.io/github/issues/your-username/t20)](https://github.com/your-username/t20/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/your-username/t20)](https://github.com/your-username/t20/pulls)

**Made with ❤️ by [Your Name]**

</div>
