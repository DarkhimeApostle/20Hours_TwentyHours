import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skill_model.dart';
import '../utils/group_storage.dart';

// 配置导出工具类
class ConfigExporter {
  // 自动导出配置（不包含头像和侧边栏背景）
  static Future<void> autoExportConfig() async {
    try {
      // 使用应用内部存储目录
      final appDir = await getApplicationDocumentsDirectory();
      String backupPath = '${appDir.path}/t20_backup';

      // 创建或清空备份目录
      final backupDir = Directory(backupPath);
      if (await backupDir.exists()) {
        // 如果目录存在，删除所有内容
        try {
          await backupDir.delete(recursive: true);
        } catch (e) {
          // 如果删除失败，尝试使用新的目录名
          backupPath = '${backupPath}_${DateTime.now().millisecondsSinceEpoch}';
          final newBackupDir = Directory(backupPath);
          await newBackupDir.create(recursive: true);
        }
      }

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final prefs = await SharedPreferences.getInstance();

      // 收集配置数据（包含头像和侧边栏背景）
      final Map<String, dynamic> configData = {
        'version': '1.0',
        'exportTime': DateTime.now().toIso8601String(),
        'userInfo': {
          'userName': prefs.getString('user_name') ?? '开发者',
          'avatarPath': prefs.getString('user_avatar_path'),
          'drawerBgPath': prefs.getString('drawer_bg_path'),
        },
        'skills': {'mainSkills': [], 'hallOfGlorySkills': []},
        'diaries': {},
        'congratulatedSkills':
            prefs.getStringList('congratulated_skill_ids') ?? [],
        'groups': [],
      };

      // 获取所有技能数据
      final List<String>? skillsAsString = prefs.getStringList(
        'skills_list_key',
      );
      if (skillsAsString != null && skillsAsString.isNotEmpty) {
        final List<Skill> allSkills = skillsAsString
            .map((e) => Skill.fromMap(Map<String, dynamic>.from(jsonDecode(e))))
            .toList();

        // 分离主页面和荣耀殿堂的技能
        for (final skill in allSkills) {
          final skillData = skill.toMap();
          if (skill.inHallOfGlory) {
            configData['skills']['hallOfGlorySkills'].add(skillData);
          } else {
            configData['skills']['mainSkills'].add(skillData);
          }

          // 获取技能日记
          final diaryKey = 'skill_diary_${skill.name}';
          final diaryList = prefs.getStringList(diaryKey);
          if (diaryList != null && diaryList.isNotEmpty) {
            configData['diaries'][skill.name] = diaryList;
          }
        }
      }

      // 获取技能分组数据
      final groups = await GroupStorage.loadGroups();
      configData['groups'] = groups.map((g) => g.toMap()).toList();

      // 复制头像和背景图片
      final avatarPath = prefs.getString('user_avatar_path');
      if (avatarPath != null && avatarPath.isNotEmpty) {
        try {
          final avatarFile = File(avatarPath);
          if (await avatarFile.exists()) {
            // 保持原始文件扩展名
            final extension = avatarPath.split('.').last;
            final backupAvatarPath = '${backupDir.path}/avatar.$extension';
            await avatarFile.copy(backupAvatarPath);
          } else {}
        } catch (e) {
          print('自动导出：复制头像失败: $e');
        }
      } else {}

      final drawerBgPath = prefs.getString('drawer_bg_path');
      if (drawerBgPath != null && drawerBgPath.isNotEmpty) {
        try {
          final bgFile = File(drawerBgPath);
          if (await bgFile.exists()) {
            // 保持原始文件扩展名
            final extension = drawerBgPath.split('.').last;
            final backupBgPath = '${backupDir.path}/drawer_bg.$extension';
            await bgFile.copy(backupBgPath);
          } else {}
        } catch (e) {
          print('自动导出：复制背景图片失败: $e');
        }
      } else {}

      // 保存配置文件
      final configFile = File('${backupDir.path}/config.json');
      final configJson = jsonEncode(configData);
      await configFile.writeAsString(configJson);
    } catch (e) {
      print('ConfigExporter: 自动导出配置失败: $e');
    }
  }
}
