import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../main.dart';
import 'dart:math';

// 通用计时页面，提供计时功能
class GenericTimerScreen extends StatefulWidget {
  const GenericTimerScreen({super.key});

  @override
  State<GenericTimerScreen> createState() => _GenericTimerScreenState();
}

// GenericTimerScreen的状态管理
class _GenericTimerScreenState extends State<GenericTimerScreen>
    with TickerProviderStateMixin {
  // 计时器对象
  Timer? _timer;
  // 秒表对象
  final Stopwatch _stopwatch = Stopwatch();
  // 显示的时间字符串
  String _displayTime = '00:00:00';
  // 是否正在计时
  bool _isTimerRunning = false;
  // 是否已结束计时
  bool _isFinished = false;

  // 虚线旋转动画控制器
  late AnimationController _rotationController;
  // 当前虚线环的角度进度
  double _rotationValue = 0.0;
  // 当前虚线区域的起始角度（随机）
  double _dashStartAngle = 0.0;
  // 已废弃缩放动画
  // 音效播放器
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60), // 60秒一圈
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _rotationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // 切换计时/暂停
  void _toggleTimer() {
    setState(() {
      _isTimerRunning = !_isTimerRunning;
    });
    if (_isTimerRunning) {
      _startTimer();
      _rotationController.repeat();
    } else {
      _stopTimer();
      _rotationController.stop();
    }
  }

  // 开始计时
  void _startTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          _displayTime = _formatTime(_stopwatch.elapsed);
        });
        // 每秒整点播放一次音效，并让虚线环跳动和随机浮动
        if (_stopwatch.elapsedMilliseconds % 1000 < 60) {
          _playTickSound();
          _rotationValue += 4 / 60; // 每秒转动4/60圈
          if (_rotationValue >= 1.0) _rotationValue -= 1.0;
          _rotationController.value = _rotationValue;
          // 随机一个新的起始角度
          _dashStartAngle = Random().nextDouble() * 2 * pi;
        }
      }
    });
  }

  // 停止计时
  void _stopTimer() {
    _stopwatch.stop();
    _timer?.cancel();
    _audioPlayer.stop();
  }

  // 播放滴答音效
  Future<void> _playTickSound() async {
    await _audioPlayer.play(AssetSource('tick_cold.wav'), volume: 0.18);
  }

  // 格式化时间显示
  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // 结束计时
  void _finishTiming() {
    _stopTimer();
    setState(() {
      _isFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('计时中')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 动态虚线旋转波纹+计时数字
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 静态完整圆环
                  CustomPaint(
                    size: const Size(200, 200),
                    painter: DashedCirclePainter(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? kCardDark.withOpacity(0.5)
                          : kButtonLight.withOpacity(0.5),
                      dashCount: 120,
                      dashWidth: 2,
                      dashSpace: 2,
                      strokeWidth: 4,
                      arcFraction: 1.0,
                      startAngle: 0.0,
                    ),
                  ),
                  // 动态虚线区域
                  AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationController.value * 2 * pi,
                        child: CustomPaint(
                          size: const Size(200, 200),
                          painter: DashedCirclePainter(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? kButtonDark
                                : kPrimaryColor,
                            dashCount: 15, // 只占1/4圆周
                            dashWidth: 8,
                            dashSpace: 7,
                            strokeWidth: 5,
                            arcFraction: 0.25, // 只画1/4圆
                            startAngle: _dashStartAngle,
                          ),
                        ),
                      );
                    },
                  ),
                  // 计时数字自适应居中且不会溢出
                  SizedBox(
                    width: 150,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _displayTime,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            if (_isFinished)
              _buildAttributionControls()
            else
              _buildTimerControls(),
          ],
        ),
      ),
    );
  }

  // 构建计时控制按钮
  Widget _buildTimerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _toggleTimer,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isTimerRunning
                ? Colors.orangeAccent
                : Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: Text(
            _isTimerRunning ? '暂停' : '开始',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          onPressed: _finishTiming,
          child: const Text('结束', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  // 构建归属控制按钮
  Widget _buildAttributionControls() {
    return Column(
      children: [
        const Text('将本次记录归属到:'),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('放弃记录'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                // 这里可以实现弹出技能选择器并返回计时结果
              },
              child: const Text('确认归属'),
            ),
          ],
        ),
      ],
    );
  }
}

// 虚线圆环Painter
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final int dashCount;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;
  final double arcFraction; // 只画圆的一部分
  final double startAngle; // 起始角度
  DashedCirclePainter({
    required this.color,
    this.dashCount = 15,
    this.dashWidth = 8,
    this.dashSpace = 7,
    this.strokeWidth = 5,
    this.arcFraction = 1.0,
    this.startAngle = 0.0,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final double radius = size.width / 2 - strokeWidth;
    final double totalAngle = 2 * pi * arcFraction;
    final double gap = dashSpace + dashWidth;
    final double arcLength = totalAngle * radius;
    final int count = dashCount;
    double currentLength = 0;
    for (int i = 0; i < count; i++) {
      final double segStartAngle = startAngle + (currentLength / radius);
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: radius,
        ),
        segStartAngle,
        dashWidth / radius,
        false,
        paint,
      );
      currentLength += gap;
      if (currentLength > arcLength) break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
