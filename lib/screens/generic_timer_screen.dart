import 'dart:async';
import 'package:flutter/material.dart';

// 这是一个通用的计时页面
class GenericTimerScreen extends StatefulWidget {
  const GenericTimerScreen({super.key});

  @override
  State<GenericTimerScreen> createState() => _GenericTimerScreenState();
}

class _GenericTimerScreenState extends State<GenericTimerScreen> {
  // ===========================================================================
  // 1. 状态变量
  // ===========================================================================
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  String _displayTime = '00:00:00';
  bool _isTimerRunning = false;
  // 一个新的状态，用于控制显示“计时中”还是“归属”的UI
  bool _isFinished = false;

  // ===========================================================================
  // 2. 生命周期方法
  // ===========================================================================
  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  // ===========================================================================
  // 3. 核心逻辑方法
  // ===========================================================================
  void _toggleTimer() {
    setState(() {
      _isTimerRunning = !_isTimerRunning;
    });
    if (_isTimerRunning) {
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  void _startTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          _displayTime = _formatTime(_stopwatch.elapsed);
        });
      }
    });
  }

  void _stopTimer() {
    _stopwatch.stop();
    _timer?.cancel();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _finishTiming() {
    _stopTimer();
    setState(() {
      _isFinished = true;
    });
  }

  // ===========================================================================
  // 4. UI 构建方法
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('计时中')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _displayTime,
              style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w200),
            ),
            const SizedBox(height: 40),
            // 根据是否已结束 (_isFinished)，来动态显示不同的控制按钮
            if (_isFinished)
              _buildAttributionControls()
            else
              _buildTimerControls(),
          ],
        ),
      ),
    );
  }

  // 一个专门用于构建“计时中”控制按钮的私有方法
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
          onPressed: _finishTiming, // 点击时，调用_finishTiming方法
          child: const Text('结束', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  // 一个专门用于构建“归属”控制按钮的私有方法
  Widget _buildAttributionControls() {
    return Column(
      children: [
        const Text('将本次记录归属到:'),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // 点击时，直接返回，不带任何数据
              child: const Text('放弃记录'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: 实现弹出技能选择器，并返回计时结果
              },
              child: const Text('确认归属'),
            ),
          ],
        ),
      ],
    );
  }
}
