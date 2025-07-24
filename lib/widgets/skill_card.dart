import 'package:flutter/material.dart';
import 'package:TwentyHours/models/skill_model.dart';
import '../main.dart';
import 'dart:math';

// 条纹绘制器
class StripePainter extends CustomPainter {
  final Animation<double> animation;
  final double progress;
  final double stripeWidth;
  final double stripeSpacing;

  // 只保留带默认参数的构造函数
  StripePainter({
    required this.animation,
    required this.progress,
    this.stripeWidth = 12.0,
    this.stripeSpacing = 32.0,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // 让offset始终在0~stripeSpacing之间循环，实现无缝动画
    final offset = (animation.value * stripeSpacing) % stripeSpacing;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.3); // 提高透明度

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));

    for (
      double x = -stripeWidth + offset;
      x < size.width * progress;
      x += stripeSpacing
    ) {
      canvas.drawRect(Rect.fromLTWH(x, 0, stripeWidth, size.height), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StripePainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.progress != progress ||
        oldDelegate.stripeWidth != stripeWidth ||
        oldDelegate.stripeSpacing != stripeSpacing;
  }
}

// 新增：彩虹流动进度条Painter
class RainbowFlowProgressPainter extends CustomPainter {
  final double progress;
  final double animationValue;
  RainbowFlowProgressPainter({
    required this.progress,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width * progress;
    const int invisibleFactor = 10;
    // HSL色环插值生成36个彩虹色，首尾自然衔接
    final List<Color> rainbow = List.generate(36, (i) {
      final h = i * 10.0;
      return HSLColor.fromAHSL(1.0, h, 1.0, 0.5).toColor();
    });
    final double rainbowWidth = barWidth * 6;
    final double shift = -rainbowWidth + animationValue * (2 * rainbowWidth);
    final gradient = LinearGradient(
      colors: rainbow,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(shift, 0, rainbowWidth, size.height),
      );
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, barWidth, size.height));
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, barWidth, size.height),
      Radius.circular(3),
    );
    canvas.drawRRect(rrect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RainbowFlowProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue;
  }
}

// 技能卡片组件，用于展示技能信息
class SkillCard extends StatefulWidget {
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
  State<SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<SkillCard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _stripeAnimationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 进度条动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // 条纹动画控制器（持续循环）
    _stripeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 4800),
      vsync: this,
    );

    // 进度条动画
    _progressAnimation =
        Tween<double>(
          begin: 0.0,
          end: widget.skill.progressBasedOn20Hours,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // 脉冲动画（当进度接近完成时）
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 启动动画
    _animationController.forward();
    _stripeAnimationController.repeat(); // 条纹动画持续循环
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stripeAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SkillCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.skill.totalTime != widget.skill.totalTime) {
      // 当技能时间更新时，重新播放动画
      _progressAnimation =
          Tween<double>(
            begin: oldWidget.skill.progressBasedOn20Hours,
            end: widget.skill.progressBasedOn20Hours,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutCubic,
            ),
          );
      _animationController.forward(from: 0.0);
    }
    // 检查duration是否变化，强制重建动画控制器
    if (_stripeAnimationController.duration !=
        const Duration(milliseconds: 4800)) {
      _stripeAnimationController.dispose();
      _stripeAnimationController = AnimationController(
        duration: const Duration(milliseconds: 4800),
        vsync: this,
      )..repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // 点击事件
      onTap: widget.onCardTapped,
      // 长按事件
      onLongPress: widget.onCardLongPressed,
      // 卡片圆角
      borderRadius: BorderRadius.circular(20),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                padding: const EdgeInsets.all(10),
                child: Icon(
  widget.skill.icon,
  color: Color(widget.skill.iconColor),
  size: 24,
),
              ),
              const SizedBox(width: 16),
              // 技能名称和进度条
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.skill.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? kTextMainDark
                            : kTextMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.skill.formattedTime,
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? kTextSubDark
                                  : kTextSub,
                            ),
                          ),
                        ),
                        // 进度百分比
                        Text(
                          widget.skill.progressPercentage,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: widget.skill.progressBasedOn20Hours > 0.8
                                ? Colors.green
                                : Theme.of(context).brightness ==
                                      Brightness.dark
                                ? kTextSubDark
                                : kTextSub,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 动态进度条
                    AnimatedBuilder(
                      animation: _stripeAnimationController,
                      builder: (context, child) {
                        return Container(
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? kCardDark
                                : kButtonLight,
                          ),
                          child: CustomPaint(
                            painter: RainbowFlowProgressPainter(
                              progress: _progressAnimation.value,
                              animationValue: _stripeAnimationController.value,
                            ),
                            size: Size.infinite,
                          ),
                        );
                      },
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

  // 根据进度获取彩虹渐变色
  List<Color> _getProgressGradient(double progress) {
    // 彩虹色渐变
    return [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];
  }

  // 根据进度获取颜色
  Color _getProgressColor(double progress) {
    if (progress >= 0.8) {
      return Colors.green; // 接近完成时显示绿色
    } else if (progress >= 0.5) {
      return Colors.orange; // 过半时显示橙色
    } else {
      return kPrimaryColor; // 默认主题色
    }
  }
}
