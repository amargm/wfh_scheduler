import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/calendar_day_widget.dart';
import './widgets/day_override_modal_widget.dart';
import './widgets/optimization_mode_selector_widget.dart';
import './widgets/weather_forecast_widget.dart';

class ScheduleOptimizationScreen extends StatefulWidget {
  const ScheduleOptimizationScreen({super.key});

  @override
  State<ScheduleOptimizationScreen> createState() => _ScheduleOptimizationScreenState();
}

class _ScheduleOptimizationScreenState extends State<ScheduleOptimizationScreen> {
  bool _isLoading = false;
  bool _isGenerating = false;
  bool _hasGeneratedSchedule = false;
  bool _hasWeatherData = true;
  String _selectedOptimizationMode = 'balanced';
  final List<DateTime> _next30Days = [];
  final Map<DateTime, String> _suggestedSchedule = {};
  final Map<DateTime, String> _confirmedSchedule = {};
  final Map<DateTime, Map<String, dynamic>> _weatherData = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Generate next 30 days
      final now = DateTime.now();
      for (int i = 0; i < 30; i++) {
        _next30Days.add(DateTime(now.year, now.month, now.day + i));
      }

      // Load user preferences
      await _loadUserPreferences();

      // Load weather data
      await _fetchWeatherData();

