import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class WeekdayToggleWidget extends StatelessWidget {
  final Map<String, bool> fixedDays;
  final Map<String, String> fixedDayTypes;
  final Function(String, bool, String) onDayToggled;

  const WeekdayToggleWidget({
    super.key,
    required this.fixedDays,
    required this.fixedDayTypes,
    required this.onDayToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: fixedDays.keys.map((day) {
        return _buildDayToggle(context, day);
      }).toList(),
    );
  }

  Widget _buildDayToggle(BuildContext context, String day) {
    final isFixed = fixedDays[day] ?? false;
    final dayType = fixedDayTypes[day] ?? 'none';
    
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFixed 
              ? (dayType == 'wfh' ? AppTheme.wfh : AppTheme.wfo) 
              : AppTheme.border,
          width: isFixed ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              day,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            flex: 5,
            child: isFixed
                ? _buildTypeSelector(context, day, dayType)
                : const SizedBox(),
          ),
          Switch(
            value: isFixed,
            onChanged: (value) {
              onDayToggled(day, value, value ? (dayType == 'none' ? 'wfh' : dayType) : 'none');
            },
            activeColor: dayType == 'wfh' ? AppTheme.wfh : AppTheme.wfo,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context, String day, String dayType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTypeOption(
          context,
          'WFH',
          dayType == 'wfh',
          AppTheme.wfh,
          () => onDayToggled(day, true, 'wfh'),
        ),
        SizedBox(width: 2.w),
        _buildTypeOption(
          context,
          'WFO',
          dayType == 'wfo',
          AppTheme.wfo,
          () => onDayToggled(day, true, 'wfo'),
        ),
      ],
    );
  }

  Widget _buildTypeOption(
    BuildContext context,
    String label,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}