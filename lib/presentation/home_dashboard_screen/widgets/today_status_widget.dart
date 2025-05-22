import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TodayStatusWidget extends StatelessWidget {
  final String status;
  final bool isCheckedIn;
  final VoidCallback onCheckIn;

  const TodayStatusWidget({
    super.key,
    required this.status,
    required this.isCheckedIn,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateFormat('EEEE, MMMM d').format(now);
    
    // Determine status details
    String statusTitle;
    String statusDescription;
    Color statusColor;
    String iconName;
    
    switch (status.toLowerCase()) {
      case 'wfh':
        statusTitle = 'Working from Home';
        statusDescription = 'You\'re working remotely today';
        statusColor = AppTheme.wfh;
        iconName = 'home';
        break;
      case 'wfo':
        statusTitle = 'Working from Office';
        statusDescription = 'You\'re at the office today';
        statusColor = AppTheme.wfo;
        iconName = 'business';
        break;
      case 'leave':
        statusTitle = 'On Leave';
        statusDescription = 'You\'re taking a day off today';
        statusColor = AppTheme.leave;
        iconName = 'beach_access';
        break;
      default:
        statusTitle = 'Not Checked In';
        statusDescription = 'Please check in for today';
        statusColor = AppTheme.warning;
        iconName = 'help_outline';
        break;
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
              children: [
                Text(
                  'Today\'s Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                Text(
                  today,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: iconName,
                      color: statusColor,
                      size: 8.w.toDouble(),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        statusDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            if (!isCheckedIn)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCheckIn,
                  child: const Text('Check In Now'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onCheckIn,
                  child: const Text('Change Status'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}