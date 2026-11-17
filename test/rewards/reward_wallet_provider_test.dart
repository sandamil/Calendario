import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:calendario2/app/modules/rewards/providers/reward_wallet_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('el monedero suma puntos y conserva el historial local', () async {
    final firstContainer = ProviderContainer();
    final initial = await firstContainer.read(rewardWalletProvider.future);
    expect(initial.balance, 0);
    expect(initial.history, isEmpty);

    await firstContainer.read(rewardWalletProvider.notifier).addPoints(10);
    final updated = firstContainer.read(rewardWalletProvider).requireValue;
    expect(updated.balance, 10);
    expect(updated.history, hasLength(1));
    expect(updated.history.single.points, 10);
    firstContainer.dispose();

    final secondContainer = ProviderContainer();
    final restored = await secondContainer.read(rewardWalletProvider.future);
    expect(restored.balance, 10);
    expect(restored.history, hasLength(1));
    secondContainer.dispose();
  });

  test('no permite añadir puntos negativos o cero', () async {
    final container = ProviderContainer();
    await container.read(rewardWalletProvider.future);
    await container.read(rewardWalletProvider.notifier).addPoints(0);
    await container.read(rewardWalletProvider.notifier).addPoints(-5);
    expect(container.read(rewardWalletProvider).requireValue.balance, 0);
    container.dispose();
  });
}
