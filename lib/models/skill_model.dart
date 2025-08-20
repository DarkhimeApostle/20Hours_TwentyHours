import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'icon_map.dart';

// 技能数据模型，描述一个技能的基本信息
class Skill {
  final String id; // 新增唯一id
  final String name; // 技能名称
  final int totalTime; // 技能累计时长，单位秒
  final int iconCodePoint; // 图标的codePoint
  final double progress; // 技能进度，范围0.0~1.0
  final String? groupId; // 技能分组ID，null表示未分组
  final bool inHallOfGlory;
  final bool congratulated; // 是否已祝贺
  final int iconColor; // 图标颜色（Color的value）

  // 构造函数，创建一个Skill对象
  const Skill({
    required this.id,
    required this.name,
    required this.totalTime,
    required this.iconCodePoint,
    required this.progress,
    this.groupId,
    this.inHallOfGlory = false,
    this.congratulated = false,
    this.iconColor = 0xFF2563EB, // 默认主色
  });

  // 获取当前时间（用于显示）
  int get currentTime => totalTime;

  // 获取颜色
  Color get color => Color(iconColor);

  // 获取图标
  IconData get icon => skillIconMap[iconCodePoint] ?? Icons.help_outline;

  // 生成一个新的Skill对象，可选择性修改部分字段
  Skill copyWith({
    String? id,
    String? name,
    int? totalTime,
    int? iconCodePoint,
    double? progress,
    String? groupId,
    bool? inHallOfGlory,
    bool? congratulated,
    int? iconColor,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      totalTime: totalTime ?? this.totalTime,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      progress: progress ?? this.progress,
      groupId: groupId ?? this.groupId,
      inHallOfGlory: inHallOfGlory ?? this.inHallOfGlory,
      congratulated: congratulated ?? this.congratulated,
      iconColor: iconColor ?? this.iconColor,
    );
  }

  // 累加时长
  Skill addTime(int seconds) {
    return copyWith(totalTime: totalTime + seconds);
  }

  // 格式化显示累计时间
  String get formattedTime {
    final hours = totalTime ~/ 3600;
    final minutes = (totalTime % 3600) ~/ 60;
    final seconds = totalTime % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 根据20小时目标计算进度
  double get progressBasedOn20Hours {
    const int targetSeconds = 20 * 3600; // 20小时 = 72000秒
    return (totalTime / targetSeconds).clamp(0.0, 1.0);
  }

  // 获取进度百分比文本
  String get progressPercentage {
    final percentage = (progressBasedOn20Hours * 100).toInt();
    return '$percentage%';
  }

  // 序列化为Map
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'totalTime': totalTime,
    'iconCodePoint': iconCodePoint,
    'progress': progress,
    'groupId': groupId,
    'inHallOfGlory': inHallOfGlory,
    'congratulated': congratulated,
    'iconColor': iconColor,
  };

  // 反序列化
  factory Skill.fromMap(Map<String, dynamic> map) => Skill(
    id: (map['id'] == null || (map['id'] as String).isEmpty)
        ? const Uuid().v4()
        : map['id'],
    name: map['name'],
    totalTime: map['totalTime'],
    iconCodePoint: map['iconCodePoint'],
    progress: map['progress'],
    groupId: map['groupId'],
    inHallOfGlory: map['inHallOfGlory'] ?? false,
    congratulated: map['congratulated'] ?? false,
    iconColor: map['iconColor'] ?? 0xFF2563EB,
  );
}
