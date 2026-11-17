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

Diretores e Coordenadores podem cadastrar e gerenciar Consultores e Coordenadores Assistentes. Ao cadastrar um assistente, devem atribuir exatamente duas companhias diferentes. O assistente não pode cadastrar jovens no registro geral, criar ou renomear companhias, administrar usuários ou acessar outras companhias.

A Logística não administra o cadastro geral de jovens nem a estrutura das companhias. Seu painel apresenta os quantitativos necessários à hospedagem e permite operar o mapa de alojamentos. O Administrador mantém acesso de supervisão ao mapa.

A tela de permissões está centralizada em `lib/data/app_permissions.dart`. As telas administrativas e os serviços locais validam as operações de criação, edição e exclusão de contas.

> Estas regras são aplicadas no cliente durante o desenvolvimento local. Antes de produção, devem ser replicadas e impostas pelo backend; esconder uma tela no aplicativo não é controle de segurança suficiente.

## Gestão de equipe

As telas **Gerenciar Consultores** e **Gerenciar Assistentes** permitem à Direção e Coordenação administrar a equipe operacional. Na tela de assistentes, cada conta recebe exatamente duas companhias existentes. A atribuição fica no campo `companhiasResponsaveis` do perfil local.

## Painel de Logística

A função Logística recebe uma dashboard interativa com indicadores clicáveis de jovens cadastrados, jovens alojados, jovens sem alojamento e quartos em uso.

Ao abrir os detalhes, a equipe pode:
- Consultar a lista de todos os jovens e identificar a situação do alojamento.
- Visualizar jovens alojados em uma hierarquia expansível: andar → quarto → jovens.
- Consultar as pendências de alojamento e iniciar a alocação de um jovem.
- Explorar quartos em uso por andar e conferir quantos quartos e jovens estão em cada nível.
- Selecionar o andar e informar a identificação do quarto ao alocar ou transferir um jovem.

Os registros antigos que possuem apenas o campo `quarto` continuam compatíveis. Quando o nome do quarto termina em um número de três ou mais dígitos (por exemplo, `Bloco A - 101`), o sistema infere o andar pelo número. Novas alocações também salvam o campo `andar` separadamente para manter a organização.

O painel não exibe informações de saúde ou medicamentos dos jovens. Os dados continuam locais e fictícios enquanto o Firebase estiver desconectado.

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


## Aplicação Web (mobile-first)

O projeto mantém Flutter e Dart e pode ser executado como aplicação Web. A experiência prioriza celulares, com navegação inferior em telas estreitas e navegação lateral em tablets/computadores.

### Executar no navegador

```bash
flutter pub get
flutter run -d chrome
```

### Gerar a versão Web

```bash
flutter build web --release
```

### Abrir no iPhone

1. Publique a versão Web em um endereço HTTPS.
2. Abra o endereço no Safari do iPhone.
3. Toque em **Compartilhar** e escolha **Adicionar à Tela de Início**.
4. Abra o ícone FSY pela tela inicial para utilizar a experiência em modo de aplicativo.

O manifesto Web e as metatags para instalação no iOS estão em `web/manifest.json` e `web/index.html`. A instalação pela tela inicial não exige APK, IPA ou publicação na App Store.

### Publicação pelo GitHub Pages

O workflow manual `.github/workflows/flutter-web-pages.yml` prepara e publica a versão Web no endereço do projeto. Para habilitar a primeira publicação:

1. No GitHub, abra **Settings → Pages**.
2. Em **Build and deployment**, selecione **GitHub Actions** como fonte.
3. Abra **Actions → Deploy FSY Web** e execute **Run workflow** na branch de desenvolvimento.
4. Após a conclusão, o endereço será `https://avisoncirilo.github.io/app_fsy/`.

A publicação é pública porque o repositório também é público. O aplicativo continua em modo de demonstração: credenciais são fictícias e dados ficam no armazenamento local de cada navegador/dispositivo. Não inserir dados reais de jovens, equipe ou saúde. Usuários em dispositivos diferentes ainda não compartilham os mesmos dados; isso só será possível depois da integração com um backend seguro.

O build Web não remove os projetos Android/iOS existentes. Assim, podemos manter a possibilidade de gerar aplicativos nativos no futuro, sem exigir App Store para o acesso pelo navegador.


### Testar no celular pela rede Wi-Fi local (sem publicar)

É possível abrir a versão Web diretamente no Chrome do celular, sem instalar APK/IPA e sem publicar o site. O computador e o celular precisam estar conectados à mesma rede Wi-Fi.

No terminal do VS Code, dentro da pasta do projeto, execute:

```bash
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

Descubra o IPv4 do computador (no Windows, execute `ipconfig` e procure o endereço IPv4 do adaptador Wi-Fi). No Chrome do celular, abra `http://IP_DO_COMPUTADOR:8080`, substituindo pelo endereço encontrado, por exemplo `http://192.168.1.10:8080`.

Mantenha o terminal e o computador ligados durante o teste. Se o Windows Firewall perguntar, permita o Flutter/Dart na rede privada. Se a página não abrir, confirme que os dois dispositivos estão na mesma rede e que a porta 8080 não está bloqueada. Esse endereço é apenas local: não publica o aplicativo na internet. Para encerrar o servidor, pressione `Ctrl+C` no terminal.
