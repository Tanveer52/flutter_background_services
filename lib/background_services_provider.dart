import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final backgroundServiceProvider =
    ChangeNotifierProvider<BackgroundServiceNotifier>((ref) {
  return BackgroundServiceNotifier();
});

class BackgroundServiceNotifier extends ChangeNotifier {
  bool _isServiceRunning = false;
  bool get isServiceRunning => _isServiceRunning;

  BackgroundServiceNotifier() {
    _initializeForegroundTask();
  }

  // Initialize the foreground task
  void _initializeForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service_channel',
        channelName: 'Foreground Service',
        channelDescription: 'Service running in foreground with high priority',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
        eventAction: ForegroundTaskEventAction.repeat(1000),
      ),
    );
  }

  // Request necessary permissions
  Future<void> requestPermissions() async {
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }
    if (!await FlutterForegroundTask.canScheduleExactAlarms) {
      await FlutterForegroundTask.openAlarmsAndRemindersSettings();
    }
    if (!await FlutterForegroundTask.canDrawOverlays) {
      await FlutterForegroundTask.openSystemAlertWindowSettings();
    }
  }

  // Start the foreground task
  Future<void> startForegroundTask() async {
    if (!await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service Running',
        notificationText: 'This service will keep the app alive.',
        callback: startCallback,
      );
      _isServiceRunning = true;
      notifyListeners();
    }
  }

  // Stop the foreground task
  Future<void> stopForegroundTask() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
      _isServiceRunning = false;
      notifyListeners();
    }
  }
}

// This is the callback function for the service
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

// The task handler for the service
class MyTaskHandler extends TaskHandler {
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    print('Foreground service is running...');
  }

  void onButtonPressed(String id) {}

  @override
  void onNotificationPressed() {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  void onStart(DateTime timestamp) {}

  @override
  void onDestroy(DateTime timestamp) {}
}
