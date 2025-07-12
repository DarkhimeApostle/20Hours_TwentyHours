import 'package:flutter/material.dart';

// 技能数据模型，描述一个技能的基本信息
class Skill {
  final String name; // 技能名称
  final String totalTime; // 技能累计时长，格式如“01:23:45”
  final IconData icon; // 技能对应的图标
  final double progress; // 技能进度，范围0.0~1.0

  // 构造函数，创建一个Skill对象
  const Skill({
    required this.name,
    required this.totalTime,
    required this.icon,
    required this.progress,
  });

  // 生成一个新的Skill对象，可选择性修改部分字段
  Skill copyWith({
    String? name,
    String? totalTime,
    IconData? icon,
    double? progress,
  }) {
    return Skill(
      name: name ?? this.name,
      totalTime: totalTime ?? this.totalTime,
      icon: icon ?? this.icon,
      progress: progress ?? this.progress,
    );
  }
}
