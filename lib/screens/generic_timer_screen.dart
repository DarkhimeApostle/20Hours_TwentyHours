import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:TwentyHours/models/skill_model.dart';
import 'package:TwentyHours/main.dart';

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

  List<Skill> _skills = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 获取传递过来的技能列表
    _skills =
        (ModalRoute.of(context)?.settings.arguments as List<Skill>?) ?? [];
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
  void _finishTiming() async {
    _stopTimer();
    setState(() {
      _isFinished = true;
    });
    // 直接传递技能列表给弹窗
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          SkillSelectDialog(skills: _skills, duration: _stopwatch.elapsed),
    );
    if (result != null && result['skillIndex'] != null) {
      Navigator.of(context).pop({
        'skillIndex': result['skillIndex'],
        'duration': _stopwatch.elapsed.inSeconds,
      });
    }
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

// 技能选择弹窗
class SkillSelectDialog extends StatefulWidget {
  final List<Skill> skills;
  final Duration duration;
  const SkillSelectDialog({required this.skills, required this.duration});
  @override
  State<SkillSelectDialog> createState() => _SkillSelectDialogState();
}

class _SkillSelectDialogState extends State<SkillSelectDialog> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题区域
            Row(
              children: [
                Icon(
                  Icons.timer,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '选择归属技能',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? kTextMainDark
                          : kTextMain,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '本次计时：${_formatDuration(widget.duration)}',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextSubDark
                    : kTextSub,
              ),
            ),
            const SizedBox(height: 24),

            // 技能列表
            if (widget.skills.isEmpty)
              _buildEmptyState()
            else
              Expanded(child: _buildSkillsList()),

            const SizedBox(height: 24),

            // 按钮区域
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('取消', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedIndex == null
                        ? null
                        : () => Navigator.of(
                            context,
                          ).pop({'skillIndex': _selectedIndex}),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('确认归属', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            '暂无技能',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            '请先添加一些技能',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // 构建技能列表
  Widget _buildSkillsList() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: widget.skills.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final skill = widget.skills[index];
        final isSelected = _selectedIndex == index;

        return Container(
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _selectedIndex = index),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // 选择指示器
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),

                    // 技能信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            skill.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? kTextMainDark
                                        : kTextMain),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '总计时：${skill.formattedTime}',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? kTextSubDark
                                  : kTextSub,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 箭头图标
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 格式化持续时间
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
