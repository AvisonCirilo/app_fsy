# App FSY

Aplicativo Flutter para apoio à organização de eventos FSY.

> **Modo atual: desenvolvimento local.** A autenticação e os dados são fictícios e ficam armazenados no próprio dispositivo/navegador. O Firebase está temporariamente desconectado.

## Funcionalidades disponíveis

- Login local por usuário e senha.
- Perfis de demonstração para Administrador, Diretor, Coordenador, Coordenador Assistente, Logística e Consultor.
- Tela inicial com painéis conforme a função.
- Agenda com alterações locais.
- Companhia, membros e metas.
- Perfil, foto e preferência de tema claro/escuro.
- Gestão local de usuários, jovens, companhias e alojamentos.
- Persistência local das alterações entre reinicializações do aplicativo.

## Credenciais de demonstração

Todas as contas iniciais usam a senha **`fsy2026`**.

| Perfil | Usuário |
| --- | --- |
| Administrador | `admin` |
| Diretor | `diretor` |
| Coordenador | `coordenador` |
| Coordenador Assistente | `assistente` |
| Logística | `logistica` |
| Consultor | `consultor` |

As credenciais são públicas e servem exclusivamente para testes. O sistema local não oferece autenticação segura.

## Dados locais

A camada `lib/data/local_database.dart` fornece um armazenamento de demonstração para as coleções `usuarios`, `jovens` e `companhias`. As alterações são persistidas em `SharedPreferences` e não são sincronizadas entre dispositivos ou navegadores.

Os registros iniciais são dados fictícios. Não cadastre informações reais, especialmente dados pessoais, médicos ou de menores de idade.

Para voltar aos dados iniciais, limpe os dados locais do aplicativo/navegador (armazenamento do site). Isso remove também as contas e alterações criadas durante os testes.

## Tecnologias

- Flutter / Dart
- SharedPreferences
- image_picker
- url_launcher

Firebase Core, Firebase Authentication e Cloud Firestore foram removidos temporariamente do fluxo de execução e das dependências diretas. A integração poderá ser reconstruída em uma etapa futura, por meio de serviços/repositórios próprios.

## Executar localmente

Pré-requisitos: Flutter SDK e Chrome (para teste web).

```bash
flutter doctor
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

O comando `flutter pub get` atualiza o arquivo de resolução de dependências após a remoção do Firebase.

## Estrutura relevante

```text
lib/
├── data/
│   ├── local_auth_service.dart
│   └── local_database.dart
├── components/
└── telas/
    ├── login_tela.dart
    ├── home_tela.dart
    ├── recuperar_senhas.dart
    └── abas/
        ├── aba_inicio.dart
        ├── aba_agenda.dart
        ├── aba_companhia.dart
        ├── aba_perfil.dart
        ├── aba_admin.dart
        └── admin/
```

## Retorno ao Firebase

O modo local é temporário. Quando a interface e os fluxos estiverem aprovados, a autenticação e a persistência serão substituídas por implementações de backend, preservando os contratos das telas sempre que possível. Antes de produção, será necessário implementar autenticação real, autorização no servidor, regras de acesso e proteção dos dados conforme a LGPD.

## Licença

Nenhum arquivo de licença foi identificado nesta revisão.
