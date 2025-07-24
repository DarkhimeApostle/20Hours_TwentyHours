import 'package:flutter/material.dart';

// 技能分组模型
class SkillGroup {
  final String id; // 分组唯一ID
  final String name; // 分组名称
  final int color; // 分组颜色（Color的value）
  final int order; // 分组排序权重

  SkillGroup({
    required this.id,
    required this.name,
    required this.color,
    required this.order,
  });

  // 序列化为Map
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'color': color,
    'order': order,
  };

  // 反序列化
  factory SkillGroup.fromMap(Map<String, dynamic> map) => SkillGroup(
    id: map['id'],
    name: map['name'],
    color: map['color'],
    order: map['order'],
  );
}
