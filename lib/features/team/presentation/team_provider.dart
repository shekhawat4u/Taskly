import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/user_role.dart';
import '../../tasks/presentation/task_provider.dart';
import '../data/team_repository.dart';

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamRepository();
});

final teamSearchQueryProvider = StateProvider<String>((ref) => '');
final teamStateRevisionProvider = StateProvider<int>((ref) => 0);

final teamMembersProvider = Provider<List<UserProfile>>((ref) {
  ref.watch(teamStateRevisionProvider);
  ref.watch(taskStateRevisionProvider); // Also refresh when Firestore syncs users
  final repo = ref.watch(teamRepositoryProvider);
  final query = ref.watch(teamSearchQueryProvider);
  return repo.searchMembers(query);
});

class TeamNotifier {
  TeamNotifier(this.ref);
  final Ref ref;

  void addMember({
    required String name,
    required String email,
    required UserRole role,
  }) {
    ref.read(teamRepositoryProvider).addMember(name: name, email: email, role: role);
    ref.read(teamStateRevisionProvider.notifier).state++;
  }

  void editMember({
    required String id,
    required String name,
    required String email,
    required UserRole role,
  }) {
    ref.read(teamRepositoryProvider).editMember(id: id, name: name, email: email, role: role);
    ref.read(teamStateRevisionProvider.notifier).state++;
  }

  void deleteMember(String id) {
    ref.read(teamRepositoryProvider).deleteMember(id);
    ref.read(teamStateRevisionProvider.notifier).state++;
  }
}

final teamProvider = Provider<TeamNotifier>((ref) {
  return TeamNotifier(ref);
});
