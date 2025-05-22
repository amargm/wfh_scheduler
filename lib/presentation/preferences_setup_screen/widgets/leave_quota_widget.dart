import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LeaveQuotaWidget extends StatefulWidget {
  final int leaveQuota;
  final List<DateTime> plannedLeaves;
  final Function(int, List<DateTime>) onLeaveDataChanged;

  const LeaveQuotaWidget({
    super.key,
    required this.leaveQuota,
    required this.plannedLeaves,
    required this.onLeaveDataChanged,
  });

  @override
  State<LeaveQuotaWidget> createState() => _LeaveQuotaWidgetState();
}

class _LeaveQuotaWidgetState extends State<LeaveQuotaWidget> {
  late TextEditingController _quotaController;
  late List<DateTime> _selectedLeaves;

  @override
  void initState() {
    super.initState();
    _quotaController = TextEditingController(text: widget.leaveQuota.toString());
    _selectedLeaves = List.from(widget.plannedLeaves);
  }

  @override
  void dispose() {
    _quotaController.dispose();
    super.dispose();
  }

  Future<void> _selectLeaveDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.surface,
              onSurface: AppTheme.textPrimary,
            ), dialogTheme: DialogThemeData(backgroundColor: AppTheme.background),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // Check if date is already selected
      final alreadySelected = _selectedLeaves.any(
        (date) => DateUtils.isSameDay(date, pickedDate),
      );
      
      setState(() {
        if (alreadySelected) {
          _selectedLeaves.removeWhere(
            (date) => DateUtils.isSameDay(date, pickedDate),
          );
        } else {
          _selectedLeaves.add(pickedDate);
        }
      });
      
      widget.onLeaveDataChanged(
        int.tryParse(_quotaController.text) ?? widget.leaveQuota,
        _selectedLeaves,
      );
    }
  }

  void _removeLeaveDate(DateTime date) {
    setState(() {
      _selectedLeaves.removeWhere(
        (d) => DateUtils.isSameDay(d, date),
      );
    });
    
    widget.onLeaveDataChanged(
      int.tryParse(_quotaController.text) ?? widget.leaveQuota,
      _selectedLeaves,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leave Management',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Set your annual leave quota and plan your leaves',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        SizedBox(height: 2.h),
        
        // Leave Quota Input
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Annual Leave Quota',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  SizedBox(height: 1.h),
                  TextFormField(
                    controller: _quotaController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: AppTheme.getInputDecoration(
                      label: 'Days',
                      prefixIcon: const CustomIconWidget(
                        iconName: 'event_available',
                        color: AppTheme.textSecondary,
                        size: 24,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your leave quota';
                      }
                      final quota = int.tryParse(value);
                      if (quota == null || quota < 0 || quota > 365) {
                        return 'Please enter a valid number of days';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final quota = int.tryParse(value) ?? widget.leaveQuota;
                      widget.onLeaveDataChanged(quota, _selectedLeaves);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plan Leaves',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  SizedBox(height: 1.h),
                  InkWell(
                    onTap: () => _selectLeaveDate(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 56,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.border, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const CustomIconWidget(
                            iconName: 'calendar_today',
                            color: AppTheme.textSecondary,
                            size: 24,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'Add Date',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const CustomIconWidget(
                            iconName: 'add',
                            color: AppTheme.primary,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        SizedBox(height: 2.h),
        
        // Planned Leaves List
        if (_selectedLeaves.isNotEmpty) ...[
          Text(
            'Planned Leaves (${_selectedLeaves.length})',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          SizedBox(height: 1.h),
          Container(
            constraints: BoxConstraints(maxHeight: 20.h),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _selectedLeaves.length,
              itemBuilder: (context, index) {
                final date = _selectedLeaves[index];
                final formattedDate = DateFormat('EEE, MMM d, yyyy').format(date);
                
                return Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.leave.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.leave.withAlpha(77)),
                  ),
                  child: Row(
                    children: [
                      const CustomIconWidget(
                        iconName: 'event_busy',
                        color: AppTheme.leave,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      IconButton(
                        icon: const CustomIconWidget(
                          iconName: 'close',
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => _removeLeaveDate(date),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}