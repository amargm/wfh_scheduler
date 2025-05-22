import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProgressTrackerWidget extends StatelessWidget {
  final int currentPercentage;
  final int targetPercentage;

  const ProgressTrackerWidget({
    super.key,
    required this.currentPercentage,
    required this.targetPercentage,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress percentage (capped at 100%)
    final progressPercentage = (currentPercentage / targetPercentage) * 100;
    final cappedProgress = progressPercentage > 100 ? 100.0 : progressPercentage;
    
    // Determine status color based on progress
    Color statusColor;
    String statusText;
    
    if (currentPercentage >= targetPercentage) {
      statusColor = AppTheme.success;
      statusText = 'On Track';
    } else if (currentPercentage >= targetPercentage * 0.7) {
      statusColor = AppTheme.warning;
      statusText = 'Almost There';
    } else {
      statusColor = AppTheme.error;
      statusText = 'Needs Attention';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'WFO Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: currentPercentage >= targetPercentage
                            ? 'check_circle'
                            : 'info',
                        color: statusColor,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '$currentPercentage%',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 8.h,
                  width: 1,
                  color: AppTheme.border,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Text(
                          'Target',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Text(
                          '$targetPercentage%',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Stack(
              children: [
                // Background track
                Container(
                  height: 1.5.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Progress indicator
                Container(
                  height: 1.5.h,
                  width: (cappedProgress / 100) * 90.w,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withAlpha(179),
                        statusColor,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
                // Target marker
                Positioned(
                  left: (targetPercentage / 100) * 90.w,
                  child: Container(
                    height: 1.5.h,
                    width: 2,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              'Monthly WFO percentage: $currentPercentage% of $targetPercentage% target',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}