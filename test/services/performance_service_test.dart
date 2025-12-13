import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:healyri/services/performance_service.dart';

@GenerateMocks([FirebasePerformance, Trace, HttpMetric])
void main() {
  late PerformanceService performanceService;
  late MockFirebasePerformance mockFirebasePerformance;
  late MockTrace mockTrace;
  late MockHttpMetric mockHttpMetric;

  setUp(() {
    mockFirebasePerformance = MockFirebasePerformance();
    mockTrace = MockTrace();
    mockHttpMetric = MockHttpMetric();

    when(mockFirebasePerformance.newTrace(any)).thenAnswer((_) async => mockTrace);
    when(mockFirebasePerformance.newHttpMetric(any, any)).thenAnswer((_) async => mockHttpMetric);
    when(mockTrace.start()).thenAnswer((_) async => null);
    when(mockTrace.stop()).thenAnswer((_) async => null);
    when(mockHttpMetric.start()).thenAnswer((_) async => null);
    when(mockHttpMetric.stop()).thenAnswer((_) async => null);

    performanceService = PerformanceService();
  });

  group('Performance Service Tests', () {
    test('track screen load', () async {
      await performanceService.trackScreenLoad('test_screen');
      verify(mockTrace.start()).called(1);
      verify(mockTrace.stop()).called(1);
    });

    test('track network request', () async {
      await performanceService.trackNetworkRequest('https://api.example.com', 'GET');
      verify(mockHttpMetric.start()).called(1);
      verify(mockHttpMetric.stop()).called(1);
    });

    test('track operation', () async {
      bool operationExecuted = false;
      await performanceService.trackOperation('test_operation', () async {
        operationExecuted = true;
      });
      expect(operationExecuted, true);
      verify(mockTrace.start()).called(1);
      verify(mockTrace.stop()).called(1);
    });

    test('track user action', () async {
      await performanceService.trackUserAction('test_action');
      verify(mockTrace.start()).called(1);
      verify(mockTrace.stop()).called(1);
    });

    test('add custom attribute', () async {
      await performanceService.addCustomAttribute('test_key', 'test_value');
      verify(mockTrace.putAttribute('test_key', 'test_value')).called(1);
    });
  });
} 