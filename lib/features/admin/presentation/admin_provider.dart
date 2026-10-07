import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/organization.dart';
import '../../../shared/models/organization_settings.dart';
import '../data/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

final adminRevisionProvider = StateProvider<int>((ref) => 0);

final organizationProvider = Provider<Organization>((ref) {
  ref.watch(adminRevisionProvider);
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getOrganization();
});

final organizationSettingsProvider = Provider<OrganizationSettings>((ref) {
  ref.watch(adminRevisionProvider);
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getSettings();
});

class AdminActions {
  AdminActions(this.ref);
  final Ref ref;

  void updateRetentionDays(int days) {
    final repo = ref.read(adminRepositoryProvider);
    repo.updateRetentionDays(days);
    ref.read(adminRevisionProvider.notifier).state++;
  }
}

final adminActionsProvider = Provider<AdminActions>((ref) {
  return AdminActions(ref);
});
