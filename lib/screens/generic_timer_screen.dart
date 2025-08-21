import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart'; // 移除音效播放器相关依赖
import '../models/skill_model.dart';
import '../models/icon_map.dart';
import '../main.dart';

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
  // 是否正在计时
  bool _isTimerRunning = false;

  // 动画控制器
  AnimationController? _pulseController;
  AnimationController? _scaleController;
  AnimationController? _rotateController;
  Animation<double>? _pulseAnimation;
  Animation<double>? _scaleAnimation;
  Animation<double>? _rotateAnimation;

  // 移除音效播放器相关变量
  // final AudioPlayer _audioPlayer = AudioPlayer();
  // bool _isTickPlaying = false;

  List<Skill> _skills = [];

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 初始化动画
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _scaleController!, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _rotateController!, curve: Curves.easeInOut),
    );
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

    // 释放动画控制器
    _pulseController?.dispose();
    _scaleController?.dispose();
    _rotateController?.dispose();

    super.dispose();
  }

  // 切换计时/暂停
  void _toggleTimer() {
    // 播放按钮点击动画 - 更明显的缩放效果
    _scaleController?.forward().then((_) {
      _scaleController?.reverse();
    });

    setState(() {
      _isTimerRunning = !_isTimerRunning;
    });

    if (_isTimerRunning) {
      _startTimer();
      // 移除持续脉冲动画，只在点击时有反馈
    } else {
      _stopTimer();
      // 移除脉冲动画相关代码
    }
  }

  // 开始计时
  void _startTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          // 触发UI更新以刷新计时显示
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
    // 播放结束按钮动画
    _rotateController?.forward().then((_) {
      _rotateController?.reverse();
    });

    _stopTimer();

    // 移除脉冲动画相关代码

    // 检查是否有计时时间
    final elapsedTime = _stopwatch.elapsed;
    if (elapsedTime.inSeconds == 0) {
      // 没有计时，直接退出

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

    if (mounted) {
      if (result != null && result['skillIndex'] != null) {
        Navigator.of(context).pop({
          'skillIndex': result['skillIndex'],
          'duration': elapsedTime.inSeconds,
        });
      } else {
        // 用户取消，直接退出计时页面
        Navigator.of(context).pop();
      }
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
            _buildTimerControls(
              endButtonVerticalOffset: 5.0,
            ), // 可以通过这个参数调整结束按钮的上下距离
          ],
        ),
      ),
    );
  }

  // 构建计时控制按钮
  Widget _buildTimerControls({double endButtonVerticalOffset = 0.0}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20), // 整体下移
      child: Stack(
        children: [
          // 开始/暂停按钮 - 居中
          Center(
            child: AnimatedBuilder(
              animation: _scaleAnimation ?? const AlwaysStoppedAnimation(1.0),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation?.value ?? 1.0,
                  child: ElevatedButton(
                    onPressed: _toggleTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isTimerRunning
                          ? Colors.orangeAccent
                          : Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.all(24),
                      shape: const CircleBorder(),
                      minimumSize: const Size(100, 100),
                      elevation: _isTimerRunning ? 8 : 4,
                      shadowColor: _isTimerRunning
                          ? Colors.orangeAccent.withValues(alpha: 0.3)
                          : Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isTimerRunning ? Icons.pause : Icons.play_arrow,
                          size: 70,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isTimerRunning ? '暂停' : '开始',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(139, 255, 255, 255),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'sans-serif',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // 结束按钮 - 在开始按钮右边，可调整上下距离
          Positioned(
            right: 40,
            top: 50 + endButtonVerticalOffset, // 可调整的上下距离
            child: AnimatedBuilder(
              animation: _rotateAnimation ?? const AlwaysStoppedAnimation(0.0),
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateAnimation?.value ?? 0.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.all(20),
                      shape: const CircleBorder(),
                      minimumSize: const Size(60, 60),
                      elevation: 4,
                      shadowColor: Colors.redAccent.withValues(alpha: 0.3),
                    ),
                    onPressed: _finishTiming,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.stop,
                          size: 24,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '结束',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(131, 255, 255, 255),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'sans-serif',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 技能选择弹窗
class SkillSelectDialog extends StatefulWidget {
  final List<Skill> skills;
  final Duration duration;
  const SkillSelectDialog({
    super.key,
    required this.skills,
    required this.duration,
  });
  @override
  State<SkillSelectDialog> createState() => _SkillSelectDialogState();
}

class _SkillSelectDialogState extends State<SkillSelectDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 24,
      ), // 减少边距
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.99, // 进一步增加宽度
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8, // 增加高度
        ),
        padding: const EdgeInsets.all(20), // 增加内边距
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
                  size: 28, // 增加图标大小
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '选择计时对象',
                    style: TextStyle(
                      fontSize: 22, // 增加标题字号
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
                fontSize: 15, // 增加副标题字号
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextSubDark
                    : kTextSub,
              ),
            ),
            const SizedBox(height: 16),

            // 技能列表
            if (widget.skills.isEmpty)
              _buildEmptyState()
            else if (widget.skills.every(
              (skill) =>
                  skill.progressBasedOn20Hours >= 1.0 || skill.inHallOfGlory,
            ))
              _buildAllCompletedState()
            else
              Expanded(child: _buildSkillsList()),

            const SizedBox(height: 16),

            // 只保留取消按钮
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('取消', style: TextStyle(fontSize: 16)),
              ),
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

  // 构建全部完成状态
  Widget _buildAllCompletedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, size: 64, color: Colors.amber.shade400),
          const SizedBox(height: 16),
          Text(
            '所有技能已完成！',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            '您的技能都已进入荣耀殿堂',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // 构建技能列表
  Widget _buildSkillsList() {
    // 过滤掉已经达到100%的技能（进入荣耀殿堂的技能）
    final availableSkills = widget.skills
        .where(
          (skill) => skill.progressBasedOn20Hours < 1.0 && !skill.inHallOfGlory,
        )
        .toList();

    return ListView.separated(
      shrinkWrap: true,
      itemCount: availableSkills.length,
      separatorBuilder: (context, index) => const SizedBox(height: 6), // 更紧凑的间距
      itemBuilder: (context, index) {
        final skill = availableSkills[index];

        return GestureDetector(
          onTap: () {
            // 点击技能后立即归属
            // 找到原始技能列表中的索引
            final originalIndex = widget.skills.indexOf(skill);
            Navigator.of(context).pop({'skillIndex': originalIndex});
          },
          child: Container(
            width: double.infinity,
            height: 52, // 固定高度，更紧凑
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                // 技能图标
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(skill.iconColor).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    skillIconMap[skill.iconCodePoint] ?? Icons.help_outline,
                    color: Color(skill.iconColor),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                // 技能信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        skill.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? kTextMainDark
                              : kTextMain,
                        ),
                        maxLines: 1, // 单行显示
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        skill.formattedTime,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).brightness == Brightness.dark
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
                  size: 12,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 16),
              ],
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
