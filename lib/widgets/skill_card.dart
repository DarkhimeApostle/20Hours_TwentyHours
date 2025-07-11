import 'package:flutter/material.dart';
import 'package:TwentyHours/models/skill_model.dart';

// 技能卡片组件
// 这个组件用于显示一个技能的名称、图标和进度条
class SkillCard extends StatelessWidget {
  // 接收两个外部参数：
  final Skill skill; // 要显示的具体技能数据

  final VoidCallback onCardTapped; //  当卡片被点击时，需要执行的回调函数
  final VoidCallback onCardLongPressed; //  当卡片被长按时，需要执行的回调函数

  // 构造函数，要求这两个参数都必须被提供
  const SkillCard({
    super.key,
    required this.skill,

    // 添加点击和长按回调
    required this.onCardTapped,
    required this.onCardLongPressed,
  });
  // 这个组件的主要作用是显示一个技能的名称、图标和进度条
  // 当用户点击或长按这个卡片时，会触发相应的回调函数

  @override
  Widget build(BuildContext context) {
    // 使用 InkWell 包裹 Card 组件，
    // 这样可以让卡片在被点击时有水波纹效果，
    return InkWell(
      // 处理点击事件
      onTap: onCardTapped,

      onLongPress: onCardLongPressed,

      // 设置边框圆角
      borderRadius: BorderRadius.circular(12),

      // 包裹 Card 组件
      child: Card(
        // 设置卡片的样式
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        //
        child: Padding(
          // 添加内边距
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 技能图标
              Icon(skill.icon),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  // ...
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
