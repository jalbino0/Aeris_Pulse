# Aeris Pulse

**Inteligência atmosférica para decisões mais conscientes.**

O **Aeris Pulse** é um aplicativo mobile desenvolvido em **Flutter e Dart**, voltado ao monitoramento da qualidade do ar, à análise de poluentes atmosféricos, ao acompanhamento de previsões ambientais e à identificação de condições que possam exigir maior atenção.

A solução reúne informações ambientais em uma interface intuitiva e personalizável, permitindo que os usuários acompanhem diferentes cidades brasileiras, visualizem tendências, consultem alertas preditivos e gerenciem suas preferências.

O projeto foi desenvolvido para a **Global Solution 2026.2 da FIAP**, no curso de Ciência da Computação, integrando desenvolvimento mobile, serviços em nuvem, análise de dados ambientais e persistência local.

---

## Sobre o projeto

A qualidade do ar é um fator importante para o meio ambiente e para a saúde da população. Entretanto, informações sobre concentrações de poluentes e previsões atmosféricas nem sempre são apresentadas de maneira centralizada, acessível e fácil de interpretar.

O Aeris Pulse foi desenvolvido com a proposta de aproximar essas informações do cotidiano das pessoas.

Por meio de consultas a serviços ambientais externos, o aplicativo apresenta estimativas de concentrações atmosféricas, tendências temporais e análises de condições futuras.

Além de consultar os dados de uma cidade, o usuário pode acompanhar outras localidades, salvar seus favoritos e personalizar a forma como deseja receber e visualizar informações.

O aplicativo também permite utilização sem cadastro, oferecendo sincronização opcional de preferências para usuários autenticados.

## Problema e motivação

As condições atmosféricas podem variar de acordo com a localidade, o horário e diversos fatores ambientais.

Embora existam plataformas que disponibilizam informações sobre qualidade do ar, esses dados podem ser difíceis de interpretar sem um contexto adequado.

Entre os principais desafios considerados no desenvolvimento do projeto, destacam-se:

- A necessidade de consultar informações ambientais de diferentes localidades.
- A dificuldade de interpretar concentrações de poluentes isoladamente.
- A importância de acompanhar mudanças e tendências ao longo do tempo.
- A necessidade de distinguir condições observadas ou estimadas de projeções futuras.
- A possibilidade de apresentar avisos ambientais de maneira compreensível.
- A necessidade de disponibilizar uma experiência acessível, com ou sem cadastro.

Esses desafios motivaram a criação de uma aplicação capaz de **centralizar, organizar e contextualizar informações atmosféricas**.

## Objetivos do projeto

### Objetivo geral

Desenvolver um aplicativo mobile que permita consultar e interpretar informações sobre qualidade do ar, utilizando dados e estimativas atmosféricas para apoiar o acompanhamento de condições ambientais em diferentes cidades.

### Objetivos específicos

- Consultar informações de qualidade do ar a partir de fontes ambientais externas.
- Apresentar concentrações estimadas dos principais poluentes atmosféricos.
- Organizar informações históricas e tendências em representações visuais.
- Disponibilizar previsões ambientais para diferentes horizontes temporais.
- Identificar condições preditivas que possam exigir atenção.
- Permitir o acompanhamento e gerenciamento de cidades favoritas.
- Implementar autenticação e sincronização opcional de preferências.
- Utilizar armazenamento local para persistência e cache.
- Disponibilizar notificações ambientais locais no Android.
- Desenvolver uma interface moderna, responsiva e adaptável aos temas claro e escuro.
- Validar regras de negócio e componentes por meio de testes automatizados.

---

## Solução proposta

O Aeris Pulse integra diferentes recursos em um único ambiente de monitoramento ambiental.

A aplicação consulta serviços externos, processa as informações recebidas e apresenta os resultados de maneira organizada.

O usuário pode selecionar a cidade que deseja monitorar, consultar os principais indicadores atmosféricos, acompanhar tendências e explorar projeções para períodos futuros.

As análises preditivas utilizam informações de previsões ambientais para identificar situações de atenção, enquanto o modo demonstrativo permite explorar cenários ilustrativos sem apresentá-los como ocorrências reais.

A arquitetura também combina armazenamento local e sincronização em nuvem, possibilitando uma experiência personalizada de acordo com a forma de acesso escolhida.

### Principais diferenciais

