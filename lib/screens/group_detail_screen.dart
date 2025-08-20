import 'package:flutter/material.dart';
import '../models/skill_group.dart';
import '../models/skill_model.dart';
import '../utils/group_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Added for jsonDecode and jsonEncode

class GroupDetailScreen extends StatefulWidget {
  final SkillGroup group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  List<Skill> _skills = [];
  bool _loading = true;
  String _sortType = 'custom'; // custom, time, name

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('skills_list_key') ?? [];
    final allSkills = list
        .map((e) => Skill.fromMap(Map<String, dynamic>.from(jsonDecode(e))))
        .toList();
    final groupSkills = allSkills
        .where((s) => s.groupId == widget.group.id)
        .toList();
    setState(() {
      _skills = groupSkills;
      _loading = false;
    });
  }

  Future<void> _saveSkills() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('skills_list_key') ?? [];
    final allSkills = list
        .map((e) => Skill.fromMap(Map<String, dynamic>.from(jsonDecode(e))))
        .toList();
    // 更新分组内技能顺�?
    for (final skill in _skills) {
      final i = allSkills.indexWhere(
        (s) => s.name == skill.name && s.groupId == skill.groupId,
      );
      if (i != -1) {
        allSkills[i] = skill;
      }
    }
    await prefs.setStringList(
      'skills_list_key',
      allSkills.map((s) => jsonEncode(s.toMap())).toList(),
    );
  }

  void _sortSkills(String type) {
    setState(() {
      _sortType = type;
      if (type == 'time') {
        _skills.sort((a, b) => b.totalTime.compareTo(a.totalTime));
      } else if (type == 'name') {
        _skills.sort((a, b) => a.name.compareTo(b.name));
      }
      // custom为手动拖动顺�?
    });
  }

  Future<void> _moveSkill(Skill skill, String? newGroupId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('skills_list_key') ?? [];
    final allSkills = list
        .map((e) => Skill.fromMap(Map<String, dynamic>.from(jsonDecode(e))))
        .toList();
    final idx = allSkills.indexWhere(
      (s) => s.name == skill.name && s.groupId == skill.groupId,
    );
    if (idx != -1) {
      allSkills[idx] = skill.copyWith(groupId: newGroupId);
      await prefs.setStringList(
        'skills_list_key',
        allSkills.map((s) => jsonEncode(s.toMap())).toList(),
      );
      await _loadSkills();
    }
  }

  Future<void> _selectAndMoveSkill(Skill skill) async {
    final groups = await GroupStorage.loadGroups();
    final otherGroups = groups.where((g) => g.id != widget.group.id).toList();
    if (otherGroups.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('暂无其它分组可移�?)));
      return;
    }
    final newGroupId = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('选择目标分组'),
        children: otherGroups
            .map(
              (g) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, g.id),
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: Color(g.color), radius: 10),
                    const SizedBox(width: 10),
                    Text(g.name),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
    if (newGroupId != null) {
      await _moveSkill(skill, newGroupId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已移动到新分�?)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(widget.group.color),
              radius: 12,
            ),
            const SizedBox(width: 10),
            Text(widget.group.name),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: '按累计时间排�?,
            onPressed: () => _sortSkills('time'),
          ),
          IconButton(
            icon: const Icon(Icons.sort_by_alpha),
            tooltip: '按名称排�?,
            onPressed: () => _sortSkills('name'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _skills.isEmpty
          ? const Center(child: Text('该分组暂无技�?))
          : ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex--;
                  final item = _skills.removeAt(oldIndex);
                  _skills.insert(newIndex, item);
                });
                _saveSkills();
              },
              children: [
                for (final skill in _skills)
                  Card(
                    key: ValueKey(skill.name + (skill.groupId ?? '')),

                    // 由于Skill没有icon属性，这里可以用一个默认图标或者根据Skill的其他属性自定义图标
                    child: ListTile(
                      leading: const Icon(Icons.star), // 使用默认图标
                      title: Text(skill.name),
                      subtitle: Text(
                        '累计时长�?{skill.totalTime ~/ 3600}小时${(skill.totalTime % 3600) ~/ 60}�?,
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'remove') {
                            await _moveSkill(skill, null);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已移出分�?)),
                            );
                          } else if (value == 'move') {
                            await _selectAndMoveSkill(skill);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'remove',
                            child: Text('移出分组'),
                          ),
                          const PopupMenuItem(
                            value: 'move',
                            child: Text('移动到其它分�?),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
