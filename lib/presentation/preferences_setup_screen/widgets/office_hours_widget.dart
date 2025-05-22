import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OfficeHoursWidget extends StatelessWidget {
  final TimeOfDay arrivalTime;
  final TimeOfDay departureTime;
  final Function(TimeOfDay, TimeOfDay) onTimeChanged;

  const OfficeHoursWidget({
    super.key,
    required this.arrivalTime,
    required this.departureTime,
    required this.onTimeChanged,
  });

  Future<void> _selectTime(BuildContext context, bool isArrival) async {
    final TimeOfDay initialTime = isArrival ? arrivalTime : departureTime;
    
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              dayPeriodColor: AppTheme.surface,
              dayPeriodTextColor: AppTheme.textPrimary,
              hourMinuteColor: AppTheme.primary.withAlpha(26),
              hourMinuteTextColor: AppTheme.textPrimary,
              dialHandColor: AppTheme.primary,
              dialBackgroundColor: AppTheme.primary.withAlpha(26),
              hourMinuteTextStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              dayPeriodTextStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              helpTextStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.border),
                ),
                contentPadding: EdgeInsets.all(0),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      if (isArrival) {
        // Validate that arrival time is before departure time
        final now = DateTime.now();
        final arrivalDateTime = DateTime(
          now.year, now.month, now.day, 
          pickedTime.hour, pickedTime.minute
        );
        final departureDateTime = DateTime(
          now.year, now.month, now.day, 
          departureTime.hour, departureTime.minute
        );
        
        if (arrivalDateTime.isBefore(departureDateTime)) {
          onTimeChanged(pickedTime, departureTime);
        } else {
          // Show error message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Arrival time must be before departure time'),
                backgroundColor: AppTheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } else {
        // Validate that departure time is after arrival time
        final now = DateTime.now();
        final arrivalDateTime = DateTime(
          now.year, now.month, now.day, 
          arrivalTime.hour, arrivalTime.minute
        );
        final departureDateTime = DateTime(
          now.year, now.month, now.day, 
          pickedTime.hour, pickedTime.minute
        );
        
        if (departureDateTime.isAfter(arrivalDateTime)) {
          onTimeChanged(arrivalTime, pickedTime);
        } else {
          // Show error message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Departure time must be after arrival time'),
                backgroundColor: AppTheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Office Hours',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Set your typical office hours for WFO days',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildTimeSelector(
                context,
                'Arrival',
                _formatTimeOfDay(arrivalTime),
                () => _selectTime(context, true),
                'login',
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildTimeSelector(
                context,
                'Departure',
                _formatTimeOfDay(departureTime),
                () => _selectTime(context, false),
                'logout',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSelector(
    BuildContext context,
    String label,
    String time,
    VoidCallback onTap,
    String iconName,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: iconName,
                  color: AppTheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  time,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}