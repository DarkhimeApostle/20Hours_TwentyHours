import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';

class InstructionScreen extends StatelessWidget {
  const InstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? kBackgroundDark
          : kBackgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '传统10000小时（一万小时）学习理论，指的是成为传奇般的专家所需要的实际练习时间。而TED 演讲者 Josh Kaufman 发现，从客观掌握一项技能来看，大概只需要20 小时的练习时间。\n\n比如说，如果你花了20小时使用ppt，那么你大概率已经掌握ppt这项技能了。\nT20就是一个专门进行20小时计时的软件。',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextSubDark
                    : kTextSub,
                height: 1.4,
              ),
            ),

            Row(
              children: [
                Text(
                  '演讲的bilibili链接：',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? kTextSubDark
                        : kTextSub,
                    height: 1.4,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      const ClipboardData(
                        text:
                            'https://www.bilibili.com/video/BV144411b7Uk/?spm_id_from=333.337.search-card.all.click&vd_source=83088a58ad42455867fdcaa59412bf93',
                      ),
                    );
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('链接已复制到剪贴板')));
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '点击复制链接',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.copy, size: 16, color: Colors.blue),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              '在原视频中，20小时的意思是：',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextMainDark
                    : kTextMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '第1.找3-5个你选定的优质学习资源。\n第2.学习它们。\n第3.实际练习。（☚Josh 的意思是从这里开始计算20小时）',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextSubDark
                    : kTextSub,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              '我的看法是',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextMainDark
                    : kTextMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '第1.找3-5个你选定的优质学习资源。\n第2.学习它们。（☚从这里就可以开始计算20小时）\n第3.实际练习。',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextSubDark
                    : kTextSub,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 8),
            Text(
              '这样虽然降低20小时的理论质量，但其实大量减轻了起步的心理门槛，况且对于大多数技能（比如：如何煮汤）来说，可能学3-6小时就完全懂了。\n对于像建模和编程这类技能，20小时也足够跨越完全不懂的阶段啦。',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextSubDark
                    : kTextSub,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              '不必被精确限制，比如大概学了30分钟，但是忘记计时了，可以长按技能手动补上30分钟。',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextSubDark
                    : kTextSub,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              '功能介绍',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextMainDark
                    : kTextMain,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              '功能1：开始计时',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextMainDark
                    : kTextMain,
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Image.asset(
                'assets/images/instructions/a1.webp',
                width: 200,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('图片加载错误: $error');
                  return Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 32,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '图片加载失败\na1.webp',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Text(
              '功能2：长按调整时间',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextMainDark
                    : kTextMain,
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Image.asset(
                'assets/images/instructions/a2.webp',
                width: 200,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('图片加载错误: $error');
                  return Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 32,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '图片加载失败\na2.webp',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Text(
              '功能3：单击技能可以写小日记',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextMainDark
                    : kTextMain,
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Image.asset(
                'assets/images/instructions/a3.webp',
                width: 200,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('图片加载错误: $error');
                  return Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 32,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '图片加载失败\na3.webp',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            Text(
              '功能4：右上角有新建技能的按钮',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextMainDark
                    : kTextMain,
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Image.asset(
                'assets/images/instructions/a4.webp',
                width: 200,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('图片加载错误: $error');
                  return Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        '图片加载失败\na4.webp',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            Text(
              '功能5：滑动技能可以移入移出殿堂',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextMainDark
                    : kTextMain,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              '荣耀殿堂是一个专门放那些已完成技能的地方。',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextSubDark
                    : kTextSub,
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Image.asset(
                'assets/images/instructions/a5.webp',
                width: 200,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('图片加载错误: $error');
                  return Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 32,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '图片加载失败\na5.webp',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Text(
              '功能6：设置界面可以自定义侧边栏背景与头像，ID',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextMainDark
                    : kTextMain,
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Image.asset(
                'assets/images/instructions/a6.webp',
                width: 200,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('图片加载错误: $error');
                  return Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 32,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '图片加载失败\na6.webp',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Text(
              '功能7：设置中可以导出当前配置',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextMainDark
                    : kTextMain,
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Image.asset(
                'assets/images/instructions/a7.webp',
                width: 200,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('图片加载错误: $error');
                  return Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        '图片加载失败\na7.webp',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
