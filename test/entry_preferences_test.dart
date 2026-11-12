
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aeris_pulse/features/onboarding/data/entry_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Apresenta boas-vindas no primeiro acesso', () async {
    const preferences = EntryPreferences();

    expect(
      await preferences.shouldShowWelcome(),
      isTrue,
    );
  });

  test('Não repete boas-vindas depois da conclusão', () async {
    const preferences = EntryPreferences();

    await preferences.markCompleted();

    expect(
      await preferences.shouldShowWelcome(),
      isFalse,
    );
  });

  test('Mantém a escolha após recriar o controlador', () async {
    const first = EntryPreferences();

    await first.markCompleted();

    const second = EntryPreferences();

    expect(
      await second.shouldShowWelcome(),
      isFalse,
    );
  });
}
