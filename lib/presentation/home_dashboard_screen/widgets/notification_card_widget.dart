import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationCardWidget extends StatelessWidget {
  final String type;
  final String title;
  final String message;
  final String actionText;
  final VoidCallback onAction;

  const NotificationCardWidget({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    // Determine notification color based on type
    Color notificationColor;
    String iconName;
    
    switch (type) {
      case 'success':
        notificationColor = AppTheme.success;
        iconName = 'check_circle';
        break;
      case 'warning':
        notificationColor = AppTheme.warning;
        iconName = 'warning';
        break;
      case 'error':
        notificationColor = AppTheme.error;
        iconName = 'error';
        break;
      case 'info':
      default:
        notificationColor = AppTheme.info;
        iconName = 'info';
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notificationColor.withAlpha(77),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: notificationColor.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: iconName,
                  color: notificationColor,
                  size: 5.w.toDouble(),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  SizedBox(height: 1.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onAction,
                      child: Text(actionText),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}