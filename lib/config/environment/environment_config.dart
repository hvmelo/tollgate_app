import 'app_environment.dart';

class EnvironmentConfig {
  final AppEnvironment environment;
  final bool useMocks;

  const EnvironmentConfig({
    required this.environment,
    required this.useMocks,
  });

  factory EnvironmentConfig.development() {
    return const EnvironmentConfig(
      environment: AppEnvironment.development,
      useMocks: true,
    );
  }

  factory EnvironmentConfig.staging() {
    return const EnvironmentConfig(
      environment: AppEnvironment.staging,
      useMocks: false,
    );
  }

  factory EnvironmentConfig.production() {
    return const EnvironmentConfig(
      environment: AppEnvironment.production,
      useMocks: false,
    );
  }

  bool get isDev => environment == AppEnvironment.development;
  bool get isStaging => environment == AppEnvironment.staging;
  bool get isProd => environment == AppEnvironment.production;
}
