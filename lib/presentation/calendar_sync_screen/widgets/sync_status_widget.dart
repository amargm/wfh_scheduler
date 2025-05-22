import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SyncStatusWidget extends StatelessWidget {
  final DateTime? lastSyncTime;
  final String syncStatus;
  final String? errorMessage;
  final VoidCallback onRetry;

  const SyncStatusWidget({
    super.key,
    required this.lastSyncTime,
    required this.syncStatus,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasError = syncStatus == 'error';
    final bool hasSuccess = syncStatus == 'success';
    final bool hasSynced = lastSyncTime != null;

    Color statusColor = AppTheme.textSecondary;
    String statusText = 'Not synced yet';
    String iconName = 'sync_disabled';

    if (hasError) {
      statusColor = AppTheme.error;
      statusText = 'Sync failed';
      iconName = 'error_outline';
    } else if (hasSuccess) {
      statusColor = AppTheme.success;
      statusText = 'Sync successful';
      iconName = 'check_circle_outline';
    } else if (hasSynced) {
      statusColor = AppTheme.info;
      statusText = 'Last synced';
      iconName = 'access_time';
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
                CustomIconWidget(
                  iconName: 'sync',
                  color: AppTheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Sync Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: iconName,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        hasSynced
                            ? 'Last sync: ${_formatDateTime(lastSyncTime!)}'
                            : 'No sync history available',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasError && errorMessage != null) ...[
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.error.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.error.withAlpha(77)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'error',
                          color: AppTheme.error,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Error Details',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.error,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    SizedBox(height: 1.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: onRetry,
                        icon: const CustomIconWidget(
                          iconName: 'refresh',
                          color: AppTheme.error,
                          size: 18,
                        ),
                        label: Text(
                          'Retry Sync',
                          style: TextStyle(color: AppTheme.error),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                          backgroundColor: AppTheme.error.withAlpha(26),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (hasSuccess) ...[
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.success.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.success.withAlpha(77)),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: AppTheme.success,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'All calendars are in sync',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.success,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return 'Today at ${DateFormat('h:mm a').format(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('h:mm a').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${DateFormat('EEEE').format(dateTime)} at ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      return DateFormat('MMM d, yyyy, h:mm a').format(dateTime);
    }
  }
}