import 'package:flutter/material.dart';

// 技能数据模型，描述一个技能的基本信息
class Skill {
  final String name; // 技能名称
  final int totalTime; // 技能累计时长，单位秒
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
    int? totalTime,
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

  // 累加时长
  Skill addTime(int seconds) {
    return copyWith(totalTime: totalTime + seconds);
  }

  // 格式化显示累计时长
  String get formattedTime {
    final hours = totalTime ~/ 3600;
    final minutes = (totalTime % 3600) ~/ 60;
    final seconds = totalTime % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
