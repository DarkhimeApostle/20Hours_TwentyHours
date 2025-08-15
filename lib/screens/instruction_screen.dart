import 'package:flutter/material.dart';
import '../main.dart';

class InstructionScreen extends StatelessWidget {
  const InstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 标题
            Center(
              child: Column(
                children: [
                  Icon(Icons.help_outline, size: 48, color: kPrimaryColor),
                  const SizedBox(height: 12),
                  Text(
                    '使用说明',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? kTextMainDark
                          : kTextMain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '新手必读指南',
                    style: TextStyle(fontSize: 14, color: kTextSub),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 功能介绍
            _buildSection(
              context,
              title: '🎯 核心功能',
              items: [
                '技能计时：为不同技能设置独立的计时器',
                '进度追踪：实时显示技能练习进度',
                '数据统计：查看技能练习历史和成就',
                '个性化设置：自定义头像、背景和用户名',
              ],
            ),

            const SizedBox(height: 20),

            // 使用步骤
            _buildSection(
              context,
              title: '📋 使用步骤',
              items: [
                '1. 点击右上角"+"按钮添加新技能',
                '2. 设置技能名称、图标和目标时间',
                '3. 点击底部悬浮按钮开始计时',
                '4. 选择要练习的技能并开始计时',
                '5. 计时结束后选择归属技能',
                '6. 在荣耀殿堂查看成就记录',
              ],
            ),

            const SizedBox(height: 20),

            // 操作技巧
            _buildSection(
              context,
              title: '💡 操作技巧',
              items: [
                '右滑打开侧边栏，访问更多功能',
                '长按技能卡片可编辑或删除技能',
                '在设置中自定义应用外观',
                '查看统计了解练习趋势',
                '设置合理的目标时间，循序渐进',
              ],
            ),

            const SizedBox(height: 20),

            // 注意事项
            _buildSection(
              context,
              title: '⚠️ 注意事项',
              items: [
                '计时过程中请勿关闭应用',
                '建议定期备份重要数据',
                '合理分配练习时间，避免过度疲劳',
                '坚持练习才能看到明显进步',
              ],
            ),

            const SizedBox(height: 30),

            // 联系信息
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kCardDark
                      : kCardLight,
                  borderRadius: BorderRadius.circular(12),
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
                    Icon(Icons.help_outline, size: 32, color: kPrimaryColor),
                    const SizedBox(height: 8),
                    Text(
                      '如有问题或建议',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? kTextMainDark
                            : kTextMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '欢迎在关于页面联系我们',
                      style: TextStyle(fontSize: 14, color: kTextSub),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 构建说明章节
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? kCardDark
            : kCardLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? kTextMainDark
                  : kTextMain,
            ),
          ),
          const SizedBox(height: 12),
          ...items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 8, right: 12),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? kTextMainDark
                                : kTextMain,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
