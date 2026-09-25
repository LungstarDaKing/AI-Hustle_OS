import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:ai_hustle_os/core/di/service_locator.dart';
import 'package:ai_hustle_os/core/di/auth_service.dart';

void main() {
  setUp(() async {
    await ServiceLocator.setup();
  });

  test('AuthService returns false for isLoggedIn in test environment', () async {
    final authService = GetIt.instance<AuthService>();
    final isLoggedIn = await authService.isLoggedIn;
    expect(isLoggedIn, false, reason: 'Should return false in test environment');
  });
}