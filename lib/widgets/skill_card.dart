import 'package:flutter/material.dart';
import 'package:TwentyHours/models/skill_model.dart';

// 可复用的、专门用于显示单个技能信息的“卡片”组件
class SkillCard extends StatelessWidget {
  // 接收两个外部参数：
  final Skill skill; // 1. 要显示的具体技能数据
  final Function() onDelete; // 2. 当删除按钮被点击时，需要执行的回调函数

  // 构造函数，要求这两个参数都必须被提供
  const SkillCard({super.key, required this.skill, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    // Card 组件 创建带有圆角和阴影的卡片外观
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 左侧的图标
            Icon(
              skill.icon,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),

            const SizedBox(width: 16),

            // 中间的文字和进度条，用Expanded来占满所有可用空间
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '累计: ${skill.totalTime}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: skill.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                    minHeight: 6, // 让进度条稍微粗一点
                  ),
                ],
              ),
            ),

            // 右侧的删除按钮
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