      // Load any existing confirmed schedule
      await _loadConfirmedSchedule();
    } catch (e) {
      _showErrorSnackBar('Failed to initialize data: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _selectedOptimizationMode = prefs.getString('optimizationMode') ?? 'balanced';
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load preferences: ${e.toString()}');
    }
  }

  Future<void> _fetchWeatherData() async {
    try {
      // Simulate API call to fetch weather data
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock weather data for the next 5 days
      final weatherData = _generateMockWeatherData();
      
      setState(() {
        _weatherData.clear();
        _weatherData.addAll(weatherData);
        _hasWeatherData = true;
      });
    } catch (e) {
      setState(() {
        _hasWeatherData = false;
      });
      _showWarningSnackBar('Weather data unavailable. Optimization will proceed without weather considerations.');
    }
  }

  Map<DateTime, Map<String, dynamic>> _generateMockWeatherData() {
    final Map<DateTime, Map<String, dynamic>> mockData = {};
    final now = DateTime.now();
    
    // Weather conditions: sunny, cloudy, rainy, stormy, snowy
    final List<String> conditions = ['sunny', 'cloudy', 'rainy', 'stormy', 'rainy'];
    final List<int> rainProbabilities = [5, 20, 80, 90, 75];
    final List<int> temperatures = [28, 24, 22, 19, 21];
    
    for (int i = 0; i < 5; i++) {
      final day = DateTime(now.year, now.month, now.day + i);
      mockData[day] = {
        'condition': conditions[i],
        'rainProbability': rainProbabilities[i],
        'temperature': temperatures[i],
      };
    }
    
    return mockData;
  }

  Future<void> _loadConfirmedSchedule() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final confirmedDays = prefs.getStringList('confirmedSchedule') ?? [];
      
      for (final dayData in confirmedDays) {
        final parts = dayData.split('|');
        if (parts.length == 2) {
          final date = DateTime.parse(parts[0]);
          final status = parts[1];
          
          setState(() {
            _confirmedSchedule[date] = status;
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load confirmed schedule: ${e.toString()}');
    }
  }

  Future<void> _generateOptimizedSchedule() async {
    if (_isGenerating) return;
    
    setState(() {
      _isGenerating = true;
      _suggestedSchedule.clear();
    });
    
    try {
      // Simulate optimization process
      await Future.delayed(const Duration(seconds: 2));
      
      // Generate optimized schedule based on selected mode
      final optimizedSchedule = _generateMockOptimizedSchedule();
      
      setState(() {
        _suggestedSchedule.clear();
        _suggestedSchedule.addAll(optimizedSchedule);
        _hasGeneratedSchedule = true;
      });
      
      _showSuccessSnackBar('Schedule optimized successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to generate schedule: ${e.toString()}');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Map<DateTime, String> _generateMockOptimizedSchedule() {
    final Map<DateTime, String> schedule = {};
    final now = DateTime.now();
    
    // Different patterns based on optimization mode
    if (_selectedOptimizationMode == 'productivity') {
      // Productivity focus: More WFO days, clustered together
      for (int i = 0; i < 30; i++) {
        final day = DateTime(now.year, now.month, now.day + i);
        final weekday = day.weekday;
        
        // Skip weekends
        if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
          continue;
        }
        
        // Monday, Tuesday, Wednesday are WFO days
        if (weekday >= DateTime.monday && weekday <= DateTime.wednesday) {
          schedule[day] = 'wfo';
        } else {
          // Thursday, Friday are WFH days
          schedule[day] = 'wfh';
        }
        
        // Add some leaves
        if (i == 10 || i == 20) {
          schedule[day] = 'leave';
        }
      }
    } else if (_selectedOptimizationMode == 'wellbeing') {
      // Wellbeing focus: More WFH days, especially on rainy days
      for (int i = 0; i < 30; i++) {
        final day = DateTime(now.year, now.month, now.day + i);
        final weekday = day.weekday;
        
        // Skip weekends
        if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
          continue;
        }
        
        // Check if it's a rainy day (if we have weather data)
        final isRainyDay = _weatherData[day]?['condition'] == 'rainy' || 
                          _weatherData[day]?['condition'] == 'stormy';
        
        // WFH on rainy days and most Mondays and Fridays
        if (isRainyDay || weekday == DateTime.monday || weekday == DateTime.friday) {
          schedule[day] = 'wfh';
        } else {
          // WFO on other days
          schedule[day] = 'wfo';
        }
        
        // Add some leaves
        if (i == 15 || i == 25) {
          schedule[day] = 'leave';
        }
      }
    } else {
      // Balanced mode: Even distribution
      for (int i = 0; i < 30; i++) {
        final day = DateTime(now.year, now.month, now.day + i);
        final weekday = day.weekday;
        
        // Skip weekends
        if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
          continue;
        }
        
        // Alternate WFH and WFO
        if (i % 2 == 0) {
          schedule[day] = 'wfo';
        } else {
          schedule[day] = 'wfh';
        }
        
        // Add some leaves
        if (i == 12 || i == 22) {
          schedule[day] = 'leave';
        }
      }
    }
    
    // Override with any confirmed days
    for (final entry in _confirmedSchedule.entries) {
      if (schedule.containsKey(entry.key)) {
        schedule[entry.key] = entry.value;
      }
    }
    
    return schedule;
  }

  Future<void> _applyGeneratedSchedule() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Merge suggested schedule with confirmed schedule
      for (final entry in _suggestedSchedule.entries) {
        _confirmedSchedule[entry.key] = entry.value;
      }
      
      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      final List<String> confirmedDays = [];
      
      for (final entry in _confirmedSchedule.entries) {
        confirmedDays.add('${entry.key.toIso8601String()}|${entry.value}');
      }
      
      await prefs.setStringList('confirmedSchedule', confirmedDays);
      
      _showSuccessSnackBar('Schedule applied successfully!');
      
      // Navigate back to home dashboard
      if (mounted) {
        Navigator.pushNamed(context, '/home-dashboard-screen');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to apply schedule: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showDayOverrideModal(DateTime day) async {
    final currentStatus = _suggestedSchedule[day] ?? _confirmedSchedule[day] ?? 'none';
    
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayOverrideModalWidget(
        date: day,
        currentStatus: currentStatus,
      ),
    );
    
    if (result != null && result != currentStatus) {
      setState(() {
        _confirmedSchedule[day] = result;
        if (_suggestedSchedule.containsKey(day)) {
          _suggestedSchedule[day] = result;
        }
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

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.warning,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _fetchWeatherData,
          textColor: Colors.white,
        ),
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
          onPressed: _initializeData,
          textColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Optimization'),
        leading: IconButton(
          icon: const CustomIconWidget(
            iconName: 'arrow_back',
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const CustomIconWidget(
              iconName: 'settings',
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/preferences-setup-screen');
            },
            tooltip: 'Preferences',
          ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 3.h),
                  
                  // Optimization Mode Selector
                  OptimizationModeSelectorWidget(
                    selectedMode: _selectedOptimizationMode,
                    onModeChanged: (mode) {
                      setState(() {
                        _selectedOptimizationMode = mode;
                        // Clear suggested schedule when mode changes
                        if (_hasGeneratedSchedule) {
                          _suggestedSchedule.clear();
                          _hasGeneratedSchedule = false;
                        }
                      });
                    },
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  // Weather Forecast Section
                  if (_hasWeatherData) ...[
                    Text(
                      'Weather Forecast',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 1.h),
                    WeatherForecastWidget(weatherData: _weatherData),
                    SizedBox(height: 3.h),
                  ],
                  
                  // Calendar Section
                  _buildCalendarSection(),
                  
                  SizedBox(height: 3.h),
                  
                  // Action Buttons
                  _buildActionButtons(),
                  
                  SizedBox(height: 2.h),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Optimize Your Schedule',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        SizedBox(height: 1.h),
        Text(
          'Generate an optimized WFH/WFO schedule based on your preferences and external factors.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Next 30 Days',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (_hasGeneratedSchedule)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _suggestedSchedule.clear();
                    _hasGeneratedSchedule = false;
                  });
                },
                icon: const CustomIconWidget(
                  iconName: 'refresh',
                  color: AppTheme.primary,
                  size: 20,
                ),
                label: const Text('Reset'),
              ),
          ],
        ),
        SizedBox(height: 1.h),
        
        // Calendar Legend
        _buildCalendarLegend(),
        
        SizedBox(height: 2.h),
        
        // Calendar Grid
        _buildCalendarGrid(),
      ],
    );
  }

  Widget _buildCalendarLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('WFH', AppTheme.wfh),
        _buildLegendItem('WFO', AppTheme.wfo),
        _buildLegendItem('Leave', AppTheme.leave),
        _buildLegendItem('Weekend', AppTheme.textTertiary),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    // Group days by week
    final List<List<DateTime>> weeks = [];
    List<DateTime> currentWeek = [];
    
    for (final day in _next30Days) {
      if (currentWeek.isEmpty || day.weekday == DateTime.monday) {
        if (currentWeek.isNotEmpty) {
          weeks.add(currentWeek);
        }
        currentWeek = [day];
      } else {
        currentWeek.add(day);
      }
    }
    
    if (currentWeek.isNotEmpty) {
      weeks.add(currentWeek);
    }
    
    return Column(
      children: weeks.map((week) {
        return Padding(
          padding: EdgeInsets.only(bottom: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: week.map((day) {
              final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
              final status = _confirmedSchedule[day] ?? _suggestedSchedule[day];
              final weatherData = _weatherData[day];
              
              return Expanded(
                child: GestureDetector(
                  onTap: isWeekend ? null : () => _showDayOverrideModal(day),
                  child: CalendarDayWidget(
                    date: day,
                    status: status,
                    isWeekend: isWeekend,
                    isConfirmed: _confirmedSchedule.containsKey(day),
                    weatherData: weatherData,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton.icon(
            onPressed: _isGenerating ? null : _generateOptimizedSchedule,
            icon: _isGenerating
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const CustomIconWidget(
                    iconName: 'auto_awesome',
                    color: Colors.white,
                    size: 24,
                  ),
            label: Text(_isGenerating ? 'Generating...' : 'Generate Optimized Schedule'),
          ),
        ),
        SizedBox(height: 2.h),
        if (_hasGeneratedSchedule)
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton.icon(
              onPressed: _applyGeneratedSchedule,
              icon: const CustomIconWidget(
                iconName: 'check_circle',
                color: Colors.white,
                size: 24,
              ),
              label: const Text('Apply Generated Schedule'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
              ),
            ),
          ),
      ],
    );
  }
}