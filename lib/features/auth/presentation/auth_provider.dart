import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/mock_data_store.dart';
import '../../../shared/models/user_profile.dart';
import '../data/auth_repository.dart';
import '../../../app/theme/theme_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserProfile?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(repo, prefs);
});

class AuthNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  AuthNotifier(this._repository, this._prefs)
      : super(const AsyncValue.data(null)) {
    _tryRestoreSession();
    // Auto-logout if admin deletes this user
    MockDataStore.instance.onCurrentUserDeleted = () {
      signOut();
    };
  }

  final AuthRepository _repository;
  final SharedPreferences _prefs;

  Future<void> _tryRestoreSession() async {
    final savedEmail = _prefs.getString('logged_in_email');
    final savedPassword = _prefs.getString('logged_in_password');
    if (savedEmail != null && savedEmail.isNotEmpty && savedPassword != null && savedPassword.isNotEmpty) {
      try {
        final user = await _repository.loginWithEmail(savedEmail, savedPassword);
        state = AsyncValue.data(user);
      } catch (_) {
        await signOut();
      }
    } else {
      await signOut();
    }
  }

  bool get isLoggedIn => state.valueOrNull != null;

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.loginWithEmail(email, password);
      
      // Save login state with password for session validation
      await _prefs.setString('logged_in_email', email);
      await _prefs.setString('logged_in_password', password);

      // Request FCM permission and save token to Firestore
      try {
        final messaging = FirebaseMessaging.instance;
        await messaging.requestPermission();
        final token = await messaging.getToken();
        if (token != null) {
          FirebaseFirestore.instance
              .collection('fcm_tokens')
              .doc(user.id)
              .set({'token': token, 'updated_at': DateTime.now().toIso8601String()});
        }
      } catch (e) {
        debugPrint('FCM Token error: $e');
      }

      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.loginWithGoogle();
      await _prefs.setString('logged_in_email', user.email);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> switchDemoUser(UserProfile user) async {
    final switched = await _repository.switchUser(user);
    await _prefs.setString('logged_in_email', switched.email);
    state = AsyncValue.data(switched);
  }

  Future<void> signOut() async {
    await _repository.logout();
    await _prefs.remove('logged_in_email');
    await _prefs.remove('logged_in_password');
    state = const AsyncValue.data(null);
  }
}
