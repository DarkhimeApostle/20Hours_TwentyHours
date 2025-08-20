# Android 权限问题修复说明

## 问题描述

应用在Android 11+设备上遇到存储权限问题，主要表现为：
- 无法访问外部存储文件
- 备份导入功能失败
- 图片选择功能受限

## 根本原因

不同Android版本的权限管理机制不同：

### Android 8-9 (API 26-28)
- 引入了**运行时权限**概念
- 需要动态请求危险权限（如存储权限）
- 权限请求相对简单

### Android 10 (API 29)
- **分区存储**成为默认行为
- 应用无法直接访问其他应用的文件
- 需要 `requestLegacyExternalStorage="true"` 来保持传统行为

### Android 11+ (API 30+)
- 引入了更严格的存储权限管理
- **管理外部存储权限**：需要特殊权限才能访问所有文件
- **细粒度媒体权限**：Android 13+需要分别请求图片、视频、音频权限

## 解决方案

### 1. 更新AndroidManifest.xml

添加了以下权限：

```xml
<!-- 基础存储权限 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

<!-- Android 11+ 管理外部存储权限 -->
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />

<!-- Android 13+ 细粒度媒体权限 -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>

<!-- 相机权限 -->
<uses-permission android:name="android.permission.CAMERA"/>

<!-- 网络权限（用于分享功能） -->
<uses-permission android:name="android.permission.INTERNET"/>
```

在application标签中添加：
```xml
android:requestLegacyExternalStorage="true"
```

### 2. 创建权限处理工具类

创建了 `lib/utils/permission_helper.dart`，提供统一的权限处理：

- **检查权限**：`PermissionHelper.hasStoragePermission()`
- **请求权限**：`PermissionHelper.requestStoragePermission(context)`
- **相机权限**：`PermissionHelper.requestCameraPermission(context)`
- **打开设置**：`PermissionHelper.openAppSettings()`

### 3. 权限请求策略

采用版本适配的权限请求策略：

#### Android 8-9 (API 26-28)
1. **请求基础存储权限**
2. **提供用户友好的权限说明**

#### Android 10 (API 29)
1. **请求基础存储权限**
2. **使用 `requestLegacyExternalStorage="true"` 保持传统行为**
3. **提供用户友好的权限说明**

#### Android 11+ (API 30+)
1. **首先请求基础存储权限**
2. **如果被拒绝，请求管理外部存储权限**
3. **如果还是被拒绝，请求照片权限（Android 13+）**
4. **提供用户友好的权限说明对话框**

### 4. 用户体验优化

- **权限状态检查**：在需要权限的功能执行前检查
- **友好提示**：当权限被拒绝时显示详细的说明
- **一键设置**：提供直接跳转到应用设置的按钮
- **状态反馈**：通过SnackBar显示权限状态变化

## 使用说明

### 在代码中使用权限检查

```dart
// 检查存储权限
if (!await PermissionHelper.hasStoragePermission()) {
  final granted = await PermissionHelper.requestStoragePermission(context);
  if (!granted) {
    // 用户拒绝了权限，处理相应逻辑
    return;
  }
}

// 继续执行需要权限的操作
```

### 权限被拒绝时的处理

当用户拒绝权限时，应用会：
1. 显示详细的权限说明对话框
2. 提供"打开设置"按钮
3. 引导用户手动授予权限

## 测试建议

1. **在不同Android版本上测试**：
   - **Android 8-9**：基础存储权限，权限请求相对简单
   - **Android 10**：基础存储权限 + 分区存储处理
   - **Android 11-12**：管理外部存储权限
   - **Android 13+**：细粒度媒体权限

2. **测试权限拒绝场景**：
   - 首次拒绝权限
   - 永久拒绝权限
   - 在设置中手动授予权限

3. **测试功能完整性**：
   - 图片选择功能
   - 备份导出功能
   - 备份导入功能
   - 文件分享功能

4. **版本兼容性测试**：
   - 确保在旧版本Android上权限请求正常工作
   - 验证权限对话框显示正确的版本信息
   - 测试权限状态检查的准确性

## 注意事项

1. **权限说明**：在应用商店描述中说明权限用途
2. **渐进式权限**：只在需要时才请求权限
3. **降级处理**：当权限被拒绝时提供替代方案
4. **用户教育**：通过UI引导用户理解权限必要性

## 相关文件

- `android/app/src/main/AndroidManifest.xml` - 权限声明
- `lib/utils/permission_helper.dart` - 权限处理工具类
- `lib/screens/settings_screen.dart` - 权限使用示例

## 更新日志

- **2024-08-20**：初始权限修复
  - 添加Android 11+权限支持
  - 创建权限处理工具类
  - 优化用户体验 