import 'package:flutter/material.dart';

// 数据核心：技能数据模型
class Skill {
  // Skill对象被创建后，就不能再被修改
  final String name; // 技能名称
  final String totalTime; // 累计时长 (格式为 "HH:mm:ss")
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
  Skill copyWith({
    String? name,
    String? totalTime,
    IconData? icon,
    double? progress,
  }) {
    return Skill(
      // 如果提供了新的 name，就用新的；如果没有提供（为null），就用 this.name（旧的那个）
      name: name ?? this.name,
      totalTime: totalTime ?? this.totalTime,
      icon: icon ?? this.icon,
      progress: progress ?? this.progress,
    );
  }
}
