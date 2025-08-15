import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TwentyHours/models/skill_model.dart';
import '../main.dart';
import 'dart:convert';

// 统计页面，显示所有技能的累积时间统计表格
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Skill> _skills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 每次页面显示时刷新数据
    _loadSkills();
  }

  // 从本地存储加载技能数据
  Future<void> _loadSkills() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? skillsAsString = prefs.getStringList(
        'skills_list_key',
      );

      if (skillsAsString != null && skillsAsString.isNotEmpty) {
        final List<Skill> loadedSkills = skillsAsString
            .map((skillString) => Skill.fromMap(json.decode(skillString)))
            .toList();

        // 按累积时间从多到少排序
        loadedSkills.sort((a, b) => b.totalTime.compareTo(a.totalTime));

        setState(() {
          _skills = loadedSkills;
          _isLoading = false;
        });
      } else {
        setState(() {
          _skills = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('加载技能数据失败: $e');
      setState(() {
        _skills = [];
        _isLoading = false;
      });
    }
  }

  // 格式化时间显示
  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  // 计算总练习时间
  int get _totalPracticeTime {
    return _skills.fold(0, (sum, skill) => sum + skill.totalTime);
  }

  // 计算完成20小时目标的技能数量
  int get _completedSkillsCount {
    return _skills.where((skill) => skill.totalTime >= 20 * 3600).length;
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
              '技能练习时间排行',
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
        children: [
          _buildStatRow('总练习时间', _formatTime(_totalPracticeTime), Icons.timer),
          const SizedBox(height: 16),
          _buildStatRow('技能数量', '${_skills.length} 个', Icons.star),
          const SizedBox(height: 16),
          _buildStatRow(
            '完成20小时目标',
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kPrimaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 14, color: kTextSub)),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kTextMainDark
                      : kTextMain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 构建技能统计表格
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
          // 表格头部
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 40), // 为排名留空间
                Expanded(
                  flex: 2,
                  child: Text(
                    '技能名称',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '练习时间',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    '进度',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // 表格内容
          ...List.generate(_skills.length, (index) {
            final skill = _skills[index];
            final isLast = index == _skills.length - 1;

            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: isLast
                      ? BorderSide.none
                      : BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                ),
              ),
              child: _buildSkillRow(skill, index + 1),
            );
          }),
        ],
      ),
    );
  }

  // 构建技能行
  Widget _buildSkillRow(Skill skill, int rank) {
    final isCompleted = skill.totalTime >= 20 * 3600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 排名
          SizedBox(
            width: 40,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: rank <= 3
                    ? [
                        Colors.amber,
                        Colors.grey.shade400,
                        Colors.orange.shade300,
                      ][rank - 1]
                    : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? Colors.white : kTextSub,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // 技能图标和名称
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Color(skill.iconColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    IconData(skill.iconCodePoint, fontFamily: 'MaterialIcons'),
                    color: Color(skill.iconColor),
                    size: 20,
                  ),
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
                fontWeight: FontWeight.w500,
                color: isCompleted ? Colors.green : kTextSub,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // 进度
          Expanded(
            child: Column(
              children: [
                Text(
                  skill.progressPercentage,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? Colors.green : kTextSub,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: skill.progressBasedOn20Hours,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green : kPrimaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
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
