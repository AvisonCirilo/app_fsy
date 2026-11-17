import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_permissions.dart';
import 'local_database.dart';

/// Autenticação fictícia para desenvolvimento local.
/// As senhas ficam no armazenamento local e não oferecem segurança real.
class LocalAuthUser {
  const LocalAuthUser({
    required this.uid,
    required this.username,
    required this.profile,
  });

  final String uid;
  final String username;
  final Map<String, dynamic> profile;
}

class LocalAuthException implements Exception {
  const LocalAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LocalAuthService {
  LocalAuthService._();

  static final LocalAuthService instance = LocalAuthService._();

  static const String _credentialsKey = 'app_fsy_local_credentials';
  static const String _sessionKey = 'app_fsy_local_session';

  final StreamController<LocalAuthUser?> _authChanges =
      StreamController<LocalAuthUser?>.broadcast();

  Map<String, String> _credentials = {};
  LocalAuthUser? _currentUser;
  bool _initialized = false;

  LocalAuthUser? get currentUser => _currentUser;

  Stream<LocalAuthUser?> get authStateChanges async* {
    yield _currentUser;
    yield* _authChanges.stream;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    final storedCredentials = prefs.getString(_credentialsKey);

    if (storedCredentials == null) {
      _credentials = {
        'admin': 'fsy2026',
        'diretor': 'fsy2026',
        'coordenador': 'fsy2026',
        'assistente': 'fsy2026',
        'logistica': 'fsy2026',
        'consultor': 'fsy2026',
      };
      await _saveCredentials();
    } else {
      final decoded = jsonDecode(storedCredentials) as Map;
      _credentials = decoded.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }

    final savedUid = prefs.getString(_sessionKey);
    if (savedUid != null) {
      final snapshot = await LocalDatabase.instance
          .collection('usuarios')
          .doc(savedUid)
          .get();

      if (snapshot.exists) {
        final profile = snapshot.data();
        _currentUser = LocalAuthUser(
          uid: savedUid,
          username: (profile['usuario'] ?? '').toString(),
          profile: profile,
        );
        await _saveProfileLocally(profile);
      } else {
        await prefs.remove(_sessionKey);
      }
    }

    _initialized = true;
  }

  Future<LocalAuthUser> signIn(String username, String password) async {
    _ensureInitialized();

    final normalized = username.trim().toLowerCase();
    final matches = await LocalDatabase.instance
        .collection('usuarios')
        .where('usuario', isEqualTo: normalized)
        .snapshots()
        .first;

    if (matches.docs.isEmpty || _credentials[normalized] != password) {
      throw const LocalAuthException('Usuário ou senha incorretos.');
    }

    final document = matches.docs.first;
    final profile = document.data();

    _currentUser = LocalAuthUser(
      uid: document.id,
      username: normalized,
      profile: profile,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, document.id);
    await _saveProfileLocally(profile);

    _authChanges.add(_currentUser);
    return _currentUser!;
  }

  Future<String> createAccount({
    required String username,
    required String password,
    required Map<String, dynamic> profile,
  }) async {
    _ensureInitialized();

    final actor = _currentUser;
    if (actor == null) {
      throw const LocalAuthException(
        'Entre no aplicativo para gerenciar contas.',
      );
    }

    final targetRole = (profile['funcao'] ?? '').toString();
    final permissions = AppPermissions.fromProfile(actor.profile);
    if (!permissions.canCreateOrManageUserRole(targetRole)) {
      throw const LocalAuthException(
        'Você não tem permissão para criar esse tipo de usuário.',
      );
    }
    await _validarDuasCompanhiasSeAssistente(profile);

    final normalized = username.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw const LocalAuthException('Informe um nome de usuário.');
    }
    if (password.length < 6) {
      throw const LocalAuthException(
        'A senha deve ter no mínimo 6 caracteres.',
      );
    }
    if (_credentials.containsKey(normalized)) {
      throw const LocalAuthException('Este usuário já está cadastrado.');
    }

    final existing = await LocalDatabase.instance
        .collection('usuarios')
        .where('usuario', isEqualTo: normalized)
        .snapshots()
        .first;
    if (existing.docs.isNotEmpty) {
      throw const LocalAuthException('Este usuário já está cadastrado.');
    }

    final data = <String, dynamic>{
      ...profile,
      'usuario': normalized,
      'criadoEm': DateTime.now().toIso8601String(),
    };

    final document = await LocalDatabase.instance
        .collection('usuarios')
        .add(data);

    _credentials[normalized] = password;
    await _saveCredentials();
    return document.id;
  }

  Future<void> deleteAccount(String uid) async {
    _ensureInitialized();

    final actor = _currentUser;
    if (actor == null) {
      throw const LocalAuthException(
        'Entre no aplicativo para gerenciar contas.',
      );
    }

    final document = await LocalDatabase.instance
        .collection('usuarios')
        .doc(uid)
        .get();

    if (!document.exists) return;

    final targetProfile = document.data();
    final targetRole = (targetProfile['funcao'] ?? '').toString();
    final permissions = AppPermissions.fromProfile(actor.profile);
    if (!permissions.canCreateOrManageUserRole(targetRole)) {
      throw const LocalAuthException(
        'Você não tem permissão para excluir esse usuário.',
      );
    }
    if (uid == actor.uid) {
      throw const LocalAuthException(
        'Não é permitido excluir a própria conta por esta tela.',
      );
    }

    final username = (targetProfile['usuario'] ?? '').toString();
    if (username.isNotEmpty) {
      _credentials.remove(username);
      await _saveCredentials();
    }

    await LocalDatabase.instance
        .collection('usuarios')
        .doc(uid)
        .delete();

    if (_currentUser?.uid == uid) {
      await signOut();
    }
  }

