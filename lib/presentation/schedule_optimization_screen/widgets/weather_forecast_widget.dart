import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WeatherForecastWidget extends StatelessWidget {
  final Map<DateTime, Map<String, dynamic>> weatherData;

  const WeatherForecastWidget({
    super.key,
    required this.weatherData,
  });

  @override
  Widget build(BuildContext context) {
    final sortedDates = weatherData.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                const CustomIconWidget(
                  iconName: 'cloud',
                  color: AppTheme.info,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Weather Forecast',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.info,
                      ),
                ),
                const Spacer(),
                Text(
                  'Next 5 Days',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
            child: Row(
              children: sortedDates.take(5).map((date) {
                return _buildWeatherDayCard(context, date, weatherData[date]!);
              }).toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Text(
              'Weather data is considered for schedule optimization. Rainy days are prioritized for WFH.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDayCard(
    BuildContext context,
    DateTime date,
    Map<String, dynamic> data,
  ) {
    final dayName = DateFormat('E').format(date);
    final dayNumber = DateFormat('d').format(date);
    final condition = data['condition'] as String;
    final rainProbability = data['rainProbability'] as int;
    final temperature = data['temperature'] as int;
    
    String iconName;
    switch (condition) {
      case 'sunny':
        iconName = 'wb_sunny';
        break;
      case 'cloudy':
        iconName = 'cloud';
        break;
      case 'rainy':
        iconName = 'water_drop';
        break;
      case 'stormy':
        iconName = 'thunderstorm';
        break;
      case 'snowy':
        iconName = 'ac_unit';
        break;
      default:
        iconName = 'help_outline';
    }
    
    Color conditionColor;
    switch (condition) {
      case 'sunny':
        conditionColor = Colors.orange;
        break;
      case 'cloudy':
        conditionColor = Colors.grey;
        break;
      case 'rainy':
      case 'stormy':
        conditionColor = AppTheme.info;
        break;
      case 'snowy':
        conditionColor = Colors.lightBlue;
        break;
      default:
        conditionColor = AppTheme.textSecondary;
    }
    
    return Container(
      width: 18.w,
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dayName,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            dayNumber,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 1.h),
          CustomIconWidget(
            iconName: iconName,
            color: conditionColor,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            '$temperature°C',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 0.5.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.2.h),
            decoration: BoxDecoration(
              color: AppTheme.info.withAlpha(26),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$rainProbability%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.info,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}