**Monitoramento de múltiplas cidades:** acompanhamento de diferentes localidades brasileiras, com seleção de uma cidade principal.

**Análise ambiental contextualizada:** apresentação de indicadores, concentrações e tendências, em vez de apenas valores isolados.

**Previsões atmosféricas:** consulta de projeções de poluentes em diferentes horizontes temporais.

**Alertas transparentes:** diferenciação entre análises baseadas em previsões ambientais e cenários demonstrativos.

**Acesso opcional com conta:** utilização como visitante ou sincronização de preferências com Firebase.

**Persistência híbrida:** utilização de armazenamento local e serviços em nuvem conforme a necessidade.

**Personalização visual:** temas claro, escuro e automático, acompanhando a preferência do usuário.

---

## Funcionalidades implementadas

### 1. Monitoramento da qualidade do ar

O aplicativo permite acompanhar informações ambientais relacionadas à cidade selecionada.

Entre os recursos disponíveis estão:

- Exibição da cidade atualmente monitorada.
- Consulta de concentrações atmosféricas estimadas.
- Identificação da fonte dos dados utilizados.
- Exibição do horário de referência das informações.
- Apresentação de indicadores ambientais.
- Classificação das condições conforme as regras implementadas no aplicativo.
- Acesso às análises detalhadas dos poluentes.

O objetivo é facilitar a interpretação das condições ambientais apresentadas.

### 2. Análise de poluentes atmosféricos

O Aeris Pulse oferece informações específicas sobre poluentes, incluindo:

- **MP2,5:** material particulado fino.
- **MP10:** material particulado inalável.
- **Ozônio (O₃):** poluente atmosférico associado a processos fotoquímicos.

As telas de análise apresentam recursos como:

- Concentrações estimadas dos poluentes.
- Variação em relação a períodos anteriores.
- Gráficos de evolução temporal.
- Dados históricos disponíveis.
- Indicadores estatísticos e tendências.
- Informações de contexto sobre as concentrações apresentadas.

Os gráficos auxiliam na interpretação das mudanças atmosféricas ao longo do tempo.

### 3. Previsões atmosféricas

O módulo de previsões permite analisar tendências futuras com base nos dados disponibilizados pelos serviços ambientais.

O usuário pode:

- Selecionar o poluente em análise.
- Consultar horizontes de 24, 48 e 72 horas.
- Visualizar projeções de concentração.
- Identificar períodos de maior concentração prevista.
- Consultar horários e referências temporais.
- Observar classificações estimadas para os cenários analisados.

As previsões são projeções de modelos atmosféricos e estão sujeitas a incertezas.

### 4. Alertas ambientais e análises preditivas

O aplicativo disponibiliza uma central dedicada à interpretação de possíveis condições ambientais desfavoráveis.

O módulo possui dois modos de funcionamento.

**Modo Previsão**

Utiliza informações provenientes das projeções atmosféricas para apresentar análises de condições futuras.

Entre os recursos estão:

- Interpretação das projeções disponíveis.
- Identificação de condições que merecem atenção.
- Apresentação de informações sobre cobertura dos dados.
- Comunicação das limitações das análises.
- Identificação do período de referência utilizado.

**Modo Demonstração**

Permite explorar cenários ilustrativos de alertas.

Os resultados desse modo são demonstrativos e não devem ser interpretados como condições ambientais reais.

O aplicativo também oferece configurações para habilitar ou desabilitar a apresentação das análises preditivas.

### 5. Notificações ambientais

O Aeris Pulse possui integração com notificações locais do Android.

As funcionalidades incluem:

- Ativação e desativação de notificações.
- Solicitação das permissões necessárias.
- Envio de notificações de teste.
- Apresentação de mensagens sobre o estado das permissões.
- Configuração independente da visualização dos alertas preditivos.

As notificações dependem das permissões do sistema e das condições de execução do aplicativo.

**A ativação desse recurso não representa monitoramento contínuo com o aplicativo fechado.**

### 6. Pesquisa e gerenciamento de cidades

O aplicativo permite pesquisar localidades brasileiras e organizar cidades de interesse.

Entre as funcionalidades estão:

- Pesquisa de cidades.
- Exibição de informações de localização.
- Seleção da cidade monitorada.
- Cadastro e remoção de cidades favoritas.
- Identificação visual da cidade ativa.
- Atualização das consultas ambientais ao alterar a localidade.

