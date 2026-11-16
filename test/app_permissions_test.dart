import 'package:flutter_test/flutter_test.dart';

import 'package:app_fsy/data/app_permissions.dart';

void main() {
  group('Permissões por responsabilidade', () {
    test('Administrador mantém acesso completo', () {
      final permissions = AppPermissions.fromProfile({
        'funcao': 'Administrador',
      });

      expect(permissions.canAccessAdminPanel, isTrue);
      expect(permissions.canManageYouthRegistry, isTrue);
      expect(permissions.canManageCompanyStructure, isTrue);
      expect(permissions.canAccessLodging, isTrue);
      expect(permissions.canManageAllUsers, isTrue);
    });

    test('Diretor e Coordenador gerenciam o evento e a equipe assistente', () {
      for (final role in ['Diretor', 'Coordenador']) {
        final permissions = AppPermissions.fromProfile({'funcao': role});

        expect(permissions.canAccessAdminPanel, isTrue);
        expect(permissions.canManageYouthRegistry, isTrue);
        expect(permissions.canManageCompanyStructure, isTrue);
        expect(permissions.canManageAssistantTeam, isTrue);
        expect(permissions.canCreateOrManageUserRole('Coordenador Assistente'), isTrue);
        expect(permissions.canCreateOrManageUserRole('Consultor'), isTrue);
        expect(permissions.canAccessLodging, isFalse);
        expect(permissions.canManageAllUsers, isFalse);
      }
    });

    test('Logística acessa alojamentos, mas não o cadastro geral', () {
      final permissions = AppPermissions.fromProfile({
        'funcao': 'Logística',
      });

      expect(permissions.canAccessLodging, isTrue);
      expect(permissions.canManageLodging, isTrue);
      expect(permissions.canManageYouthRegistry, isFalse);
      expect(permissions.canManageCompanyStructure, isFalse);
      expect(permissions.canAccessAdminPanel, isFalse);
    });

    test('Assistente administra somente as duas companhias atribuídas', () {
      final permissions = AppPermissions.fromProfile({
        'funcao': 'Coordenador Assistente',
        'companhiasResponsaveis': ['Companhia 01', 'Companhia 02'],
      });

      expect(permissions.assignedCompanies, ['Companhia 01', 'Companhia 02']);
      expect(permissions.canAccessCompany('Companhia 01'), isTrue);
      expect(permissions.canAccessCompany('Companhia 02'), isTrue);
      expect(permissions.canAccessCompany('Companhia 03'), isFalse);
      expect(permissions.canManageCompanyOperations('Companhia 01'), isTrue);
      expect(permissions.canManageCompanyOperations('Companhia 03'), isFalse);
      expect(permissions.canManageYouthRegistry, isFalse);
      expect(permissions.canManageCompanyStructure, isFalse);
      expect(permissions.canAccessLodging, isFalse);
      expect(permissions.canAccessAdminPanel, isFalse);
    });

    test('Consultor permanece limitado à companhia do próprio perfil', () {
      final permissions = AppPermissions.fromProfile({
        'funcao': 'Consultor',
        'companhia': 'Companhia 02',
        'companhiasResponsaveis': [],
      });

      expect(permissions.assignedCompanies, ['Companhia 02']);
      expect(permissions.canAccessCompany('Companhia 02'), isTrue);
      expect(permissions.canAccessCompany('Companhia 01'), isFalse);
      expect(permissions.canManageYouthRegistry, isFalse);
      expect(permissions.canAccessLodging, isFalse);
    });
  });
}
