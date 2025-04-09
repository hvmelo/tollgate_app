import 'package:tollgate_app/data/local/local_storage_service.dart';

class MockLocalStorageService implements LocalStorageService {
  @override
  Future<void> saveProperty(String key, dynamic value) async {
    // Mock implementation - does nothing
  }

  @override
  Future<void> removeProperty(String key) async {
    // Mock implementation - does nothing
  }

  @override
  T? getProperty<T>(String key) {
    return null;
  }

  @override
  Future<void> clearProperties() async {
    // Mock implementation - does nothing
  }

  @override
  bool propertyExists(String key) {
    return false;
  }
}
