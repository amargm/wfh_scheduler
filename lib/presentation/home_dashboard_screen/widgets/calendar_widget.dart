import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime selectedMonth;
  final Map<DateTime, String> scheduleData;

  const CalendarWidget({
    super.key,
    required this.selectedMonth,
    required this.scheduleData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          // Weekday headers
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Row(
              children: _buildWeekdayHeaders(context),
            ),
          ),
          
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 0.5.h,
              crossAxisSpacing: 0.5.w,
            ),
            itemCount: _getDaysInMonth() + _getFirstDayOffset(),
            itemBuilder: (context, index) {
              return _buildCalendarDay(context, index);
            },
          ),
          
          // Legend
          Padding(
            padding: EdgeInsets.all(2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(context, 'WFH', AppTheme.wfh),
                _buildLegendItem(context, 'WFO', AppTheme.wfo),
                _buildLegendItem(context, 'Leave', AppTheme.leave),
                _buildLegendItem(context, 'Holiday', AppTheme.warning),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWeekdayHeaders(BuildContext context) {
    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    return List.generate(7, (index) {
      final isWeekend = index >= 5;
      
      return Expanded(
        child: Center(
          child: Text(
            weekdays[index],
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isWeekend ? AppTheme.textTertiary : AppTheme.textSecondary,
                ),
          ),
        ),
      );
    });
  }

  Widget _buildCalendarDay(BuildContext context, int index) {
    final firstDayOffset = _getFirstDayOffset();
    
    // Empty cells for days before the 1st of the month
    if (index < firstDayOffset) {
      return const SizedBox();
    }
    
    final dayNumber = index - firstDayOffset + 1;
    final date = DateTime(selectedMonth.year, selectedMonth.month, dayNumber);
    
    // Check if this date has a schedule status
    final hasStatus = scheduleData.containsKey(date);
    final status = hasStatus ? scheduleData[date]! : '';
    
    // Determine if this is today
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    
    // Determine if this is a weekend
    final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    
    // Determine cell color based on status
    Color cellColor = Colors.transparent;
    Color textColor = isWeekend ? AppTheme.textTertiary : AppTheme.textPrimary;
    
    if (hasStatus) {
      switch (status) {
        case 'wfh':
          cellColor = AppTheme.wfh.withAlpha(51);
          textColor = AppTheme.wfh;
          break;
        case 'wfo':
          cellColor = AppTheme.wfo.withAlpha(51);
          textColor = AppTheme.wfo;
          break;
        case 'leave':
          cellColor = AppTheme.leave.withAlpha(51);
          textColor = AppTheme.leave;
          break;
        case 'holiday':
          cellColor = AppTheme.warning.withAlpha(51);
          textColor = AppTheme.warning;
          break;
        case 'wfh_suggested':
          cellColor = AppTheme.wfh.withAlpha(13);
          textColor = AppTheme.textSecondary;
          break;
        case 'wfo_suggested':
          cellColor = AppTheme.wfo.withAlpha(13);
          textColor = AppTheme.textSecondary;
          break;
      }
    }
    
    return Container(
      margin: EdgeInsets.all(0.5.w),
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: AppTheme.primary, width: 2)
            : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              dayNumber.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ),
          if (hasStatus && (status == 'wfh_suggested' || status == 'wfo_suggested'))
            Positioned(
              right: 1.w,
              bottom: 0.5.h,
              child: CustomIconWidget(
                iconName: status == 'wfh_suggested' ? 'home' : 'business',
                color: status == 'wfh_suggested' ? AppTheme.wfh : AppTheme.wfo,
                size: 10,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
            color: color.withAlpha(51),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color, width: 1),
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  int _getDaysInMonth() {
    return DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
  }

  int _getFirstDayOffset() {
    // Get the weekday of the first day (1 = Monday, 7 = Sunday)
    final firstDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final weekday = firstDayOfMonth.weekday;
    
    // Return the offset (0 for Monday, 6 for Sunday)
    return weekday - 1;
  }
}