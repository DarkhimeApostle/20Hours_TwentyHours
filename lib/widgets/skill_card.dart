import 'package:flutter/material.dart';
import 'package:TwentyHours/models/skill_model.dart';
import '../main.dart';

// 技能卡片组件，用于展示技能信息
class SkillCard extends StatelessWidget {
  // 技能数据
  final Skill skill;
  // 点击卡片时的回调
  final VoidCallback onCardTapped;
  // 长按卡片时的回调
  final VoidCallback onCardLongPressed;

  // 构造函数，要求传入技能数据和回调
  const SkillCard({
    super.key,
    required this.skill,
    required this.onCardTapped,
    required this.onCardLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // 点击事件
      onTap: onCardTapped,
      // 长按事件
      onLongPress: onCardLongPressed,
      // 卡片圆角
      borderRadius: BorderRadius.circular(20),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // 技能图标加圆形背景
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kIconBgDark
                      : kIconBgLight,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(14),
                child: Icon(
                  skill.icon,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kTextMainDark
                      : kPrimaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              // 技能名称和进度条
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? kTextMainDark
                            : kTextMain,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: skill.progress,
                      minHeight: 8,
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? kCardDark
                          : kButtonLight,
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
