import 'package:tollgate_app/data/local/cashu_local_preferences.dart';
import 'package:tollgate_app/data/mocks/mock_local_storage_service.dart';

class MockCashuLocalPreferences extends CashuLocalPreferences {
  MockCashuLocalPreferences()
      : super(localPropertiesService: MockLocalStorageService());

  @override
  String? getCurrentMintUrl() {
    return 'https://testnut.cashu.space';
  }

  @override
  Future<void> saveCurrentMintUrl(String mintUrl) async {
    // Mock implementation - does nothing
  }

  @override
  Future<void> removeCurrentMintUrl() async {
    // Mock implementation - does nothing
  }
}
