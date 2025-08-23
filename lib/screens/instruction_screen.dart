import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';

class InstructionScreen extends StatelessWidget {
  const InstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? kTextMainDark : kTextMain;
    final subTextColor = isDark ? kTextSubDark : kTextSub;
    final backgroundColor = isDark ? kBackgroundDark : kBackgroundLight;

    return Scaffold(
      backgroundColor: backgroundColor,

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题区域
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? kCardDark : kCardLight,
                borderRadius: BorderRadius.circular(16),
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
                    'T20 计时软件',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '传统10000小时（一万小时）学习理论，指的是成为传奇般的专家所需要的实际练习时间。而TED 演讲者 Josh Kaufman 发现，从客观掌握一项技能来看，大概只需要20 小时的练习时间。',
                    style: TextStyle(
                      fontSize: 15,
                      color: subTextColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '比如说，如果从零开始刚好用了20小时ppt，那么你大概率已经掌握ppt这项技能了。\nT20就是这样一个专门计算20小时的软件。',
                    style: TextStyle(
                      fontSize: 15,
                      color: subTextColor,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 链接区域
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? kCardDark : kCardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.link, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '演讲的bilibili链接：',
                      style: TextStyle(
                        fontSize: 15,
                        color: subTextColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        const ClipboardData(
                          text:
                              'https://www.bilibili.com/video/BV144411b7Uk/?spm_id_from=333.337.search-card.all.click&vd_source=83088a58ad42455867fdcaa59412bf93',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('链接已复制到剪贴板'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '点击复制链接',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.copy, size: 16, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 理论说明区域
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? kCardDark : kCardLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '理论说明',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 原视频说明
                  _buildTheorySection(
                    context,
                    '在原视频中，20小时的意思是：',
                    [
                      '第1.找3-5个你选定的优质学习资源。',
                      '第2.学习它们。',
                      '第3.实际练习。（☚Josh 的意思是从这里开始计算20小时）',
                    ],
                    isDark,
                    textColor,
                    subTextColor,
                  ),

                  const SizedBox(height: 20),

                  // 我的看法
                  _buildTheorySection(
                    context,
                    '我的看法是',
                    [
                      '第1.找3-5个你选定的优质学习资源。',
                      '第2.学习它们。（☚从这里就可以开始计算20小时）',
                      '第3.实际练习。',
                    ],
                    isDark,
                    textColor,
                    subTextColor,
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Text(
                      '这样减轻了起步的心理门槛，况且对于大多数技能（比如：如何煮汤）来说，可能学3-6小时就完全懂了。\n对于像建模和编程这类技能，20小时也足够跨越完全不懂的阶段啦。',
                      style: TextStyle(
                        fontSize: 15,
                        color: subTextColor,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '不必被精确限制，比如大概学了30分钟，但是忘记计时了，可以长按技能手动补上30分钟。',
                            style: TextStyle(
                              fontSize: 15,
                              color: subTextColor,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 功能介绍区域
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? kCardDark : kCardLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.featured_play_list,
                        color: Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '功能介绍',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildFeatureCard(
              context,
              '功能1：开始计时',
              'assets/images/instructions/a1.webp',
              isDark,
              textColor,
              subTextColor,
            ),

            const SizedBox(height: 16),

            _buildFeatureCard(
              context,
              '功能2：长按调整时间',
              'assets/images/instructions/a2.webp',
              isDark,
              textColor,
              subTextColor,
            ),

            const SizedBox(height: 16),

            _buildFeatureCard(
              context,
              '功能3：单击技能可以写小日记',
              'assets/images/instructions/a3.webp',
              isDark,
              textColor,
              subTextColor,
            ),

            const SizedBox(height: 12),

            _buildFeatureCard(
              context,
              '功能4：右上角有新建技能的按钮',
              'assets/images/instructions/a4.webp',
              isDark,
              textColor,
              subTextColor,
            ),

            const SizedBox(height: 30),

            _buildFeatureCardWithDescription(
              context,
              '功能5：滑动技能可以移入移出殿堂',
              '荣耀殿堂是一个专门放那些已完成技能的地方。',
              'assets/images/instructions/a5.webp',
              isDark,
              textColor,
              subTextColor,
            ),

            const SizedBox(height: 16),

            _buildFeatureCard(
              context,
              '功能6：设置界面可以自定义侧边栏背景与头像，ID',
              'assets/images/instructions/a6.webp',
              isDark,
              textColor,
              subTextColor,
            ),

            const SizedBox(height: 16),

            _buildFeatureCard(
              context,
              '功能7：设置中可以导出当前配置',
              'assets/images/instructions/a7.webp',
              isDark,
              textColor,
              subTextColor,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // 构建功能卡片的辅助方法
  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String imagePath,
    bool isDark,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? kCardDark : kCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.grey.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: 200,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('图片加载错误: $error');
                  return Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 32,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '图片加载失败\n${imagePath.split('/').last}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建带描述的功能卡片
  Widget _buildFeatureCardWithDescription(
    BuildContext context,
    String title,
    String description,
    String imagePath,
    bool isDark,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? kCardDark : kCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.grey.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: subTextColor,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: 200,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('图片加载错误: $error');
                  return Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 32,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '图片加载失败\n${imagePath.split('/').last}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建理论说明部分的辅助方法
  Widget _buildTheorySection(
    BuildContext context,
    String title,
    List<String> points,
    bool isDark,
    Color textColor,
    Color subTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey.withOpacity(0.1)
                : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: points
                .map(
                  (point) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      point,
                      style: TextStyle(
                        fontSize: 15,
                        color: subTextColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