  Future<void> updateAccountProfile({
    required String uid,
    required Map<String, dynamic> updates,
  }) async {
    _ensureInitialized();

    final actor = _currentUser;
    if (actor == null) {
      throw const LocalAuthException(
        'Entre no aplicativo para gerenciar contas.',
      );
    }

    final reference = LocalDatabase.instance.collection('usuarios').doc(uid);
    final document = await reference.get();
    if (!document.exists) {
      throw const LocalAuthException('Usuário não encontrado.');
    }

    final currentProfile = document.data();
    final currentRole = (currentProfile['funcao'] ?? '').toString();
    final newRole = (updates['funcao'] ?? currentRole).toString();
    final permissions = AppPermissions.fromProfile(actor.profile);

    if (!permissions.canCreateOrManageUserRole(currentRole) ||
        !permissions.canCreateOrManageUserRole(newRole)) {
      throw const LocalAuthException(
        'Você não tem permissão para alterar esse usuário ou seu cargo.',
      );
    }
    if (!permissions.isAdministrator && currentRole != newRole) {
      throw const LocalAuthException(
        'Somente o Administrador pode alterar o cargo de uma conta.',
      );
    }

    await _validarDuasCompanhiasSeAssistente({
      ...currentProfile,
      ...updates,
      'funcao': newRole,
    });

    await reference.update(updates);

    if (_currentUser?.uid == uid) {
      final updatedProfile = {...currentProfile, ...updates};
      _currentUser = LocalAuthUser(
        uid: uid,
        username: _currentUser!.username,
        profile: updatedProfile,
      );
      await _saveProfileLocally(updatedProfile);
      _authChanges.add(_currentUser);
    }
  }

  Future<void> _validarDuasCompanhiasSeAssistente(
    Map<String, dynamic> profile,
  ) async {
    if ((profile['funcao'] ?? '').toString() !=
        AppPermissions.assistantCoordinator) {
      return;
    }

    final raw = profile['companhiasResponsaveis'];
    final companhias = raw is List
        ? raw.map((value) => value.toString().trim()).toSet().toList()
        : <String>[];

    if (companhias.length != 2 || companhias.any((nome) => nome.isEmpty)) {
      throw const LocalAuthException(
        'O Coordenador Assistente precisa ter exatamente duas companhias atribuídas.',
      );
    }

    final existentes = await LocalDatabase.instance
        .collection('companhias')
        .snapshots()
        .first;
    final nomesExistentes = existentes.docs
        .map((doc) => (doc['nome'] ?? '').toString())
        .toSet();

    if (companhias.any((nome) => !nomesExistentes.contains(nome))) {
      throw const LocalAuthException(
        'Selecione duas companhias cadastradas no sistema.',
      );
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _ensureInitialized();

    final user = _currentUser;
    if (user == null) {
      throw const LocalAuthException('Nenhum usuário está conectado.');
    }
    if (_credentials[user.username] != currentPassword) {
      throw const LocalAuthException('A senha atual está incorreta.');
    }
    if (newPassword.length < 6) {
      throw const LocalAuthException(
        'A nova senha deve ter no mínimo 6 caracteres.',
      );
    }

    _credentials[user.username] = newPassword;
    await _saveCredentials();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _currentUser = null;
    _authChanges.add(null);
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_credentialsKey, jsonEncode(_credentials));
  }

  Future<void> _saveProfileLocally(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'perfil_funcao',
      (profile['funcao'] ?? 'Consultor').toString(),
    );
    await prefs.setString(
      'perfil_nome',
      (profile['nome'] ?? 'Usuário').toString(),
    );
    await prefs.setString(
      'perfil_usuario',
      (profile['usuario'] ?? '').toString(),
    );
    await prefs.setString(
      'perfil_companhia',
      (profile['companhia'] ?? 'A Definir').toString(),
    );
    await prefs.setString(
      'perfil_genero',
      (profile['genero'] ?? 'Masculino').toString(),
    );
    await prefs.setString(
      'perfil_restricoes',
      (profile['saude'] ?? 'Nenhuma').toString(),
    );
    await prefs.setString(
      'perfil_alojamento',
      (profile['quarto'] ?? 'Bloco X - Quarto 00').toString(),
    );
    await prefs.setString(
      'perfil_adjunta',
      (profile['adjunta'] ?? 'Nome da Adjunta').toString(),
    );
    await prefs.setString(
      'perfil_responsavel',
      (profile['qtdJovens'] ?? '12').toString(),
    );
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'LocalAuthService.initialize() deve ser chamado antes de autenticar.',
      );
    }
  }
}
