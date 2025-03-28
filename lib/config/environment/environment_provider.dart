import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'environment_config.dart';

part 'environment_provider.g.dart';

@riverpod
EnvironmentConfig environmentConfig(Ref ref) {
  // Default environment (can be overridden in main.dart)
  return EnvironmentConfig.development();
}
