import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skill_group.dart';

class GroupStorage {
  static const String groupsKey = 'groups_list_key';

  // 加载所有分组
  static Future<List<SkillGroup>> loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(groupsKey) ?? [];
    return list.map((e) => SkillGroup.fromMap(jsonDecode(e))).toList();
  }

  // 保存所有分组
  static Future<void> saveGroups(List<SkillGroup> groups) async {
    final prefs = await SharedPreferences.getInstance();
    final list = groups.map((g) => jsonEncode(g.toMap())).toList();
    await prefs.setStringList(groupsKey, list);
  }

  // 新增分组
  static Future<void> addGroup(SkillGroup group) async {
    final groups = await loadGroups();
    groups.add(group);
    await saveGroups(groups);
  }

  // 更新分组
  static Future<void> updateGroup(SkillGroup group) async {
    final groups = await loadGroups();
    final idx = groups.indexWhere((g) => g.id == group.id);
    if (idx != -1) {
      groups[idx] = group;
      await saveGroups(groups);
    }
  }

  // 删除分组
  static Future<void> deleteGroup(String groupId) async {
    final groups = await loadGroups();
    groups.removeWhere((g) => g.id == groupId);
    await saveGroups(groups);
  }

  // 排序分组
  static Future<void> reorderGroups(List<SkillGroup> groups) async {
    await saveGroups(groups);
  }
}
