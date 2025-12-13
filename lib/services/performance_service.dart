import 'package:firebase_performance/firebase_performance.dart';

class PerformanceService {
  final FirebasePerformance _performance = FirebasePerformance.instance;
  
  // Track screen load time
  Future<void> trackScreenLoad(String screenName) async {
    final trace = _performance.newTrace('screen_load_$screenName');
    await trace.start();
    return trace.stop();
  }
  
  // Track network request
  Future<void> trackNetworkRequest(String url, String method) async {
    final metric = _performance.newHttpMetric(url, HttpMethod.values.firstWhere(
      (e) => e.toString() == 'HttpMethod.$method',
      orElse: () => HttpMethod.Get,
    ));
    
    await metric.start();
    return metric.stop();
  }
  
  // Track custom operation
  Future<void> trackOperation(String operationName, Future<void> Function() operation) async {
    final trace = _performance.newTrace(operationName);
    await trace.start();
    try {
      await operation();
    } finally {
      await trace.stop();
    }
  }
  
  // Track user action
  Future<void> trackUserAction(String actionName) async {
    final trace = _performance.newTrace('user_action_$actionName');
    await trace.start();
    return trace.stop();
  }
  
  // Add custom attribute to current trace
  Future<void> addCustomAttribute(String name, String value) async {
    final trace = _performance.newTrace('custom_attribute');
    trace.putAttribute(name, value);
  }
} 