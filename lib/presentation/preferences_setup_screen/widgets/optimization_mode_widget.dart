import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OptimizationModeWidget extends StatelessWidget {
  final String selectedMode;
  final Function(String) onModeChanged;

  const OptimizationModeWidget({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Optimization Mode',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Choose how to optimize your work schedule',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        SizedBox(height: 2.h),
        _buildModeOption(
          context,
          'balanced',
          'Balanced',
          'Optimize for both productivity and work-life balance',
          'balance',
        ),
        SizedBox(height: 1.5.h),
        _buildModeOption(
          context,
          'productivity',
          'Productivity Focus',
          'Prioritize productivity and team collaboration days',
          'trending_up',
        ),
        SizedBox(height: 1.5.h),
        _buildModeOption(
          context,
          'wellbeing',
          'Wellbeing Focus',
          'Prioritize work-life balance and personal preferences',
          'favorite',
        ),
      ],
    );
  }

  Widget _buildModeOption(
    BuildContext context,
    String mode,
    String title,
    String description,
    String iconName,
  ) {
    final isSelected = selectedMode == mode;
    
    return InkWell(
      onTap: () => onModeChanged(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withAlpha(26) : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio(
              value: mode,
              groupValue: selectedMode,
              onChanged: (value) {
                if (value != null) {
                  onModeChanged(value);
                }
              },
              activeColor: AppTheme.primary,
            ),
            SizedBox(width: 2.w),
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.primary.withAlpha(51) 
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.border,
                ),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: iconName,
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
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
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                        ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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