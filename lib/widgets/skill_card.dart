import 'package:flutter/material.dart';
import '../models/skill_model.dart';
import '../main.dart';
import '../models/icon_map.dart';

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
      ..color = Colors.white.withValues(alpha: 0.3); // 提高透明度

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
  final VoidCallback? onTap;
  // 长按卡片时的回调
  final VoidCallback? onLongPress;

  // 构造函数，要求传入技能数据和回调
  const SkillCard({
    super.key,
    required this.skill,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<SkillCard> with TickerProviderStateMixin {
  AnimationController? _stripeController;
  AnimationController? _rainbowController;
  Animation<double>? _stripeAnimation;
  Animation<double>? _rainbowAnimation;

  @override
  void initState() {
    super.initState();
    _stripeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rainbowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _stripeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_stripeController!);

    _rainbowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rainbowController!);

    _stripeController!.repeat();
    _rainbowController!.repeat();
  }

  @override
  void dispose() {
    _stripeController?.dispose();
    _rainbowController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // 点击事件
      onTap: widget.onTap,
      // 长按事件
      onLongPress: widget.onLongPress,
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
                padding: const EdgeInsets.all(12),
                child: Icon(
                  skillIconMap[widget.skill.iconCodePoint] ??
                      Icons.help_outline,
                  color: Color(widget.skill.iconColor),
                  size: 28,
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
                    if (_stripeAnimation != null && _rainbowAnimation != null)
                      AnimatedBuilder(
                        animation: _stripeAnimation!,
                        builder: (context, child) {
                          return Container(
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? kCardDark
                                  : kButtonLight,
                            ),
                            child: CustomPaint(
                              painter: RainbowFlowProgressPainter(
                                progress: widget.skill.progressBasedOn20Hours,
                                animationValue: _stripeAnimation!.value,
                              ),
                              size: Size.infinite,
                            ),
                          );
                        },
                      )
                    else
                      // 静态进度条（当动画未初始化时）
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? kCardDark
                              : kButtonLight,
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: widget.skill.progressBasedOn20Hours,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: widget.skill.progressBasedOn20Hours > 0.8
                                  ? Colors.green
                                  : kPrimaryColor,
                            ),
                          ),
                        ),
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
}
