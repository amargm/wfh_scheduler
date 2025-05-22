import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/calendar_widget.dart';
import './widgets/notification_card_widget.dart';
import './widgets/progress_tracker_widget.dart';
import './widgets/today_status_widget.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  bool _isLoading = true;
  bool _isFirstTimeUser = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _selectedIndex = 0;
  
  // User preferences
  double _targetWfoPercentage = 60;
  int _currentWfoPercentage = 0;
  
  // Schedule data
  late DateTime _selectedMonth;
  late Map<DateTime, String> _scheduleData;
  String _todayStatus = 'Not checked in';
  bool _isCheckedIn = false;
  
  // Notifications
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _scheduleData = {};
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnectivity = connectivityResult != ConnectivityResult.none;
      
      // Load data from local storage first
      await _loadLocalData();
      
      // If we have connectivity, refresh data from API
      if (hasConnectivity) {
        // Simulate API call with delay
        await Future.delayed(const Duration(seconds: 1));
        await _fetchDataFromApi();
      }
      
      // Generate notifications based on current data
      _generateNotifications();
      
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if first time user
      _isFirstTimeUser = prefs.getBool('isFirstTimeUser') ?? true;
      
      if (_isFirstTimeUser) {
        return;
      }
      
      // Load target WFO percentage
      _targetWfoPercentage = prefs.getDouble('targetWfoPercentage') ?? 60;
      
      // Load current WFO percentage
      _currentWfoPercentage = prefs.getInt('currentWfoPercentage') ?? 0;
      
      // Load today's status
      _todayStatus = prefs.getString('todayStatus') ?? 'Not checked in';
      _isCheckedIn = prefs.getBool('isCheckedIn') ?? false;
      
      // Load schedule data
      final scheduleKeys = prefs.getStringList('scheduleKeys') ?? [];
      final scheduleValues = prefs.getStringList('scheduleValues') ?? [];
      
      if (scheduleKeys.length == scheduleValues.length) {
        for (int i = 0; i < scheduleKeys.length; i++) {
          final date = DateTime.parse(scheduleKeys[i]);
          _scheduleData[date] = scheduleValues[i];
        }
      }
    } catch (e) {
      throw Exception('Failed to load local data: ${e.toString()}');
    }
  }

  Future<void> _fetchDataFromApi() async {
    // Simulate API call to fetch schedule data
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock data for the current month
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    
    // Generate mock schedule data
    final mockSchedule = _generateMockScheduleData(now, daysInMonth);
    
    // Calculate current WFO percentage
    _calculateCurrentWfoPercentage(mockSchedule);
    
    setState(() {
      _scheduleData = mockSchedule;
    });
    
    // Save to local storage
    await _saveDataToLocalStorage();
  }

  Map<DateTime, String> _generateMockScheduleData(DateTime now, int daysInMonth) {
    final Map<DateTime, String> mockData = {};
    final random = DateTime.now().millisecondsSinceEpoch;
    
    // Public holidays (for example)
    final holidays = [
      DateTime(now.year, now.month, 1),  // Example holiday
      DateTime(now.year, now.month, 15), // Example holiday
    ];
    
    // Generate data for each day of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(now.year, now.month, day);
      
      // Skip past days and set them based on a pattern
      if (date.isBefore(DateTime(now.year, now.month, now.day))) {
        if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
          // Weekends
          continue;
        } else if (holidays.any((holiday) => 
            holiday.year == date.year && 
            holiday.month == date.month && 
            holiday.day == date.day)) {
          // Holidays
          mockData[date] = 'holiday';
        } else if ((day + random) % 5 == 0) {
          // Some leave days
          mockData[date] = 'leave';
        } else if ((day + random) % 3 == 0) {
          // WFO days
          mockData[date] = 'wfo';
        } else {
          // WFH days
          mockData[date] = 'wfh';
        }
      } else if (date.day == now.day) {
        // Today's status
        if (!_isCheckedIn) {
          // If not checked in yet, don't set a status
          continue;
        } else {
          mockData[date] = _todayStatus.toLowerCase();
        }
      } else if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        // Future weekends
        continue;
      } else if (holidays.any((holiday) => 
          holiday.year == date.year && 
          holiday.month == date.month && 
          holiday.day == date.day)) {
        // Future holidays
        mockData[date] = 'holiday';
      } else {
        // Future workdays - suggested schedule
        if ((day + random) % 3 == 0) {
          mockData[date] = 'wfo_suggested';
        } else {
          mockData[date] = 'wfh_suggested';
        }
      }
    }
    
    return mockData;
  }

  void _calculateCurrentWfoPercentage(Map<DateTime, String> schedule) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    // Count WFO days up to today
    int wfoDays = 0;
    int totalWorkdays = 0;
    
    schedule.forEach((date, status) {
      if (date.isBefore(DateTime(now.year, now.month, now.day + 1)) && 
          date.isAfter(startOfMonth.subtract(const Duration(days: 1)))) {
        if (status == 'wfo') {
          wfoDays++;
          totalWorkdays++;
        } else if (status == 'wfh') {
          totalWorkdays++;
        }
      }
    });
    
    if (totalWorkdays > 0) {
      _currentWfoPercentage = ((wfoDays / totalWorkdays) * 100).round();
    } else {
      _currentWfoPercentage = 0;
    }
  }

  Future<void> _saveDataToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save first time user status
      await prefs.setBool('isFirstTimeUser', false);
      
      // Save target WFO percentage
      await prefs.setDouble('targetWfoPercentage', _targetWfoPercentage);
      
      // Save current WFO percentage
      await prefs.setInt('currentWfoPercentage', _currentWfoPercentage);
      
      // Save today's status
      await prefs.setString('todayStatus', _todayStatus);
      await prefs.setBool('isCheckedIn', _isCheckedIn);
      
      // Save schedule data
      final scheduleKeys = _scheduleData.keys.map((date) => date.toIso8601String()).toList();
      final scheduleValues = _scheduleData.values.toList();
      
      await prefs.setStringList('scheduleKeys', scheduleKeys);
      await prefs.setStringList('scheduleValues', scheduleValues);
    } catch (e) {
      throw Exception('Failed to save data: ${e.toString()}');
    }
  }

  void _generateNotifications() {
    final now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysLeft = endOfMonth.difference(now).inDays + 1;
    
    // Calculate WFO days needed to reach target
    int wfoDays = 0;
    int totalWorkdays = 0;
    int suggestedWfoDays = 0;
    
    _scheduleData.forEach((date, status) {
      if (date.month == now.month && date.year == now.year) {
        if (status == 'wfo') {
          wfoDays++;
          totalWorkdays++;
        } else if (status == 'wfh') {
          totalWorkdays++;
        } else if (status == 'wfo_suggested') {
          suggestedWfoDays++;
        }
      }
    });
    
    // Calculate workdays left in month (excluding weekends and holidays)
    int workdaysLeft = 0;
    for (int i = now.day; i <= endOfMonth.day; i++) {
      final date = DateTime(now.year, now.month, i);
      if (date.weekday != DateTime.saturday && date.weekday != DateTime.sunday) {
        if (!_scheduleData.containsKey(date) || 
            (_scheduleData[date] != 'holiday' && _scheduleData[date] != 'leave')) {
          workdaysLeft++;
        }
      }
    }
    
    // Calculate target WFO days for the month
    final totalMonthWorkdays = totalWorkdays + workdaysLeft;
    final targetWfoDays = (totalMonthWorkdays * _targetWfoPercentage / 100).round();
    final wfoDaysNeeded = targetWfoDays - wfoDays;
    
    _notifications = [];
    
    // Add notifications based on calculations
    if (wfoDaysNeeded > 0 && wfoDaysNeeded <= workdaysLeft) {
      _notifications.add({
        'type': 'warning',
        'title': 'WFO Target Alert',
        'message': 'Need $wfoDaysNeeded more WFO days this month to reach your target.',
        'actionText': 'View Schedule',
        'action': () {
          // Navigate to schedule optimization
          Navigator.pushNamed(context, '/schedule-optimization-screen');
        },
      });
    } else if (wfoDaysNeeded > workdaysLeft) {
      _notifications.add({
        'type': 'error',
        'title': 'WFO Target Warning',
        'message': 'Cannot reach WFO target of $_targetWfoPercentage% this month. Consider adjusting your target.',
        'actionText': 'Adjust Target',
        'action': () {
          // Navigate to preferences
          Navigator.pushNamed(context, '/preferences-setup-screen');
        },
      });
    } else if (!_isCheckedIn) {
      _notifications.add({
        'type': 'info',
        'title': 'Daily Check-in',
        'message': 'Don\'t forget to check in for today!',
        'actionText': 'Check In',
        'action': () {
          _showCheckInBottomSheet();
        },
      });
    }
    
    // Add weather-related notification (mock)
    if (daysLeft > 0 && suggestedWfoDays > 0) {
      _notifications.add({
        'type': 'info',
        'title': 'Weather Forecast',
        'message': 'Good weather expected for your suggested WFO days this week.',
        'actionText': 'View Details',
        'action': () {
          // Show weather details
          _showWeatherDetailsDialog();
        },
      });
    }
  }

  void _showWeatherDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weather Forecast'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Upcoming weather for suggested WFO days:'),
              SizedBox(height: 2.h),
              _buildWeatherForecastItem(
                DateTime.now().add(const Duration(days: 1)),
                'Sunny',
                '24°C',
                'sunny',
              ),
              SizedBox(height: 1.h),
              _buildWeatherForecastItem(
                DateTime.now().add(const Duration(days: 3)),
                'Partly Cloudy',
                '22°C',
                'partly_cloudy',
              ),
              SizedBox(height: 1.h),
              _buildWeatherForecastItem(
                DateTime.now().add(const Duration(days: 5)),
                'Sunny',
                '25°C',
                'sunny',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherForecastItem(
    DateTime date,
    String condition,
    String temperature,
    String iconName,
  ) {
    final dateFormat = DateFormat('EEE, MMM d');
    
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: AppTheme.info.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName == 'sunny' ? 'wb_sunny' : 'cloud',
                color: AppTheme.info,
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
                  dateFormat.format(date),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '$condition, $temperature',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          CustomIconWidget(
            iconName: _scheduleData[DateTime(date.year, date.month, date.day)] == 'wfo_suggested' 
                ? 'business' 
                : 'home',
            color: _scheduleData[DateTime(date.year, date.month, date.day)] == 'wfo_suggested'
                ? AppTheme.wfo
                : AppTheme.wfh,
            size: 20,
          ),
        ],
      ),
    );
  }

  void _showCheckInBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 5.w,
                right: 5.w,
                top: 3.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 3.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Check In for Today',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Select your work status for ${DateFormat('EEEE, MMMM d').format(DateTime.now())}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  SizedBox(height: 3.h),
                  _buildCheckInOption(
                    context,
                    'Work from Home',
                    'wfh',
                    AppTheme.wfh,
                    'home',
                  ),
                  SizedBox(height: 2.h),
                  _buildCheckInOption(
                    context,
                    'Work from Office',
                    'wfo',
                    AppTheme.wfo,
                    'business',
                  ),
                  SizedBox(height: 2.h),
                  _buildCheckInOption(
                    context,
                    'On Leave',
                    'leave',
                    AppTheme.leave,
                    'beach_access',
                  ),
                  SizedBox(height: 3.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCheckInOption(
    BuildContext context,
    String title,
    String value,
    Color color,
    String iconName,
  ) {
    return InkWell(
      onTap: () {
        _checkIn(value);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(128), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: color.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: iconName,
                  color: color,
                  size: 28,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    value == 'wfh'
                        ? 'Working remotely today'
                        : value == 'wfo'
                            ? 'Working from the office today'
                            : 'Taking a day off',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: color,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkIn(String status) async {
    // Update today's status
    setState(() {
      _todayStatus = status;
      _isCheckedIn = true;
    });
    
    // Update schedule data
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    setState(() {
      _scheduleData[today] = status;
    });
    
    // Recalculate WFO percentage
    _calculateCurrentWfoPercentage(_scheduleData);
    
    // Save to local storage
    await _saveDataToLocalStorage();
    
    // Regenerate notifications
    _generateNotifications();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully checked in as ${status.toUpperCase()}'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onBottomNavTapped(int index) {
  if (index == _selectedIndex) return;
  
  switch (index) {
    case 0:
      // Already on home screen
      break;
    case 1:
      Navigator.pushNamed(context, '/schedule-optimization-screen');
      break;
    case 2:
      Navigator.pushNamed(context, '/calendar-sync-screen');
      break;
    case 3:
      Navigator.pushNamed(context, '/preferences-setup-screen');
      break;
  }
  
  setState(() {
    _selectedIndex = index;
  });
}

  void _changeMonth(int monthOffset) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + monthOffset,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WFH Scheduler'),
        actions: [
          IconButton(
            icon: const CustomIconWidget(
              iconName: 'sync',
              color: Colors.white,
              size: 24,
            ),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isFirstTimeUser
          ? _buildFirstTimeUserView()
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasError
                  ? _buildErrorView()
                  : _buildDashboardContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: AppTheme.textSecondary,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'home',
              color: AppTheme.primary,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'calendar_today',
              color: AppTheme.textSecondary,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'calendar_today',
              color: AppTheme.primary,
              size: 24,
            ),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'sync',
              color: AppTheme.textSecondary,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'sync',
              color: AppTheme.primary,
              size: 24,
            ),
            label: 'Sync',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.textSecondary,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.primary,
              size: 24,
            ),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: !_isFirstTimeUser && !_isLoading && !_hasError && !_isCheckedIn
          ? FloatingActionButton(
              onPressed: _showCheckInBottomSheet,
              tooltip: 'Check In',
              child: const CustomIconWidget(
                iconName: 'check',
                color: Colors.white,
                size: 24,
              ),
            )
          : null,
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Tracker
            ProgressTrackerWidget(
              currentPercentage: _currentWfoPercentage,
              targetPercentage: _targetWfoPercentage.round(),
            ),
            
            SizedBox(height: 3.h),
            
            // Calendar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const CustomIconWidget(
                    iconName: 'chevron_left',
                    color: AppTheme.textSecondary,
                    size: 24,
                  ),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedMonth),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                IconButton(
                  icon: const CustomIconWidget(
                    iconName: 'chevron_right',
                    color: AppTheme.textSecondary,
                    size: 24,
                  ),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
            
            SizedBox(height: 1.h),
            
            CalendarWidget(
              selectedMonth: _selectedMonth,
              scheduleData: _scheduleData,
            ),
            
            SizedBox(height: 3.h),
            
            // Today's Status
            TodayStatusWidget(
              status: _todayStatus,
              isCheckedIn: _isCheckedIn,
              onCheckIn: _showCheckInBottomSheet,
            ),
            
            SizedBox(height: 3.h),
            
            // Notifications
            if (_notifications.isNotEmpty) ...[
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: 1.h),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 1.5.h),
                    child: NotificationCardWidget(
                      type: notification['type'] as String,
                      title: notification['title'] as String,
                      message: notification['message'] as String,
                      actionText: notification['actionText'] as String,
                      onAction: notification['action'] as Function(),
                    ),
                  );
                },
              ),
            ],
            
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstTimeUserView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'schedule',
                  color: AppTheme.primary,
                  size: 15.w.toDouble(),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Welcome to WFH Scheduler',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Let\'s set up your work preferences to optimize your WFH/WFO schedule.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5.h),
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/preferences-setup-screen');
                },
                child: const Text('Set Up Preferences'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 25.w,
              height: 25.w,
              decoration: BoxDecoration(
                color: AppTheme.error.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'error_outline',
                  color: AppTheme.error,
                  size: 12.w.toDouble(),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              _errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}