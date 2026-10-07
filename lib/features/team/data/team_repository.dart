import '../../../core/services/mock_data_store.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/user_role.dart';

class TeamRepository {
  TeamRepository({MockDataStore? dataStore})
      : _dataStore = dataStore ?? MockDataStore.instance;

  final MockDataStore _dataStore;

  List<UserProfile> getTeamMembers() {
    return List.unmodifiable(_dataStore.users);
  }

  List<UserProfile> searchMembers(String query) {
    if (query.trim().isEmpty) return getTeamMembers();
    final q = query.trim().toLowerCase();
    return _dataStore.users.where((user) {
      return user.name.toLowerCase().contains(q) ||
          user.email.toLowerCase().contains(q) ||
          user.role.label.toLowerCase().contains(q);
    }).toList();
  }

  void addMember({
    required String name,
    required String email,
    required UserRole role,
  }) {
    _dataStore.addMember(name: name, email: email, role: role);
  }

  void editMember({
    required String id,
    required String name,
    required String email,
    required UserRole role,
  }) {
    _dataStore.editMember(id: id, name: name, email: email, role: role);
  }

  void deleteMember(String id) {
    _dataStore.deleteMember(id);
  }
}
