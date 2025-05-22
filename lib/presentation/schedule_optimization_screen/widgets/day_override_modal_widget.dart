import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DayOverrideModalWidget extends StatefulWidget {
  final DateTime date;
  final String currentStatus;

  const DayOverrideModalWidget({
    super.key,
    required this.date,
    required this.currentStatus,
  });

  @override
  State<DayOverrideModalWidget> createState() => _DayOverrideModalWidgetState();
}

class _DayOverrideModalWidgetState extends State<DayOverrideModalWidget> {
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(widget.date);
    
    return Container(
      padding: EdgeInsets.only(
        top: 2.h,
        left: 5.w,
        right: 5.w,
        bottom: 2.h + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Override Day Status',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              IconButton(
                icon: const CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.textSecondary,
                  size: 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          
          SizedBox(height: 2.h),
          
          // Date display
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const CustomIconWidget(
                  iconName: 'calendar_today',
                  color: AppTheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Date',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        formattedDate,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 3.h),
          
          // Status options
          Text(
            'Select Status',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          
          SizedBox(height: 2.h),
          
          // WFH Option
          _buildStatusOption(
            'wfh',
            'Work From Home',
            'Schedule this day as a remote work day',
            'home',
            AppTheme.wfh,
          ),
          
          SizedBox(height: 1.5.h),
          
          // WFO Option
          _buildStatusOption(
            'wfo',
            'Work From Office',
            'Schedule this day as an office work day',
            'business',
            AppTheme.wfo,
          ),
          
          SizedBox(height: 1.5.h),
          
          // Leave Option
          _buildStatusOption(
            'leave',
            'Leave',
            'Schedule this day as a leave day',
            'beach_access',
            AppTheme.leave,
          ),
          
          SizedBox(height: 3.h),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedStatus),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
    String status,
    String title,
    String description,
    String iconName,
    Color color,
  ) {
    final isSelected = _selectedStatus == status;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(26) : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio(
              value: status,
              groupValue: _selectedStatus,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
              activeColor: color,
            ),
            SizedBox(width: 2.w),
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: isSelected 
                    ? color.withAlpha(51) 
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? color : AppTheme.border,
                ),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: iconName,
                  color: isSelected ? color : AppTheme.textSecondary,
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
                          color: isSelected ? color : AppTheme.textPrimary,
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