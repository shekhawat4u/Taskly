import '../../../core/services/mock_data_store.dart';
import '../../../shared/models/organization.dart';
import '../../../shared/models/organization_settings.dart';

class AdminRepository {
  AdminRepository({MockDataStore? dataStore})
      : _dataStore = dataStore ?? MockDataStore.instance;

  final MockDataStore _dataStore;

  Organization getOrganization() => _dataStore.organization;

  OrganizationSettings getSettings() => _dataStore.organizationSettings;

  void updateRetentionDays(int days) {
    _dataStore.organizationSettings = OrganizationSettings(
      organizationId: _dataStore.organization.id,
      completedTaskRetentionDays: days,
    );
  }
}
