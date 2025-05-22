import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SyncPreferencesWidget extends StatelessWidget {
  final bool importHolidays;
  final bool exportWfhWfoStatus;
  final bool syncLeaves;
  final Function({bool? importHolidays, bool? exportWfhWfoStatus, bool? syncLeaves}) onPreferencesChanged;

  const SyncPreferencesWidget({
    super.key,
    required this.importHolidays,
    required this.exportWfhWfoStatus,
    required this.syncLeaves,
    required this.onPreferencesChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                  iconName: 'settings',
                  color: AppTheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Sync Preferences',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildPreferenceCheckbox(
              context,
              title: 'Import Holidays',
              subtitle: 'Add public holidays to your schedule',
              value: importHolidays,
              onChanged: (value) {
                if (value != null) {
                  onPreferencesChanged(importHolidays: value);
                }
              },
              iconName: 'celebration',
            ),
            Divider(height: 3.h, thickness: 1),
            _buildPreferenceCheckbox(
              context,
              title: 'Export WFH/WFO Status',
              subtitle: 'Add your work status to calendar events',
              value: exportWfhWfoStatus,
              onChanged: (value) {
                if (value != null) {
                  onPreferencesChanged(exportWfhWfoStatus: value);
                }
              },
              iconName: 'work',
            ),
            Divider(height: 3.h, thickness: 1),
            _buildPreferenceCheckbox(
              context,
              title: 'Sync Leaves',
              subtitle: 'Synchronize leave days with your calendar',
              value: syncLeaves,
              onChanged: (value) {
                if (value != null) {
                  onPreferencesChanged(syncLeaves: value);
                }
              },
              iconName: 'event_busy',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceCheckbox(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String iconName,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: value ? AppTheme.primary.withAlpha(26) : AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: value ? AppTheme.primary : AppTheme.border,
            ),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: iconName,
              color: value ? AppTheme.primary : AppTheme.textSecondary,
              size: 20,
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
                      fontWeight: FontWeight.w500,
                    ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primary,
        ),
      ],
    );
  }
}