import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalendarProviderCard extends StatelessWidget {
  final String provider;
  final String iconName;
  final bool isConnected;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final bool isLoading;

  const CalendarProviderCard({
    super.key,
    required this.provider,
    required this.iconName,
    required this.isConnected,
    required this.onConnect,
    required this.onDisconnect,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isConnected ? AppTheme.primary : AppTheme.border,
          width: isConnected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: isConnected 
                        ? AppTheme.primary.withAlpha(26) 
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isConnected ? AppTheme.primary : AppTheme.border,
                    ),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: iconName,
                      color: isConnected ? AppTheme.primary : AppTheme.textSecondary,
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$provider Calendar',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isConnected ? AppTheme.success : AppTheme.textTertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            isConnected ? 'Connected' : 'Not Connected',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isConnected ? AppTheme.success : AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isConnected,
                  onChanged: isLoading 
                      ? null 
                      : (value) {
                          if (value) {
                            onConnect();
                          } else {
                            onDisconnect();
                          }
                        },
                  activeColor: AppTheme.primary,
                ),
              ],
            ),
            if (isConnected) ...[
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.info.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'info',
                            color: AppTheme.info,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Flexible(
                            child: Text(
                              'Syncing events from $provider',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.info,
                                    fontWeight: FontWeight.w500,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  TextButton(
                    onPressed: isLoading ? null : onDisconnect,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.error,
                    ),
                    child: Text('Disconnect'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}