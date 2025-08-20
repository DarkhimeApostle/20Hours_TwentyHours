import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skill_model.dart';
import '../models/icon_map.dart';
import '../main.dart';
import 'dart:convert';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Skill> _skills = [];
  bool _isLoading = true;
  int _totalPracticeTime = 0;
  int _completedSkillsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final skillsAsString = prefs.getStringList('skills_list_key') ?? [];

      if (skillsAsString.isNotEmpty) {
        final List<Skill> loadedSkills = skillsAsString
            .map((skillString) => Skill.fromMap(json.decode(skillString)))
            .toList();

        // 按练习时间排序
        loadedSkills.sort((a, b) => b.totalTime.compareTo(a.totalTime));

        setState(() {
          _skills = loadedSkills;
          _totalPracticeTime = _calculateTotalPracticeTime();
          _completedSkillsCount = _calculateCompletedSkillsCount();
          _isLoading = false;
        });
      } else {
        setState(() {
          _skills = [];
          _totalPracticeTime = 0;
          _completedSkillsCount = 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('加载技能数据失败: $e');
      setState(() {
        _skills = [];
        _totalPracticeTime = 0;
        _completedSkillsCount = 0;
        _isLoading = false;
      });
    }
  }

  int _calculateTotalPracticeTime() {
    return _skills.fold(0, (sum, skill) => sum + skill.totalTime);
  }

  int _calculateCompletedSkillsCount() {
    return _skills.where((skill) => skill.totalTime >= 20 * 3600).length;
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return '${hours}小时${minutes}分钟';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('技能统计'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? kTextMainDark
              : kTextMain,
        ),
        titleTextStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? kTextMainDark
              : kTextMain,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _skills.isEmpty
              ? _buildEmptyState()
              : _buildStatisticsContent(),
    );
  }

  // 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: kTextSub),
          const SizedBox(height: 24),
          Text(
            '暂无技能数据',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kTextSub,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '开始添加技能并练习来查看统计',
            style: TextStyle(fontSize: 14, color: kTextSub),
          ),
        ],
      ),
    );
  }

  // 构建统计内容
  Widget _buildStatisticsContent() {
    return RefreshIndicator(
      onRefresh: _loadSkills,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 总体统计卡片
            _buildOverallStatsCard(),
            const SizedBox(height: 20),

            // 技能统计表格标题
            Text(
              '技能练习时间排名',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextMainDark
                    : kTextMain,
              ),
            ),
            const SizedBox(height: 12),

            // 技能统计表格
            _buildSkillsTable(),
          ],
        ),
      ),
    );
  }

  // 构建总体统计卡片
  Widget _buildOverallStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? kCardDark
            : kCardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '总体统计',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? kTextMainDark
                  : kTextMain,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow('总练习时间', _formatTime(_totalPracticeTime), Icons.timer),
          const SizedBox(height: 8),
          _buildStatRow('技能数量', '${_skills.length} 个', Icons.star),
          const SizedBox(height: 8),
          _buildStatRow(
            '已完成技能',
            '$_completedSkillsCount 个',
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  // 构建统计行
  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: kPrimaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? kTextSubDark
                  : kTextSub,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? kTextMainDark
                : kTextMain,
          ),
        ),
      ],
    );
  }

  // 构建技能表格
  Widget _buildSkillsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? kCardDark
            : kCardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 表头
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 40), // 排名列宽度
                Expanded(
                  flex: 2,
                  child: Text(
                    '技能名称',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? kTextMainDark
                          : kTextMain,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '练习时间',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? kTextMainDark
                          : kTextMain,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '进度',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? kTextMainDark
                          : kTextMain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 表格内容
          ...List.generate(_skills.length, (index) {
            final skill = _skills[index];
            final rank = index + 1;
            return _buildSkillRow(skill, rank);
          }),
        ],
      ),
    );
  }

  // 构建技能行
  Widget _buildSkillRow(Skill skill, int rank) {
    final isLast = rank == _skills.length;
    final progress = (skill.totalTime / (20 * 3600) * 100).clamp(0, 100);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
      ),
      child: Row(
        children: [
          // 排名
          SizedBox(
            width: 40,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: rank <= 3 ? Colors.amber : kTextSub,
              ),
            ),
          ),
          // 技能图标和名称
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(
                  skillIconMap[skill.iconCodePoint] ?? Icons.help_outline,
                  size: 20,
                  color: kPrimaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    skill.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? kTextMainDark
                          : kTextMain,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // 练习时间
          Expanded(
            child: Text(
              _formatTime(skill.totalTime),
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextSubDark
                    : kTextSub,
              ),
            ),
          ),
          // 进度
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${progress.toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: progress >= 100 ? Colors.green : kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 100 ? Colors.green : kPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
