# Migrating from Workmanager to Background Fetch

This guide will help you migrate your code from the `workmanager` plugin to the more compatible `background_fetch` plugin.

## Why Migrate?

The `workmanager` plugin is currently having compatibility issues with Flutter 3.29.0 and newer versions, causing build failures with errors like:

```
Unresolved reference: shim
Unresolved reference: ShimPluginRegistry
Unresolved reference: PluginRegistrantCallback
```

## Migration Steps

### 1. Update Dependencies

Replace `workmanager` with `background_fetch` in your `pubspec.yaml`:

```yaml
dependencies:
  # Remove this line
  # workmanager: ^0.5.2
  
  # Add this line
  background_fetch: ^1.3.3
```

### 2. Initialize Background Fetch

Replace Workmanager initialization with Background Fetch initialization:

#### Old Code (Workmanager):

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  
  runApp(MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    // Your background task code
    return Future.value(true);
  });
}
```

#### New Code (Background Fetch):

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Background Fetch
  BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 15, // Minimum interval in minutes
      stopOnTerminate: false,
      enableHeadless: true,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresStorageNotLow: false,
      requiresDeviceIdle: false,
      requiredNetworkType: NetworkType.NONE,
    ),
    _onBackgroundFetch,
    _onBackgroundFetchTimeout,
  );
  
  // Register headless task
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  
  runApp(MyApp());
}

// Regular background fetch handler
void _onBackgroundFetch(String taskId) async {
  // Your background task code
  
  // IMPORTANT: You must call finish() when your task is complete
  BackgroundFetch.finish(taskId);
}

// Timeout handler
void _onBackgroundFetchTimeout(String taskId) {
  // This function is called when the background fetch operation times out
  BackgroundFetch.finish(taskId);
}

// Headless task handler (runs when app is terminated)
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  
  // Your background task code
  
  // IMPORTANT: You must call finish() when your task is complete
  BackgroundFetch.finish(taskId);
}
```

### 3. Scheduling Tasks

#### Old Code (Workmanager):

```dart
// One-time task
Workmanager().registerOneOffTask(
  "oneOffTask",
  "simpleTask",
  initialDelay: Duration(seconds: 10),
);

// Periodic task
Workmanager().registerPeriodicTask(
  "periodicTask",
  "simplePeriodicTask",
  frequency: Duration(hours: 1),
);
```

#### New Code (Background Fetch):

```dart
// Start the background fetch process
BackgroundFetch.start();

// To schedule a one-time task
BackgroundFetch.scheduleTask(TaskConfig(
  taskId: "oneOffTask",
  delay: 10000, // milliseconds
  periodic: false,
));

// For periodic tasks, use the minimumFetchInterval in the configuration
// or schedule multiple one-time tasks
```

### 4. Stopping Tasks

#### Old Code (Workmanager):

```dart
Workmanager().cancelByUniqueName("oneOffTask");
Workmanager().cancelAll();
```

#### New Code (Background Fetch):

```dart
BackgroundFetch.stop("oneOffTask");
BackgroundFetch.stop(); // Stop all tasks
```

## Additional Notes

1. `background_fetch` uses a different approach to background processing than `workmanager`. It's based on iOS's `performFetchWithCompletionHandler` and Android's `JobScheduler` or `AlarmManager`.

2. The minimum interval for `background_fetch` is 15 minutes on iOS due to platform limitations. Android can support shorter intervals.

3. Always call `BackgroundFetch.finish(taskId)` when your task is complete to prevent resource leaks.

4. For more precise scheduling on Android, consider using `android_alarm_manager_plus` in combination with `background_fetch`.

## Example Implementation

```dart
import 'package:flutter/material.dart';
import 'package:background_fetch/background_fetch.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = "Not started";
  List<String> _events = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Configure BackgroundFetch
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE,
      ),
      _onBackgroundFetch,
      _onBackgroundFetchTimeout,
    );

    // Register headless task
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

    if (!mounted) return;

    setState(() {
      _status = "Background fetch configured";
    });
  }

  void _onBackgroundFetch(String taskId) async {
    // This is the fetch-event callback
    print("[BackgroundFetch] Event received: $taskId");
    setState(() {
      _events.insert(0, "[$taskId] ${DateTime.now()}");
    });

    // Perform your task here

    // IMPORTANT: You must signal completion of your task or the OS can punish your app
    BackgroundFetch.finish(taskId);
  }

  void _onBackgroundFetchTimeout(String taskId) {
    print("[BackgroundFetch] TIMEOUT: $taskId");
    BackgroundFetch.finish(taskId);
  }

  void _startBackgroundFetch() {
    BackgroundFetch.start().then((int status) {
      setState(() {
        _status = "Started: $status";
      });
    }).catchError((e) {
      setState(() {
        _status = "Error: $e";
      });
    });
  }

  void _stopBackgroundFetch() {
    BackgroundFetch.stop().then((int status) {
      setState(() {
        _status = "Stopped: $status";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Background Fetch Example'),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text("Status: $_status"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _startBackgroundFetch,
                    child: Text('Start'),
                  ),
                  ElevatedButton(
                    onPressed: _stopBackgroundFetch,
                    child: Text('Stop'),
                  ),
                ],
              ),
              Divider(),
              Text("Events:"),
              Expanded(
                child: ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    return Text(_events[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// This is the headless task that will be executed when the app is terminated
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  print("[BackgroundFetch] Headless event received: $taskId");
  
  // Perform your task here
  
  BackgroundFetch.finish(taskId);
}
```
