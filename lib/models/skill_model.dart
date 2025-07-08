import 'package:flutter/material.dart';

// 数据核心：技能数据模型
class Skill {
  // Skill对象被创建后，就不能再被修改
  final String name; // 技能名称
  final String totalTime; // 累计时长 (我们未来会重构成一个更精确的类型)
  final IconData icon; // 用于在UI上显示的图标
  final double progress; // 学习进度 (0.0 到 1.0)

  //  const 创建不可变的 Skill 对象
  const Skill({
    // required 表示这些参数在创建Skill对象时，都必须被提供
    required this.name,
    required this.totalTime,
    required this.icon,
    required this.progress,
  });
}
