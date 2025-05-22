import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalendarDayWidget extends StatelessWidget {
  final DateTime date;
  final String? status;
  final bool isWeekend;
  final bool isConfirmed;
  final Map<String, dynamic>? weatherData;

  const CalendarDayWidget({
    super.key,
    required this.date,
    this.status,
    this.isWeekend = false,
    this.isConfirmed = false,
    this.weatherData,
  });

  Color _getStatusColor() {
    if (isWeekend) return AppTheme.textTertiary;
    
    switch (status) {
      case 'wfh':
        return AppTheme.wfh;
      case 'wfo':
        return AppTheme.wfo;
      case 'leave':
        return AppTheme.leave;
      default:
        return AppTheme.border;
    }
  }

  String _getStatusLabel() {
    if (isWeekend) return '';
    
    switch (status) {
      case 'wfh':
        return 'WFH';
      case 'wfo':
        return 'WFO';
      case 'leave':
        return 'Leave';
      default:
        return '';
    }
  }

  String _getWeatherIcon() {
    if (weatherData == null) return '';
    
    final condition = weatherData!['condition'] as String;
    switch (condition) {
      case 'sunny':
        return 'wb_sunny';
      case 'cloudy':
        return 'cloud';
      case 'rainy':
        return 'water_drop';
      case 'stormy':
        return 'thunderstorm';
      case 'snowy':
        return 'ac_unit';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayNumber = DateFormat('d').format(date);
    final dayName = DateFormat('E').format(date);
    final isToday = DateTime.now().day == date.day && 
                    DateTime.now().month == date.month && 
                    DateTime.now().year == date.year;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0.5.w),
      decoration: BoxDecoration(
        color: isWeekend 
            ? AppTheme.surface 
            : (isConfirmed 
                ? _getStatusColor().withAlpha(51) 
                : AppTheme.background),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isToday 
              ? AppTheme.primary 
              : (isWeekend 
                  ? AppTheme.border 
                  : _getStatusColor()),
          width: isToday || isConfirmed ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Day name (Mon, Tue, etc.)
            Text(
              dayName.substring(0, 1),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isWeekend ? AppTheme.textTertiary : AppTheme.textSecondary,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
            
            SizedBox(height: 0.5.h),
            
            // Day number
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: isToday ? AppTheme.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  dayNumber,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isToday 
                            ? Colors.white 
                            : (isWeekend 
                                ? AppTheme.textTertiary 
                                : AppTheme.textPrimary),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
            
            SizedBox(height: 0.5.h),
            
            // Status label (WFH, WFO, Leave)
            if (!isWeekend && status != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.2.h),
                decoration: BoxDecoration(
                  color: _getStatusColor().withAlpha(26),
                  borderRadius: BorderRadius.circular(4),
                  border: isConfirmed 
                      ? Border.all(color: _getStatusColor(), width: 1) 
                      : null,
                ),
                child: Text(
                  _getStatusLabel(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(),
                        fontWeight: isConfirmed ? FontWeight.bold : FontWeight.normal,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            SizedBox(height: 0.5.h),
            
            // Weather icon (if available)
            if (weatherData != null && !isWeekend)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: _getWeatherIcon(),
                    color: AppTheme.info,
                    size: 14,
                  ),
                  SizedBox(width: 0.5.w),
                  Text(
                    '${weatherData!['rainProbability']}%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.info,
                          fontSize: 8,
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