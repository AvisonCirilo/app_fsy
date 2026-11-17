/// Centraliza as regras de acesso por responsabilidade no App FSY.
///
/// Esta camada controla a experiência local de desenvolvimento. Na versão
/// conectada ao backend, as mesmas regras também deverão ser aplicadas no
/// servidor, nunca apenas na interface.
class AppPermissions {
  AppPermissions.fromProfile(Map<String, dynamic> profile)
      : role = (profile['funcao'] ?? '').toString().trim(),
        assignedCompanies = _readAssignedCompanies(profile);

  final String role;
  final List<String> assignedCompanies;

  static const String administrator = 'Administrador';
  static const String director = 'Diretor';
  static const String coordinator = 'Coordenador';
  static const String assistantCoordinator = 'Coordenador Assistente';
  static const String logistics = 'Logística';
  static const String consultant = 'Consultor';

  static List<String> _readAssignedCompanies(Map<String, dynamic> profile) {
    final raw = profile['companhiasResponsaveis'];
    if (raw is List) {
      final companies = raw
          .map((value) => value.toString().trim())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList();
      if (companies.isNotEmpty) return companies.take(2).toList();
    }

    final singleCompany = (profile['companhia'] ?? '').toString().trim();
    return singleCompany.isEmpty || singleCompany == 'A Definir'
        ? <String>[]
        : <String>[singleCompany];
  }

  bool get isAdministrator => role == administrator;
  bool get isDirector => role == director;
  bool get isCoordinator => role == coordinator;
  bool get isAssistantCoordinator => role == assistantCoordinator;
  bool get isLogistics => role == logistics;
  bool get isConsultant => role == consultant;

  /// Administrador, Diretor e Coordenador gerenciam a estrutura geral do FSY.
  bool get canAccessAdminPanel =>
      isAdministrator || isDirector || isCoordinator;

  bool get canManageYouthRegistry => canAccessAdminPanel;
  bool get canManageCompanyStructure => canAccessAdminPanel;
  bool get canManageAssistantTeam => canAccessAdminPanel;

  /// Somente o Administrador pode administrar todos os cargos e contas.
  bool get canManageAllUsers => isAdministrator;
  bool get canManageUsers => canAccessAdminPanel;

  bool canCreateOrManageUserRole(String targetRole) {
    if (isAdministrator) return true;
    return (isDirector || isCoordinator) &&
        (targetRole == assistantCoordinator || targetRole == consultant);
  }

  /// Logística cuida da hospedagem; o Administrador mantém acesso de supervisão.
  bool get canAccessLodging => isAdministrator || isLogistics;
  bool get canManageLodging => canAccessLodging;

  bool get canAccessCompanyArea =>
      isAssistantCoordinator || isConsultant;

  bool canAccessCompany(String companyName) {
    if (isAdministrator || isDirector || isCoordinator) return true;
    return assignedCompanies.contains(companyName);
  }

  bool canManageCompanyOperations(String companyName) {
    if (isAssistantCoordinator || isConsultant) {
      return assignedCompanies.contains(companyName);
    }
    return isAdministrator || isDirector || isCoordinator;
  }

  bool get canChangeCompanyStructure => canAccessAdminPanel;
}
