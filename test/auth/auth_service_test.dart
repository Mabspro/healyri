import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:healyri/services/auth_service.dart';

@GenerateMocks([FirebaseAuth, FirebaseFirestore, User, UserCredential])
void main() {
  late AuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();

    // Setup default mock behavior
    when(mockUser.uid).thenReturn('test-uid');
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

    authService = AuthService();
  });

  group('Authentication Service Tests', () {
    test('sign up with email and password', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);

      final result = await authService.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
        role: UserRole.patient,
        name: 'Test User',
      );

      expect(result, isA<UserCredential>());
      expect(result.user, isNotNull);
      expect(result.user!.email, equals('test@example.com'));
    });

    test('sign in with email and password', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);

      final result = await authService.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isA<UserCredential>());
      expect(result.user, isNotNull);
      expect(result.user!.email, equals('test@example.com'));
    });

    test('sign out', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async => null);
      await authService.signOut();
      expect(authService.currentUser, isNull);
    });

    test('get user role', () async {
      final mockDocSnapshot = MockDocumentSnapshot();
      when(mockFirestore.collection('users')).thenReturn(MockCollectionReference());
      when(mockFirestore.collection('users').doc('test-uid')).thenReturn(MockDocumentReference());
      when(mockFirestore.collection('users').doc('test-uid').get())
          .thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.data()).thenReturn({'role': 'patient'});

      final role = await authService.getUserRole();
      expect(role, equals(UserRole.patient));
    });
  });
}

// Mock classes for testing
class MockCollectionReference extends Mock implements CollectionReference {}
class MockDocumentReference extends Mock implements DocumentReference {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {} 