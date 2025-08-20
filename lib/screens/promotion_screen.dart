import 'package:flutter/material.dart';
import '../main.dart';

// 统计页面
class PromotionScreen extends StatelessWidget {
  const PromotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: kPrimaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              '数据统计',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kTextMainDark
                    : kTextMain,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '技能练习数据分�?,
              style: TextStyle(
                fontSize: 16,
                color: kTextSub,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? kCardDark
                    : kCardLight,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildStatItem(context, '总练习时�?, '0 小时', Icons.timer),
                  const SizedBox(height: 16),
                  _buildStatItem(context, '技能数�?, '0 �?, Icons.star),
                  const SizedBox(height: 16),
                  _buildStatItem(context, '完成目标', '0 �?, Icons.check_circle),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              '更多统计功能开发中...',
              style: TextStyle(
                fontSize: 14,
                color: kTextSub,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: kPrimaryColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: kTextSub,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kTextMainDark
                      : kTextMain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
