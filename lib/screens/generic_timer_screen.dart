import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart'; // 移除音效播放器相关依赖
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

  // 移除音效播放器相关变量
  // final AudioPlayer _audioPlayer = AudioPlayer();
  // bool _isTickPlaying = false;

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
    // _audioPlayer.dispose(); // 移除音效播放器释放
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
        // 移除每秒播放音效
        // if (_stopwatch.elapsedMilliseconds % 1000 < 60) {
        //   _playTickSound();
        // }
      }
    });
  }

  // 停止计时
  void _stopTimer() {
    _stopwatch.stop();
    _timer?.cancel();
    // _audioPlayer.stop(); // 移除音效播放器停止
  }

  // 移除音效相关方法
  // Future<void> _playTickSound() async { ... }

  // 格式化时间显示
  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // 格式化时间显示，返回主时间和毫秒部分
  List<String> _formatTimeParts(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String oneDigitMillis = (duration.inMilliseconds % 1000 ~/ 100).toString();
    return [
      "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds",
      ".$oneDigitMillis",
    ];
  }

  // 结束计时
  void _finishTiming() async {
    _stopTimer();

    // 检查是否有计时时间
    final elapsedTime = _stopwatch.elapsed;
    if (elapsedTime.inSeconds == 0) {
      // 没有计时，直接退出
      debugPrint('No timing recorded, exiting timer page');
      Navigator.of(context).pop();
      return;
    }

    // 有计时时间，弹出技能选择对话框
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          SkillSelectDialog(skills: _skills, duration: elapsedTime),
    );

    // 如果用户选择了技能，返回结果；如果取消，直接退出
    debugPrint('Dialog result: $result');
    if (result != null && result['skillIndex'] != null) {
      debugPrint('User selected skill: ${result['skillIndex']}');
      Navigator.of(context).pop({
        'skillIndex': result['skillIndex'],
        'duration': elapsedTime.inSeconds,
      });
    } else {
      debugPrint('User cancelled, exiting timer page');
      // 用户取消，直接退出计时页面
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeParts = _formatTimeParts(_stopwatch.elapsed);
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
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: timeParts[0],
                              style: const TextStyle(
                                fontSize: 54,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: timeParts[1],
                              style: const TextStyle(
                                fontSize: 27, // 一半字号
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8, // 缩小宽度
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6, // 缩小高度
        ),
        padding: const EdgeInsets.all(16), // 缩小内边距
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
                  size: 24, // 缩小图标
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '选择归属技能',
                    style: TextStyle(
                      fontSize: 20, // 缩小标题字号
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? kTextMainDark
                          : kTextMain,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '本次计时：${_formatDuration(widget.duration)}',
              style: TextStyle(
                fontSize: 13, // 缩小副标题字号
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextSubDark
                    : kTextSub,
              ),
            ),
            const SizedBox(height: 12),

            // 技能列表
            if (widget.skills.isEmpty)
              _buildEmptyState()
            else
              Expanded(child: _buildSkillsList()),

            const SizedBox(height: 16),

            // 按钮区域
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('取消', style: TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedIndex == null
                        ? null
                        : () => Navigator.of(
                            context,
                          ).pop({'skillIndex': _selectedIndex}),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('确认归属', style: TextStyle(fontSize: 14)),
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
      separatorBuilder: (context, index) => const SizedBox(height: 8), // 缩小间距
      itemBuilder: (context, index) {
        final skill = widget.skills[index];
        final isSelected = _selectedIndex == index;

        return Container(
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12), // 缩小圆角
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
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _selectedIndex = index),
              child: Padding(
                padding: const EdgeInsets.all(12), // 缩小内边距
                child: Row(
                  children: [
                    // 选择指示器
                    Container(
                      width: 18,
                      height: 18,
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
                              size: 12,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),

                    // 技能信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            skill.name,
                            style: TextStyle(
                              fontSize: 15, // 缩小主字号
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? kTextMainDark
                                        : kTextMain),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '总计时：${skill.formattedTime}',
                            style: TextStyle(
                              fontSize: 12, // 缩小副字号
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
                      size: 12, // 缩小箭头
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
