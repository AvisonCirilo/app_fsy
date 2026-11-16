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

## Matriz de permissões

O acesso é definido pela responsabilidade de cada função:

| Função | Permissões principais |
| --- | --- |
| Administrador | Acesso completo, incluindo contas, gestão do evento e alojamentos |
| Diretor | Gestão geral do evento, cadastro de jovens, companhias e equipe de assistentes |
| Coordenador | Gestão geral do evento, cadastro de jovens, companhias e equipe de assistentes |
| Logística | Painel de hospedagem, consulta de quantitativos e alocação/transferência de quartos |
| Coordenador Assistente | Gestão operacional de exatamente duas companhias atribuídas: metas e acompanhamento dos jovens vinculados |
| Consultor | Acompanhamento da companhia associada ao próprio perfil |

Diretores e Coordenadores podem cadastrar Coordenadores Assistentes e atribuir exatamente duas companhias diferentes a cada um. O assistente não pode cadastrar jovens no registro geral, criar ou renomear companhias, administrar usuários ou acessar outras companhias.

A Logística não administra o cadastro geral de jovens nem a estrutura das companhias. Seu painel apresenta os quantitativos necessários à hospedagem e permite operar o mapa de alojamentos. O Administrador mantém acesso de supervisão ao mapa.

A tela de permissões está centralizada em `lib/data/app_permissions.dart`. As telas administrativas e os serviços locais validam as operações de criação, edição e exclusão de contas.

> Estas regras são aplicadas no cliente durante o desenvolvimento local. Antes de produção, devem ser replicadas e impostas pelo backend; esconder uma tela no aplicativo não é controle de segurança suficiente.

## Gestão de equipe

A tela **Gerenciar Assistentes** permite cadastrar e editar coordenadores assistentes, atribuindo duas companhias existentes. A atribuição fica no campo `companhiasResponsaveis` do perfil local.

## Painel de Logística

A função Logística recebe uma aba própria com os quantitativos de jovens cadastrados, jovens alojados, pendências de alojamento e quartos em uso. O mapa permite alocar ou transferir jovens entre quartos sem expor os campos de saúde e medicamentos.

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
│   ├── app_permissions.dart
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
        ├── aba_companhias_assistente.dart
        ├── aba_logistica.dart
        ├── aba_perfil.dart
        ├── aba_admin.dart
        └── admin/
            └── gerenciar_assistentes.dart
```

## Retorno ao Firebase

O modo local é temporário. Quando a interface e os fluxos estiverem aprovados, a autenticação e a persistência serão substituídas por implementações de backend, preservando os contratos das telas sempre que possível. Antes de produção, será necessário implementar autenticação real, autorização no servidor, regras de acesso e proteção dos dados conforme a LGPD.

## Licença

Nenhum arquivo de licença foi identificado nesta revisão.
