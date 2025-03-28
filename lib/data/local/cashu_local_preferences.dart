import 'local_storage_service.dart';

class CashuLocalPreferences {
  final LocalStorageService localPropertiesService;

  CashuLocalPreferences({required this.localPropertiesService});
  Future<void> saveCurrentMintUrl(String mintUrl) async {
    await localPropertiesService.saveProperty('current_mint_url', mintUrl);
  }

  Future<void> removeCurrentMintUrl() async {
    await localPropertiesService.removeProperty('current_mint_url');
  }

  String? getCurrentMintUrl() {
    return localPropertiesService.getProperty<String>('current_mint_url');
  }
}
