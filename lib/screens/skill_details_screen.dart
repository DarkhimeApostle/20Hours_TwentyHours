import 'package:flutter/material.dart';
import 'package:TwentyHours/models/skill_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 技能详情页面，显示技能的详细信息和心情日记
class SkillDetailsScreen extends StatefulWidget {
  final Skill skill;
  const SkillDetailsScreen({super.key, required this.skill});

  @override
  State<SkillDetailsScreen> createState() => _SkillDetailsScreenState();
}

class _SkillDetailsScreenState extends State<SkillDetailsScreen> {
  List<String> _diaryList = [];
  final TextEditingController _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadDiary();
  }

  Future<void> _loadDiary() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'skill_diary_${widget.skill.name}';
    setState(() {
      _diaryList = prefs.getStringList(key) ?? [];
    });
  }

  Future<void> _saveDiary() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'skill_diary_${widget.skill.name}';
    await prefs.setStringList(key, _diaryList);
  }

  Future<void> _addDiary() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSaving = true);
    _diaryList.insert(0, '${DateTime.now().toIso8601String()}|$text');
    await _saveDiary();
    setState(() {
      _isSaving = false;
      _controller.clear();
    });
  }

  Future<void> _deleteDiary(int index) async {
    setState(() {
      _diaryList.removeAt(index);
    });
    await _saveDiary();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.skill.name)),
      body: Column(
        children: [
          Expanded(
            child: _diaryList.isEmpty
                ? Center(child: Text('暂无短日记'))
                : ListView.separated(
                    reverse: false,
                    itemCount: _diaryList.length,
                    separatorBuilder: (_, __) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = _diaryList[index];
                      final split = entry.split('|');
                      final time = split[0];
                      final text = split.sublist(1).join('|');
                      return Dismissible(
                        key: ValueKey(entry),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.redAccent,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _deleteDiary(index),
                        child: ListTile(
                          title: Text(text),
                          subtitle: Text(
                            time.replaceFirst('T', ' ').substring(0, 16),
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1, // 高度提升一倍
                    maxLines: 6,
                    decoration: InputDecoration(hintText: ''),
                  ),
                ),
                const SizedBox(width: 8),
                _isSaving
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : ElevatedButton(
                        onPressed: _addDiary,
                        child: const Text('添加'),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
