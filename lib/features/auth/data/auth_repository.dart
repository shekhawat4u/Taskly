import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/mock_data_store.dart';
import '../../../shared/models/user_profile.dart';

class AuthRepository {
  AuthRepository({MockDataStore? dataStore})
      : _dataStore = dataStore ?? MockDataStore.instance;

  final MockDataStore _dataStore;

  UserProfile? get currentUser => _dataStore.currentUser;
  List<UserProfile> get demoUsers => _dataStore.users;

  Future<UserProfile> loginWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final cleanEmail = email.trim().toLowerCase();

    // Always verify against Firestore (source of truth)
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('auth_email', isEqualTo: cleanEmail)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: cleanEmail)
          .limit(1)
          .get();
    }

    if (snapshot.docs.isEmpty) {
      throw Exception('No account found for this email. Please contact your admin.');
    }

    final data = snapshot.docs.first.data();
    final expectedPassword = (data['password'] as String?) ??
        (cleanEmail == 'harsh@deepbasics.in' ? 'Ks@210109' : '123456');

    if (password != expectedPassword) {
      throw Exception('Invalid password. Please check your password and try again.');
    }

    final user = UserProfile.fromMap(data);
    // Update local list
    final idx = _dataStore.users.indexWhere((u) => u.id == user.id);
    if (idx >= 0) {
      _dataStore.users[idx] = user;
    } else {
      _dataStore.users.add(user);
    }
    _dataStore.switchUser(user);
    return user;
  }

  Future<UserProfile> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final user = _dataStore.anuragAdmin; // Default to Admin
    _dataStore.switchUser(user);
    return user;
  }

  Future<UserProfile> switchUser(UserProfile user) async {
    _dataStore.switchUser(user);
    return user;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