O usuário pode manter diferentes cidades favoritas e alternar entre elas conforme sua necessidade.

### 7. Autenticação e gerenciamento de conta

O Aeris Pulse utiliza **Firebase Authentication** para disponibilizar acesso autenticado.

As funcionalidades incluem:

- Cadastro com nome, e-mail e senha.
- Login com e-mail e senha.
- Recuperação de senha.
- Validação de campos.
- Exibição de mensagens de erro.
- Gerenciamento de informações da conta.
- Encerramento de sessão.
- Solicitação de exclusão de conta.
- Acesso às informações de privacidade.

O cadastro solicita a confirmação de leitura das informações de privacidade antes da criação da conta.

### 8. Acesso como visitante

A utilização do aplicativo não exige a criação de uma conta.

No modo visitante, o usuário pode explorar os recursos ambientais e utilizar preferências mantidas localmente.

A autenticação é opcional e permite vincular determinadas informações ao usuário no Firebase.

Os dados locais de visitante permanecem separados das preferências sincronizadas em nuvem.

### 9. Sincronização com Firebase

Para usuários autenticados, o aplicativo utiliza o **Cloud Firestore** para persistir informações relacionadas às preferências da conta.

Os recursos incluem:

- Armazenamento de cidades favoritas.
- Persistência da cidade monitorada.
- Recuperação de informações vinculadas à conta.
- Separação dos dados por identificador de usuário.
- Controle de acesso por regras de segurança do Firestore.

A sincronização permite recuperar preferências associadas à conta em instalações devidamente configuradas.

### 10. Armazenamento local e cache

O Aeris Pulse utiliza armazenamento local com SQLite para persistência e cache.

Entre suas aplicações estão:

- Armazenamento de preferências de visitante.
- Persistência local de informações relacionadas às cidades.
- Cache de respostas de consultas ambientais.
- Reutilização de dados previamente obtidos.
- Apoio ao funcionamento em situações de conectividade limitada.

O cache reduz a necessidade de repetir determinadas consultas e permite recuperar informações anteriormente armazenadas.

O aplicativo não substitui uma conexão com a internet para a obtenção de novos dados ambientais.

### 11. Personalização da interface

O aplicativo disponibiliza três opções de aparência:

- **Claro:** utiliza a identidade visual clara.
- **Escuro:** utiliza superfícies escuras e elementos de destaque em verde-menta.
- **Automático:** acompanha a configuração de aparência do sistema.

A preferência selecionada é persistida para as próximas utilizações.

A interface foi organizada com componentes reutilizáveis, hierarquia visual consistente e adaptação das principais telas.

---

## Tecnologias utilizadas

| Tecnologia | Aplicação no projeto |
|---|---|
| **Flutter** | Desenvolvimento mobile multiplataforma |
| **Dart** | Implementação da aplicação e regras de negócio |
| **Riverpod** | Gerenciamento de estado e integração entre funcionalidades |
| **GoRouter** | Organização de rotas e navegação |
| **Firebase Authentication** | Cadastro, autenticação e gerenciamento de usuários |
| **Cloud Firestore** | Persistência e sincronização de preferências |
| **SQLite** | Armazenamento local e cache |
| **Open-Meteo / CAMS** | Consulta de dados e estimativas atmosféricas |
| **Android Notifications** | Notificações ambientais locais |
| **Git e GitHub** | Versionamento e publicação do código |

---

## Arquitetura do aplicativo

O Aeris Pulse utiliza uma organização modular, separando as funcionalidades do sistema em diretórios específicos.

Essa estrutura facilita a manutenção, a evolução e os testes do aplicativo.

### Estrutura principal

```text
lib/
├── app/
│   └── app_shell.dart
│
├── core/
│   ├── domain/
│   ├── network/
│   ├── providers/
│   ├── storage/
│   ├── theme/
│   └── widgets/
│
├── features/
│   ├── air_quality/
│   ├── alerts/
│   ├── auth/
│   ├── forecasts/
│   ├── home/
│   ├── locations/
│   ├── onboarding/
│   └── settings/
│
└── main.dart
```

### Organização das responsabilidades

