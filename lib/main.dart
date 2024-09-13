import 'package:flutter/material.dart';
import 'package:flutter_foreground_task_example/background_services_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ProviderScope(child: MaterialApp(home: MyApp())),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundService = ref.watch(backgroundServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foreground Service Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                backgroundService.startForegroundTask();
              },
              child: const Text('Start Foreground Service'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                backgroundService.stopForegroundTask();
              },
              child: const Text('Stop Foreground Service'),
            ),
            const SizedBox(height: 20),
            Text(
              backgroundService.isServiceRunning
                  ? 'Service is running'
                  : 'Service is stopped',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
