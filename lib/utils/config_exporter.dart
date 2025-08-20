import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TwentyHours/models/skill_model.dart';
import 'package:TwentyHours/utils/group_storage.dart';

// 配置导出工具类
class ConfigExporter {
  // 自动导出配置（不包含头像和侧边栏背景）
  static Future<void> autoExportConfig() async {
    try {
      // 使用应用内部存储目录
      final appDir = await getApplicationDocumentsDirectory();
      String backupPath = '${appDir.path}/20timer_backup';
      print('自动导出配置到: $backupPath');

      // 创建或清空备份目录
      final backupDir = Directory(backupPath);
      if (await backupDir.exists()) {
        // 如果目录存在，删除所有内容
        try {
          await backupDir.delete(recursive: true);
        } catch (e) {
          print('删除旧备份目录失败: $e');
          // 如果删除失败，尝试使用新的目录名
          backupPath = '${backupPath}_${DateTime.now().millisecondsSinceEpoch}';
          final newBackupDir = Directory(backupPath);
          await newBackupDir.create(recursive: true);
          print('使用新备份目录: $backupPath');
        }
      }

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final prefs = await SharedPreferences.getInstance();

      // 收集配置数据（不包含头像和侧边栏背景）
      final Map<String, dynamic> configData = {
        'version': '1.0',
        'exportTime': DateTime.now().toIso8601String(),
        'userInfo': {
          'userName': prefs.getString('user_name') ?? '开狼',
          'avatarPath': null, // 不包含头像
          'drawerBgPath': null, // 不包含侧边栏背景
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

      // 保存配置文件
      final configFile = File('${backupDir.path}/config.json');
      final configJson = jsonEncode(configData);
      await configFile.writeAsString(configJson);

      print('自动导出配置文件成功: ${configFile.path}');
      print('配置文件内容长度: ${configJson.length} 字符');
    } catch (e) {
      print('自动导出配置失败: $e');
    }
  }
}
