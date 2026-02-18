import 'package:flutter/material.dart';
import '../../../../core/theme/color_scheme.dart';

class RevenueChart extends StatelessWidget {
  final List<double> trends;
  final double height;

  const RevenueChart({super.key, required this.trends, this.height = 150});

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) return const SizedBox.shrink();

    final maxVal = trends.reduce((a, b) => a > b ? a : b);

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: trends.asMap().entries.map((entry) {
          final double val = entry.value;
          final double barHeight = (val / maxVal) * (height - 20);

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 32,
                height: barHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.7),
                      AppColors.accent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getMonthLabel(entry.key, trends.length),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getMonthLabel(int index, int total) {
    final now = DateTime.now();
    final monthDate = DateTime(now.year, now.month - (total - 1 - index), 1);
    final List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[monthDate.month - 1];
  }
}
