import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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

  // 音效播放器
  final AudioPlayer _audioPlayer = AudioPlayer();
  // 音效播放状态
  bool _isTickPlaying = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
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
    } else {
      _stopTimer();
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
        // 每秒整点播放一次音效
        if (_stopwatch.elapsedMilliseconds % 1000 < 60) {
          _playTickSound();
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
    try {
      if (!_isTickPlaying) {
        _isTickPlaying = true;
        await _audioPlayer.play(AssetSource('tick_cold.MP3'), volume: 0.18);
        _isTickPlaying = false;
      }
    } catch (e) {
      debugPrint('Tick sound error: $e');
      _isTickPlaying = false;
    }
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
            // 计时数字
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
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
