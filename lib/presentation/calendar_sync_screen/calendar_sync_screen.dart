import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/calendar_provider_card_widget.dart';
import './widgets/sync_preferences_widget.dart';
import './widgets/sync_status_widget.dart';

class CalendarSyncScreen extends StatefulWidget {
  const CalendarSyncScreen({super.key});

  @override
  State<CalendarSyncScreen> createState() => _CalendarSyncScreenState();
}

class _CalendarSyncScreenState extends State<CalendarSyncScreen> {
  bool _isLoading = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  String _syncStatus = 'none'; // 'none', 'success', 'error'
  String? _errorMessage;
  int _selectedIndex = 2; // Set the selected index to 2 for the sync tab

  // Calendar connection status
  final Map<String, bool> _connectedCalendars = {
    'google': false,
    'outlook': false,
    'apple': false,
  };

  // Sync preferences
  bool _importHolidays = true;
  bool _exportWfhWfoStatus = true;
  bool _syncLeaves = true;

  @override
  void initState() {
    super.initState();
    _loadSyncSettings();
  }

  Future<void> _loadSyncSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        // Load calendar connection status
        _connectedCalendars['google'] = prefs.getBool('calendar_google_connected') ?? false;
        _connectedCalendars['outlook'] = prefs.getBool('calendar_outlook_connected') ?? false;
        _connectedCalendars['apple'] = prefs.getBool('calendar_apple_connected') ?? false;
        
        // Load sync preferences
        _importHolidays = prefs.getBool('sync_import_holidays') ?? true;
        _exportWfhWfoStatus = prefs.getBool('sync_export_wfh_wfo') ?? true;
        _syncLeaves = prefs.getBool('sync_leaves') ?? true;
        
        // Load last sync time
        final lastSyncTimeString = prefs.getString('last_sync_time');
        _lastSyncTime = lastSyncTimeString != null 
            ? DateTime.parse(lastSyncTimeString) 
            : null;
        
        // Load sync status
        _syncStatus = prefs.getString('sync_status') ?? 'none';
        _errorMessage = prefs.getString('sync_error_message');
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load sync settings: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCalendarSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save calendar connection status
      await prefs.setBool('calendar_google_connected', _connectedCalendars['google']!);
      await prefs.setBool('calendar_outlook_connected', _connectedCalendars['outlook']!);
      await prefs.setBool('calendar_apple_connected', _connectedCalendars['apple']!);
      
      // Save sync preferences
      await prefs.setBool('sync_import_holidays', _importHolidays);
      await prefs.setBool('sync_export_wfh_wfo', _exportWfhWfoStatus);
      await prefs.setBool('sync_leaves', _syncLeaves);
      
      // Save last sync time if available
      if (_lastSyncTime != null) {
        await prefs.setString('last_sync_time', _lastSyncTime!.toIso8601String());
      }
      
      // Save sync status
      await prefs.setString('sync_status', _syncStatus);
      if (_errorMessage != null) {
        await prefs.setString('sync_error_message', _errorMessage!);
      } else {
        await prefs.remove('sync_error_message');
      }
      
