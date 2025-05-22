import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/leave_quota_widget.dart';
import './widgets/office_hours_widget.dart';
import './widgets/optimization_mode_widget.dart';
import './widgets/weekday_toggle_widget.dart';

class PreferencesSetupScreen extends StatefulWidget {
  const PreferencesSetupScreen({super.key});

  @override
  State<PreferencesSetupScreen> createState() => _PreferencesSetupScreenState();
}

class _PreferencesSetupScreenState extends State<PreferencesSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showAdvancedOptions = false;
  
  // Form values
  double _targetWfoPercentage = 60;
  String _selectedOptimizationMode = 'balanced';
  final Map<String, bool> _fixedDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
  };
  final Map<String, String> _fixedDayTypes = {
    'Monday': 'none',
    'Tuesday': 'none',
    'Wednesday': 'none',
    'Thursday': 'none',
    'Friday': 'none',
  };
  TimeOfDay _arrivalTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _departureTime = const TimeOfDay(hour: 17, minute: 0);
  int _leaveQuota = 20;
  List<DateTime> _plannedLeaves = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _targetWfoPercentage = prefs.getDouble('targetWfoPercentage') ?? 60;
        _selectedOptimizationMode = prefs.getString('optimizationMode') ?? 'balanced';
        
        // Load fixed days
        for (var day in _fixedDays.keys) {
          _fixedDays[day] = prefs.getBool('fixedDay_$day') ?? false;
          _fixedDayTypes[day] = prefs.getString('fixedDayType_$day') ?? 'none';
        }
        
        // Load office hours
        _arrivalTime = TimeOfDay(
          hour: prefs.getInt('arrivalHour') ?? 9,
          minute: prefs.getInt('arrivalMinute') ?? 0,
        );
        
        _departureTime = TimeOfDay(
          hour: prefs.getInt('departureHour') ?? 17,
          minute: prefs.getInt('departureMinute') ?? 0,
        );
        
        // Load leave quota
        _leaveQuota = prefs.getInt('leaveQuota') ?? 20;
        
        // Load planned leaves
        final leaveDates = prefs.getStringList('plannedLeaves') ?? [];
        _plannedLeaves = leaveDates
            .map((date) => DateTime.parse(date))
            .toList();
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load preferences: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save target WFO percentage
      await prefs.setDouble('targetWfoPercentage', _targetWfoPercentage);
      
      // Save optimization mode
      await prefs.setString('optimizationMode', _selectedOptimizationMode);
      
      // Save fixed days
      for (var day in _fixedDays.keys) {
        await prefs.setBool('fixedDay_$day', _fixedDays[day]!);
        await prefs.setString('fixedDayType_$day', _fixedDayTypes[day]!);
      }
      
      // Save office hours
      await prefs.setInt('arrivalHour', _arrivalTime.hour);
      await prefs.setInt('arrivalMinute', _arrivalTime.minute);
      await prefs.setInt('departureHour', _departureTime.hour);
      await prefs.setInt('departureMinute', _departureTime.minute);
      
      // Save leave quota
      await prefs.setInt('leaveQuota', _leaveQuota);
      
      // Save planned leaves
      final leaveDates = _plannedLeaves
          .map((date) => date.toIso8601String())
          .toList();
      await prefs.setStringList('plannedLeaves', leaveDates);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _showSuccessSnackBar('Preferences saved successfully!');
      
      // Navigate to home dashboard
      if (mounted) {
        Navigator.pushNamed(context, '/home-dashboard-screen');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to save preferences: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _loadSavedPreferences,
          textColor: Colors.white,
        ),
      ),
    );
  }

  void _updateFixedDay(String day, bool isFixed, String type) {
    setState(() {
      _fixedDays[day] = isFixed;
      if (isFixed) {
        _fixedDayTypes[day] = type;
      } else {
        _fixedDayTypes[day] = 'none';
      }
    });
  }

  void _updateOfficeHours(TimeOfDay arrival, TimeOfDay departure) {
    setState(() {
      _arrivalTime = arrival;
      _departureTime = departure;
    });
  }

  void _updateLeaveQuota(int quota, List<DateTime> plannedLeaves) {
    setState(() {
      _leaveQuota = quota;
      _plannedLeaves = plannedLeaves;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Preferences'),
        actions: [
          IconButton(
            icon: const CustomIconWidget(
              iconName: 'sync',
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/calendar-sync-screen');
            },
            tooltip: 'Sync Calendar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Work Preferences',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Configure your work preferences to optimize your WFH/WFO schedule.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    
                    // Target WFO Percentage
                    _buildTargetWfoSection(),
                    
                    SizedBox(height: 4.h),
                    
                    // Office Hours
                    OfficeHoursWidget(
                      arrivalTime: _arrivalTime,
                      departureTime: _departureTime,
                      onTimeChanged: _updateOfficeHours,
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Optimization Mode
                    OptimizationModeWidget(
                      selectedMode: _selectedOptimizationMode,
                      onModeChanged: (mode) {
                        setState(() {
                          _selectedOptimizationMode = mode;
                        });
                      },
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Fixed Days Setup
                    _buildFixedDaysSection(),
                    
                    SizedBox(height: 3.h),
                    
                    // Advanced Options Toggle
                    _buildAdvancedOptionsToggle(),
                    
                    // Advanced Options Section
                    if (_showAdvancedOptions) ...[
                      SizedBox(height: 3.h),
                      
                      // Leave Quota and Planning
                      LeaveQuotaWidget(
                        leaveQuota: _leaveQuota,
                        plannedLeaves: _plannedLeaves,
                        onLeaveDataChanged: _updateLeaveQuota,
                      ),
                      
                      SizedBox(height: 3.h),
                      
                      // Additional Navigation Options
                      _buildAdditionalOptions(),
                    ],
                    
                    SizedBox(height: 5.h),
                    
                    // Save Button
                    _buildSaveButton(),
                    
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTargetWfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target WFO Percentage',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Set your target percentage of days to work from office',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _targetWfoPercentage,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${_targetWfoPercentage.round()}%',
                onChanged: (value) {
                  setState(() {
                    _targetWfoPercentage = value;
                  });
                },
              ),
            ),
            Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              alignment: Alignment.center,
              child: Text(
                '${_targetWfoPercentage.round()}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFixedDaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fixed WFH/WFO Days',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Set specific days that should always be WFH or WFO',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        SizedBox(height: 2.h),
        WeekdayToggleWidget(
          fixedDays: _fixedDays,
          fixedDayTypes: _fixedDayTypes,
          onDayToggled: _updateFixedDay,
        ),
      ],
    );
  }

  Widget _buildAdvancedOptionsToggle() {
    return InkWell(
      onTap: () {
        setState(() {
          _showAdvancedOptions = !_showAdvancedOptions;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: _showAdvancedOptions ? 'expand_less' : 'expand_more',
              color: AppTheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Advanced Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Options',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 2.h),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/schedule-optimization-screen');
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'tune',
                        color: AppTheme.primary,
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
                          'Advanced Optimization',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Fine-tune your schedule optimization parameters',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'chevron_right',
                    color: AppTheme.textSecondary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _savePreferences,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text('Save Preferences'),
      ),
    );
  }
}