**app/**

Contém componentes relacionados à estrutura principal do aplicativo, incluindo a organização da navegação e das áreas acessíveis ao usuário.

**core/**

Reúne recursos compartilhados entre diferentes funcionalidades, como regras ambientais, comunicação com serviços externos, cache, armazenamento, temas e componentes reutilizáveis.

**features/**

Organiza as funcionalidades em módulos independentes, facilitando a separação das responsabilidades.

**main.dart**

Representa o ponto de entrada da aplicação.

### Organização dos módulos

Os módulos podem conter diretórios como:

| Diretório | Responsabilidade |
|---|---|
| `data/` | Serviços, modelos e mecanismos de persistência |
| `domain/` | Regras de negócio e processamento de informações |
| `presentation/` | Telas e componentes visuais |
| `providers/` | Estado e integração entre as camadas |

Essa organização permite manter a lógica de interface separada de parte das regras de negócio e dos mecanismos de acesso aos dados.

### Fluxo geral das informações

O funcionamento do aplicativo pode ser resumido nas seguintes etapas:

1. O usuário seleciona uma funcionalidade ou cidade.
2. A interface consulta os estados e provedores necessários.
3. Os serviços responsáveis verificam as informações disponíveis.
4. Quando necessário, são realizadas consultas às fontes externas.
5. Os dados recebidos são processados e disponibilizados para a interface.
6. Informações elegíveis podem ser armazenadas em cache.
7. Preferências são persistidas localmente ou no Firestore, conforme o modo de acesso.
8. As telas apresentam os resultados em indicadores, gráficos, cartões e análises.

### Persistência de informações

| Informação | Armazenamento |
|---|---|
| Preferências de cidades do visitante | SQLite local |
| Cidade monitorada do visitante | SQLite local |
| Favoritos de usuário autenticado | Cloud Firestore |
| Cidade monitorada de usuário autenticado | Cloud Firestore |
| Respostas ambientais em cache | Armazenamento local |
| Autenticação e identidade | Firebase Authentication |
| Preferência de aparência | Persistência local |

A utilização de armazenamento local e serviços em nuvem permite oferecer diferentes experiências sem exigir autenticação obrigatória.

---

## Galeria do aplicativo

As capturas abaixo apresentam as principais telas do **Aeris Pulse em seu tema escuro**.

As imagens estão organizadas em três colunas para facilitar a visualização da interface.

| Boas-vindas | Página inicial | Qualidade do ar |
|:---:|:---:|:---:|
| <img src="assets/screenshots/boas-vindas.png" alt="Tela de boas-vindas" width="235"> | <img src="assets/screenshots/home.png" alt="Página inicial" width="235"> | <img src="assets/screenshots/qualidade-ar.png" alt="Qualidade do ar" width="235"> |
| **Análise de poluentes** | **Previsões atmosféricas** | **Alertas ambientais** |
| <img src="assets/screenshots/poluentes.png" alt="Análise de poluentes" width="235"> | <img src="assets/screenshots/previsoes.png" alt="Previsões atmosféricas" width="235"> | <img src="assets/screenshots/alertas.png" alt="Alertas ambientais" width="235"> |
| **Cidades e favoritos** | **Login** | **Cadastro** |
| <img src="assets/screenshots/cidades.png" alt="Cidades favoritas" width="235"> | <img src="assets/screenshots/login.png" alt="Tela de login" width="235"> | <img src="assets/screenshots/cadastro.png" alt="Tela de cadastro" width="235"> |
| **Minha conta** | **Configurações** | **Privacidade e dados** |
| <img src="assets/screenshots/minha-conta.png" alt="Minha conta" width="235"> | <img src="assets/screenshots/configuracoes.png" alt="Configurações" width="235"> | <img src="assets/screenshots/privacidade.png" alt="Privacidade e dados" width="235"> |

---

## Demonstração em vídeo

O vídeo de apresentação demonstra o funcionamento do Aeris Pulse e suas principais funcionalidades.

A demonstração contempla recursos como:

- Navegação entre as telas.
- Monitoramento da qualidade do ar.
- Consulta de poluentes.
- Análise de previsões.
- Alertas ambientais.
- Pesquisa e gerenciamento de cidades.
- Autenticação e acesso como visitante.
- Configurações e personalização da interface.

**Vídeo de apresentação no YouTube:** link a adicionar após a publicação.

---

## Como executar o projeto

### Pré-requisitos

Para executar o Aeris Pulse localmente, são necessários:

- Flutter SDK instalado e configurado.
- Android SDK e ferramentas de desenvolvimento.
- Android Studio ou Visual Studio Code.
- Emulador Android ou dispositivo físico.
- Acesso à internet para consultas ambientais.
- Projeto Firebase configurado para a aplicação.

O Dart SDK acompanha a instalação do Flutter.

### 1. Clonar o repositório

```bash
git clone https://github.com/jalbino0/Aeris_Pulse.git
```

### 2. Acessar a pasta do projeto

```bash
cd Aeris_Pulse
```

### 3. Instalar as dependências

```bash
flutter pub get
```

### 4. Configurar o Firebase

O aplicativo utiliza serviços do Firebase para autenticação e sincronização de preferências.

Para executar o projeto, é necessário configurar uma aplicação Firebase compatível.

Os arquivos de configuração específicos do ambiente não são disponibilizados neste repositório.

Entre eles:

```text
lib/firebase_options.dart
android/app/google-services.json
```

A configuração pode ser realizada com o FlutterFire CLI:

```bash
flutterfire configure
```

Também é necessário habilitar e configurar os serviços utilizados, incluindo Firebase Authentication e Cloud Firestore.

As regras de segurança do Firestore devem restringir o acesso aos documentos associados a cada usuário autenticado.

**Importante:** os arquivos privados, chaves de assinatura, arquivos de ambiente e pacotes Android gerados são excluídos do versionamento conforme as regras do `.gitignore`.

### 5. Verificar os dispositivos disponíveis

```bash
flutter devices
```

### 6. Executar o aplicativo

```bash
flutter run
```

A execução pode ser realizada em um dispositivo Android físico ou em um emulador devidamente configurado.

---

## Testes e validação

O projeto possui testes automatizados para diferentes componentes e regras de negócio.

### Análise estática

Para verificar possíveis problemas identificados pelo analisador do Dart:

```bash
flutter analyze
```

### Testes automatizados

Para executar a suíte de testes:

```bash
flutter test
```

### Formatação

Para aplicar a formatação padrão do Dart:

```bash
dart format lib
```

### Áreas cobertas pelos testes

O projeto contém testes relacionados a:

- Análises de qualidade do ar.
- Regras de classificação ambiental.
- Processamento de informações de poluentes.
- Estatísticas ambientais.
- Mecanismos de alertas.
- Validação de alertas seguros.
- Análises de previsões.
- Tratamento de horários e fusos.
- Consultas e pesquisa de cidades.
- Seleção de cidade monitorada.
- Persistência de preferências.
- Armazenamento em cache.
- Consultas com cache em múltiplas cidades.
- Atualização global de informações.
- Componentes de interface.

### Validação funcional

A aplicação também foi executada em ambiente Flutter para verificar a integração e a navegação entre as telas.

Foram conferidos visualmente os temas claro e escuro, incluindo elementos de interface, contrastes, botões, campos de entrada e cartões informativos.

A existência dos testes automatizados não elimina a necessidade de validação das integrações externas e das permissões específicas do dispositivo Android.

---

## Privacidade e gerenciamento de dados

O Aeris Pulse foi desenvolvido com autenticação opcional.

O usuário pode acessar informações ambientais sem criar uma conta, utilizando recursos de armazenamento local.

Ao optar pelo cadastro, informações relacionadas à conta e às preferências sincronizadas passam a ser gerenciadas pelos serviços Firebase utilizados.

### Informações de autenticação

O cadastro utiliza nome, e-mail e senha.

A autenticação é processada pelo Firebase Authentication.

A senha não é armazenada nos documentos de favoritos ou preferências do Cloud Firestore.

### Informações sincronizadas

Para usuários autenticados, informações como cidades favoritas e cidade monitorada podem ser associadas à conta.

### Dados locais

O aplicativo também utiliza armazenamento local para preferências de visitante e cache ambiental.

A exclusão da conta em nuvem não significa necessariamente a exclusão de todos os arquivos locais do dispositivo.

### Exclusão de conta

Usuários autenticados podem solicitar a exclusão da conta pelo aplicativo.

O processo inclui confirmação de identidade e operações de remoção relacionadas aos dados associados à conta.

O aplicativo disponibiliza uma tela específica para apresentar informações sobre privacidade e gerenciamento de dados.

---

## Fontes e interpretação dos dados ambientais

O Aeris Pulse utiliza dados e estimativas disponibilizados por serviços ambientais externos, incluindo **Open-Meteo/CAMS**.

Essas informações permitem apresentar concentrações atmosféricas e projeções temporais conforme a disponibilidade dos serviços consultados.

### Limitações importantes

**Dados estimados**

As concentrações apresentadas podem representar estimativas provenientes de modelos atmosféricos.

**Não equivalência a medições oficiais**

As informações não devem ser interpretadas automaticamente como medições realizadas por estações oficiais, incluindo estações da CETESB.

**Incerteza das previsões**

As projeções futuras estão sujeitas às limitações dos modelos, da resolução espacial e da disponibilidade dos dados.

**Cobertura e disponibilidade**

A disponibilidade das informações pode variar conforme a cidade, o poluente, o período e as condições de comunicação com os serviços externos.

**Alertas demonstrativos**

Os cenários demonstrativos são ilustrativos e não representam necessariamente situações ambientais reais.

**Notificações**

As notificações locais dependem das permissões do Android e das condições de execução do aplicativo.

**Funcionamento offline**

O armazenamento local pode disponibilizar dados previamente consultados, mas não garante atualização das informações sem conexão.

O Aeris Pulse possui finalidade informativa e não substitui orientações de órgãos ambientais, autoridades de saúde ou serviços oficiais de monitoramento.

---

## Desafios e aprendizados

O desenvolvimento do Aeris Pulse envolveu a aplicação de diferentes conhecimentos de Ciência da Computação e engenharia de software.

### Integração de serviços externos

A utilização de dados atmosféricos exigiu a organização das consultas, o tratamento das respostas e a disponibilização das informações para diferentes telas.

### Gerenciamento de estado

O Riverpod foi utilizado para organizar estados da aplicação, conectar funcionalidades e atualizar a interface conforme a disponibilidade das informações.

### Persistência local e em nuvem

A combinação entre SQLite e Firebase permitiu trabalhar com estratégias diferentes de armazenamento, de acordo com o modo de utilização.

### Autenticação e privacidade

A implementação de cadastro, login, recuperação de senha e exclusão de conta envolveu conceitos de autenticação e gerenciamento de dados associados ao usuário.

### Análise de informações ambientais

O processamento de concentrações, séries temporais e previsões permitiu aplicar regras de negócio e construir representações visuais contextualizadas.

### Desenvolvimento de interfaces

A implementação dos temas claro e escuro, da navegação e dos componentes reutilizáveis permitiu trabalhar princípios de consistência visual, responsividade e experiência do usuário.

### Testes e qualidade de software

A construção de testes automatizados auxiliou na validação de regras e comportamentos específicos, contribuindo para a manutenção e evolução do projeto.

---

## Entrega do projeto

A entrega do Aeris Pulse contempla os seguintes componentes:

| Item | Descrição |
|---|---|
| **Código-fonte** | Aplicação Flutter organizada em módulos |
| **Interface mobile** | Telas de monitoramento, análise, conta e configurações |
| **Integração ambiental** | Consultas a serviços de dados atmosféricos |
| **Autenticação** | Firebase Authentication |
| **Persistência** | SQLite e Cloud Firestore |
| **Análises e alertas** | Previsões, classificações e notificações locais |
| **Testes** | Arquivos de testes automatizados |
| **Documentação** | README com informações técnicas |
| **Capturas de tela** | Galeria com 12 imagens do aplicativo |
| **Vídeo demonstrativo** | Seção reservada ao link do YouTube |

Os arquivos de instalação utilizados para testes não fazem parte do repositório de código-fonte.

---

## Equipe de desenvolvimento

Projeto desenvolvido pelos seguintes integrantes:

| Integrante | Registro acadêmico |
|---|---|
| **João Pedro de Moura Albino** | **RM565323** |
| **Kauê Silva Matheus** | **RM561675** |
| **Giovanna Fernandes Pereira** | **RM565434** |

**Instituição:** FIAP — Faculdade de Informática e Administração Paulista

**Curso:** Ciência da Computação

**Projeto:** Global Solution — 2º semestre de 2026

---

## Licença e finalidade acadêmica

O Aeris Pulse foi desenvolvido para fins acadêmicos no contexto da Global Solution da FIAP.

O repositório disponibiliza o código-fonte e a documentação do projeto para apresentação e avaliação.

Não foi definida uma licença de software específica neste repositório.

---

## Repositório

**Aeris Pulse — GitHub**

https://github.com/jalbino0/Aeris_Pulse

---

**Aeris Pulse — Inteligência no ar. Clareza na vida.**