      _showSuccessSnackBar('Calendar settings saved successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to save calendar settings: ${e.toString()}');
    }
  }

  Future<void> _connectCalendar(String provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate OAuth flow with a delay
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, this would be replaced with actual OAuth authentication
      final bool authSuccess = true; // Simulated success
      
      if (authSuccess) {
        setState(() {
          _connectedCalendars[provider] = true;
        });
        
        await _saveCalendarSettings();
        _showSuccessSnackBar('Connected to $provider calendar');
      } else {
        _showErrorSnackBar('Failed to connect to $provider calendar');
      }
    } catch (e) {
      _showErrorSnackBar('Authentication error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _disconnectCalendar(String provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate disconnection with a delay
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _connectedCalendars[provider] = false;
      });
      
      await _saveCalendarSettings();
      _showSuccessSnackBar('Disconnected from $provider calendar');
    } catch (e) {
      _showErrorSnackBar('Failed to disconnect: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _syncCalendars() async {
    // Check if any calendar is connected
    final bool anyCalendarConnected = _connectedCalendars.values.any((connected) => connected);
    
    if (!anyCalendarConnected) {
      _showErrorSnackBar('Please connect at least one calendar to sync');
      return;
    }

    setState(() {
      _isSyncing = true;
      _syncStatus = 'none';
      _errorMessage = null;
    });

    try {
      // Simulate sync process with a delay
      await Future.delayed(const Duration(seconds: 3));
      
      // In a real app, this would be replaced with actual sync logic
      final bool syncSuccess = true; // Simulated success
      
      setState(() {
        _lastSyncTime = DateTime.now();
        _syncStatus = syncSuccess ? 'success' : 'error';
        _errorMessage = syncSuccess ? null : 'Failed to sync with one or more calendars';
      });
      
      await _saveCalendarSettings();
      
      if (syncSuccess) {
        _showSuccessSnackBar('Calendars synced successfully');
      } else {
        _showErrorSnackBar('Sync failed: $_errorMessage');
      }
    } catch (e) {
      setState(() {
        _syncStatus = 'error';
        _errorMessage = e.toString();
      });
      _showErrorSnackBar('Sync error: ${e.toString()}');
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  void _updateSyncPreferences({
    bool? importHolidays,
    bool? exportWfhWfoStatus,
    bool? syncLeaves,
  }) {
    setState(() {
      if (importHolidays != null) _importHolidays = importHolidays;
      if (exportWfhWfoStatus != null) _exportWfhWfoStatus = exportWfhWfoStatus;
      if (syncLeaves != null) _syncLeaves = syncLeaves;
    });
    
    _saveCalendarSettings();
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
          onPressed: _loadSyncSettings,
          textColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Sync'),
        leading: IconButton(
          icon: const CustomIconWidget(
            iconName: 'arrow_back',
            color: Colors.white,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calendar Integration',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Connect and sync your calendars to optimize your work schedule',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  SizedBox(height: 3.h),
                  
                  // Calendar Provider Cards
                  CalendarProviderCard(
                    provider: 'Google',
                    iconName: 'calendar_today',
                    isConnected: _connectedCalendars['google']!,
                    onConnect: () => _connectCalendar('google'),
                    onDisconnect: () => _disconnectCalendar('google'),
                    isLoading: _isLoading,
                  ),
                  SizedBox(height: 2.h),
                  
                  CalendarProviderCard(
                    provider: 'Outlook',
                    iconName: 'event_note',
                    isConnected: _connectedCalendars['outlook']!,
                    onConnect: () => _connectCalendar('outlook'),
                    onDisconnect: () => _disconnectCalendar('outlook'),
                    isLoading: _isLoading,
                  ),
                  SizedBox(height: 2.h),
                  
                  CalendarProviderCard(
                    provider: 'Apple',
                    iconName: 'event',
                    isConnected: _connectedCalendars['apple']!,
                    onConnect: () => _connectCalendar('apple'),
                    onDisconnect: () => _disconnectCalendar('apple'),
                    isLoading: _isLoading,
                  ),
                  SizedBox(height: 3.h),
                  
                  // Sync Preferences
                  SyncPreferencesWidget(
                    importHolidays: _importHolidays,
                    exportWfhWfoStatus: _exportWfhWfoStatus,
                    syncLeaves: _syncLeaves,
                    onPreferencesChanged: _updateSyncPreferences,
                  ),
                  SizedBox(height: 3.h),
                  
                  // Sync Status
                  SyncStatusWidget(
                    lastSyncTime: _lastSyncTime,
                    syncStatus: _syncStatus,
                    errorMessage: _errorMessage,
                    onRetry: _syncCalendars,
                  ),
                  SizedBox(height: 4.h),
                  
                  // Sync Now Button
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton.icon(
                      onPressed: _isSyncing ? null : _syncCalendars,
                      icon: _isSyncing
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const CustomIconWidget(
                              iconName: 'sync',
                              color: Colors.white,
                              size: 24,
                            ),
                      label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  
                  // Navigation Options
                  _buildNavigationOptions(),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
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
    );
  }

  void _onBottomNavTapped(int index) {
    if (index == _selectedIndex) return;
    
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/home-dashboard-screen',
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/schedule-optimization-screen',
          (route) => false,
        );
        break;
      case 2:
        // Already on sync screen
        break;
      case 3:
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/preferences-setup-screen',
          (route) => false,
        );
        break;
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavigationOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Navigation',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildNavigationCard(
                title: 'Dashboard',
                iconName: 'dashboard',
                onTap: () {
                  Navigator.pushNamed(context, '/home-dashboard-screen');
                },
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildNavigationCard(
                title: 'Preferences',
                iconName: 'settings',
                onTap: () {
                  Navigator.pushNamed(context, '/preferences-setup-screen');
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        _buildNavigationCard(
          title: 'Schedule Optimization',
          iconName: 'tune',
          onTap: () {
            Navigator.pushNamed(context, '/schedule-optimization-screen');
          },
        ),
      ],
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required String iconName,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: iconName,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
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
    );
  }
}