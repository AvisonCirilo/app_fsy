import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_fsy/data/local_auth_service.dart';
import 'package:app_fsy/data/local_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalDatabase.instance.initialize();
    await LocalAuthService.instance.initialize();
  });

  test('conta de demonstração autentica sem Firebase', () async {
    final usuario = await LocalAuthService.instance.signIn(
      'admin',
      'fsy2026',
    );

    expect(usuario.username, 'admin');
    expect(usuario.profile['funcao'], 'Administrador');

    await LocalAuthService.instance.signOut();
  });

  test('senha incorreta é rejeitada pela autenticação local', () async {
    expect(
      () => LocalAuthService.instance.signIn('admin', 'senha-incorreta'),
      throwsA(isA<LocalAuthException>()),
    );
  });
}
