# Aeris Pulse

<p align="center">
  <img src="assets/images/aeris_logo.png" alt="Logotipo Aeris Pulse" width="120">
</p>

<p align="center">
  <strong>Inteligência no ar. Clareza na vida.</strong>
</p>

O **Aeris Pulse** é um aplicativo mobile desenvolvido em **Flutter e Dart** para monitoramento da qualidade do ar, análise de poluentes atmosféricos, acompanhamento de previsões ambientais e identificação de condições que possam exigir atenção.

A solução reúne informações ambientais em uma interface intuitiva e personalizável, permitindo acompanhar diferentes cidades brasileiras, visualizar tendências, consultar alertas preditivos e gerenciar preferências.

O projeto foi desenvolvido para a **Global Solution 2026.2 da FIAP**, no desafio **Territory Predictive Insights**, integrando desenvolvimento mobile, análise de dados ambientais, serviços em nuvem e persistência local.

---

## 1. Problema, público-alvo e impacto social

### Contextualização do problema

A qualidade do ar é um fator importante para o meio ambiente, para a saúde pública e para a qualidade de vida da população.

As concentrações de poluentes atmosféricos podem variar de acordo com a cidade, o horário, as condições meteorológicas e outros fatores ambientais.

Apesar da existência de plataformas que disponibilizam informações atmosféricas, a interpretação desses dados pode ser complexa para pessoas que não possuem conhecimentos técnicos sobre o assunto.

Entre os principais desafios identificados estão:

- Dificuldade de acompanhar informações ambientais de diferentes localidades.
- Necessidade de interpretar concentrações de poluentes de maneira contextualizada.
- Ausência de informações facilmente compreensíveis sobre tendências futuras.
- Dificuldade de identificar períodos que possam apresentar condições ambientais desfavoráveis.
- Necessidade de distinguir estimativas, previsões e informações demonstrativas.
- Importância de oferecer uma experiência acessível, independentemente da criação de uma conta.

Esses desafios motivaram o desenvolvimento de uma aplicação capaz de **centralizar, organizar e contextualizar informações sobre a qualidade do ar**.

### Público-alvo

O Aeris Pulse foi desenvolvido para atender principalmente:

**Cidadãos e moradores de centros urbanos:** pessoas interessadas em acompanhar as condições ambientais das localidades em que vivem, trabalham ou realizam suas atividades.

**Pessoas sensíveis às condições ambientais:** usuários que desejam consultar informações sobre concentrações atmosféricas e períodos potencialmente desfavoráveis, sem substituir orientações médicas ou oficiais.

**Estudantes e pesquisadores:** pessoas interessadas em explorar dados ambientais, séries temporais e tendências atmosféricas.

**Gestores e profissionais interessados em informações territoriais:** usuários que necessitam consultar indicadores e projeções ambientais para apoiar análises e decisões humanas.

### Objetivo geral

Desenvolver um aplicativo mobile capaz de consultar, processar e apresentar informações sobre qualidade do ar, utilizando dados e estimativas atmosféricas para apoiar o acompanhamento de condições ambientais em diferentes cidades.

### Objetivos específicos

- Consultar dados ambientais disponibilizados por fontes externas.
- Apresentar indicadores de qualidade do ar de forma compreensível.
- Disponibilizar análises de concentrações e tendências de poluentes.
- Permitir a consulta de previsões atmosféricas.
- Identificar condições futuras que possam exigir atenção.
- Apresentar alertas com justificativas, confiança e limitações.
- Permitir o gerenciamento de cidades favoritas.
- Disponibilizar autenticação e sincronização opcionais.
- Utilizar armazenamento local e cache.
- Oferecer personalização visual e configurações de notificações.
- Validar funcionalidades por meio de testes automatizados.

### Impacto social esperado

O Aeris Pulse busca contribuir para a **democratização do acesso a informações ambientais**, apresentando dados técnicos de maneira mais acessível.

A centralização das informações pode auxiliar cidadãos a compreender melhor as condições atmosféricas de suas cidades e consultar tendências antes de planejar determinadas atividades.

A aplicação também busca estimular o interesse pela qualidade ambiental urbana e pelo uso de dados públicos como ferramentas de informação à sociedade.

O impacto esperado está relacionado a:

- Maior acessibilidade às informações atmosféricas.
- Melhor compreensão dos indicadores ambientais.
- Apoio ao planejamento individual diante de condições desfavoráveis.
- Incentivo ao acompanhamento das condições ambientais locais.
- Disponibilização de informações para diferentes cidades brasileiras.

**O Aeris Pulse não realiza decisões automáticas de alto impacto.** Os indicadores, previsões e alertas possuem caráter informativo, e a decisão final permanece sob responsabilidade humana.

---

## 2. Integrantes

O projeto foi desenvolvido pelos seguintes integrantes:

| Integrante | Registro acadêmico |
|---|---|
| **João Pedro de Moura Albino** | **RM565323** |
| **Kauê Silva Matheus** | **RM561675** |
| **Giovanna Fernandes Pereira** | **RM565434** |

**Instituição:** FIAP — Faculdade de Informática e Administração Paulista

**Curso:** Ciência da Computação

**Disciplina:** Cross-Platform Application Development

**Projeto:** Global Solution — 2º semestre de 2026

**Desafio:** Territory Predictive Insights

**Repositório:** https://github.com/jalbino0/Aeris_Pulse

---

## 3. Demonstração visual

As capturas abaixo apresentam as principais telas do **Aeris Pulse em seu tema escuro**.

A interface utiliza uma identidade visual própria, com tons de azul-petróleo, verde-menta e componentes organizados para favorecer a leitura e a navegação.

### Galeria do aplicativo

| Boas-vindas | Página inicial | Qualidade do ar |
|:---:|:---:|:---:|
| <img src="assets/screenshots/boas-vindas.png" alt="Tela de boas-vindas" width="235"> | <img src="assets/screenshots/home.png" alt="Página inicial" width="235"> | <img src="assets/screenshots/qualidade-ar.png" alt="Qualidade do ar" width="235"> |
| **Análise de poluentes** | **Previsões atmosféricas** | **Alertas ambientais** |
| <img src="assets/screenshots/poluentes.png" alt="Análise de poluentes" width="235"> | <img src="assets/screenshots/previsoes.png" alt="Previsões atmosféricas" width="235"> | <img src="assets/screenshots/alertas.png" alt="Alertas ambientais" width="235"> |
| **Cidades e favoritos** | **Login** | **Cadastro** |
| <img src="assets/screenshots/cidades.png" alt="Cidades favoritas" width="235"> | <img src="assets/screenshots/login.png" alt="Tela de login" width="235"> | <img src="assets/screenshots/cadastro.png" alt="Tela de cadastro" width="235"> |
| **Minha conta** | **Configurações** | **Privacidade e dados** |
| <img src="assets/screenshots/minha-conta.png" alt="Minha conta" width="235"> | <img src="assets/screenshots/configuracoes.png" alt="Configurações" width="235"> | <img src="assets/screenshots/privacidade.png" alt="Privacidade e dados" width="235"> |

### Identidade visual

O Aeris Pulse possui uma identidade visual desenvolvida para transmitir clareza, confiança e conexão com o monitoramento ambiental.

Os principais elementos incluem:

- Logotipo próprio.
- Paleta de cores temática.
- Hierarquia tipográfica consistente.
- Cartões informativos e indicadores visuais.
- Gráficos de evolução atmosférica.
- Navegação inferior entre os principais módulos.
- Ícones relacionados às funcionalidades.
- Estados visuais de carregamento, seleção e erro.
- Temas claro, escuro e automático.

A interface foi desenvolvida para facilitar o acesso às informações e a interpretação dos resultados.

---

## 4. Funcionalidades implementadas

### Checklist geral

- [x] Monitoramento de qualidade do ar.
- [x] Consulta de concentrações atmosféricas.
- [x] Classificação de indicadores ambientais.
- [x] Análise detalhada de poluentes.
- [x] Visualização de histórico e tendências.
- [x] Gráficos de evolução temporal.
- [x] Previsões atmosféricas.
- [x] Seleção de horizontes de previsão.
- [x] Alertas preditivos.
- [x] Justificativas e informações de transparência dos alertas.
- [x] Modo demonstrativo de alertas.
- [x] Notificações ambientais locais.
- [x] Pesquisa de cidades brasileiras.
- [x] Gerenciamento de cidades favoritas.
- [x] Seleção da cidade monitorada.
- [x] Cadastro e autenticação com Firebase.
- [x] Recuperação de senha.
- [x] Exclusão de conta.
- [x] Acesso sem cadastro.
- [x] Sincronização de preferências com Firestore.
- [x] Armazenamento local com SQLite.
- [x] Cache de informações ambientais.
- [x] Tratamento de estados de carregamento e erro.
- [x] Formulários com validação.
- [x] Tema claro.
- [x] Tema escuro.
- [x] Tema automático.
- [x] Persistência da preferência visual.
- [x] Tela de privacidade e consentimento.
- [x] Testes automatizados.
- [x] Indicador de benefício social potencial, com antecedência estimada até o pico de poluentes.

### 4.1. Monitoramento da qualidade do ar

O aplicativo permite acompanhar informações ambientais relacionadas à cidade selecionada.

As funcionalidades incluem:

- Identificação da cidade monitorada.
- Consulta de concentrações atmosféricas estimadas.
- Exibição da fonte das informações.
- Apresentação do horário de referência.
- Classificação dos indicadores ambientais.
- Consulta de dados históricos disponíveis.
- Acesso às análises detalhadas dos poluentes.

O objetivo é permitir que o usuário compreenda as condições ambientais apresentadas sem depender exclusivamente de valores numéricos isolados.

### 4.2. Análise de poluentes

O Aeris Pulse oferece informações específicas sobre poluentes atmosféricos, incluindo:

**MP2,5:** material particulado fino.

**MP10:** material particulado inalável.

**Ozônio (O₃):** poluente atmosférico associado a processos fotoquímicos.

As telas permitem acompanhar:

- Concentrações estimadas.
- Variações temporais.
- Gráficos de evolução.
- Informações históricas disponíveis.
- Indicadores estatísticos.
- Tendências de concentração.

As informações são apresentadas conforme a disponibilidade dos dados consultados.

### 4.3. Previsões atmosféricas

O módulo de previsões permite analisar tendências futuras com base em projeções ambientais.

O usuário pode:

- Selecionar o poluente.
- Escolher horizontes de 24, 48 ou 72 horas.
- Consultar concentrações previstas.
- Identificar períodos de maior concentração.
- Visualizar classificações estimadas.
- Acompanhar o horário de referência das projeções.

As previsões representam resultados estimados pelos modelos consultados e estão sujeitas a incertezas.

### 4.4. Alertas ambientais

O aplicativo disponibiliza uma central de alertas para apresentar condições que possam exigir atenção.

A funcionalidade possui dois modos.

**Modo Previsão**

Utiliza projeções atmosféricas para realizar análises preditivas.

Os resultados são acompanhados de informações sobre:

- Condições identificadas.
- Evidências utilizadas.
- Classificação do alerta.
- Nível de confiança informado pela análise.
- Cobertura dos dados.
- Limitações e incertezas.
- Período de referência.

**Modo Demonstração**

Permite explorar cenários ilustrativos de alertas ambientais.

Esse modo foi desenvolvido para demonstrar o funcionamento da análise sem apresentar os resultados simulados como ocorrências reais.

### 4.5. Notificações ambientais

O Aeris Pulse possui integração com notificações locais do Android.

O usuário pode:

- Habilitar ou desabilitar notificações.
- Gerenciar a autorização necessária.
- Enviar uma notificação de teste.
- Consultar mensagens relacionadas às permissões.

A ativação das notificações não representa monitoramento contínuo com o aplicativo fechado.

### 4.6. Cidades e favoritos

O aplicativo permite pesquisar e acompanhar diferentes cidades brasileiras.

Entre os recursos estão:

- Pesquisa de localidades.
- Seleção da cidade principal.
- Cadastro de cidades favoritas.
- Remoção de favoritos.
- Identificação da cidade monitorada.
- Atualização das consultas ao alterar a cidade.

### 4.7. Autenticação e contas

O aplicativo utiliza Firebase Authentication para permitir a criação e o gerenciamento de contas.

As funcionalidades incluem:

- Cadastro com nome, e-mail e senha.
- Login.
- Recuperação de senha.
- Validação de campos.
- Mensagens de erro.
- Encerramento da sessão.
- Gerenciamento e exclusão de conta.

### 4.8. Acesso como visitante

O Aeris Pulse pode ser utilizado sem cadastro.

Nesse modo, o usuário continua tendo acesso às funcionalidades ambientais e utiliza preferências mantidas localmente no dispositivo.

A criação de uma conta é opcional.

### 4.9. Sincronização de preferências

Usuários autenticados podem utilizar o Cloud Firestore para armazenar informações associadas à conta.

Entre elas:

- Cidades favoritas.
- Cidade monitorada.
- Preferências relacionadas à experiência do usuário.

Os documentos são associados ao identificador da conta e protegidos pelas regras de acesso configuradas.

### 4.10. Armazenamento local e cache

O aplicativo utiliza SQLite para persistir informações locais e armazenar respostas ambientais em cache.

Isso permite:

- Manter preferências de visitantes.
- Reutilizar informações previamente consultadas.
- Reduzir determinadas consultas repetidas.
- Recuperar dados armazenados quando não há conexão.

Novas atualizações ambientais dependem da disponibilidade dos serviços externos.

### 4.11. Personalização

O aplicativo disponibiliza três opções de aparência:

- **Claro:** identidade visual clara.
- **Escuro:** superfícies escuras e destaques em verde-menta.
- **Automático:** acompanha a configuração do sistema.

A preferência selecionada é mantida para utilizações posteriores.

---

## 5. Dados, modelos e alertas preditivos

### 5.1. Fontes de dados

O Aeris Pulse utiliza dados e estimativas atmosféricas disponibilizados por serviços externos, incluindo **Open-Meteo/CAMS**.

Esses serviços permitem consultar informações relacionadas à composição atmosférica e a projeções ambientais.

Os dados podem incluir concentrações estimadas de diferentes poluentes ao longo do tempo.

A aplicação utiliza essas informações para alimentar os indicadores, gráficos, previsões e análises apresentadas na interface.

### 5.2. Processamento das informações

As respostas provenientes dos serviços ambientais são tratadas pelos módulos de dados e domínio do aplicativo.

O processamento envolve:

1. Solicitação das informações para a cidade selecionada.
2. Recebimento das respostas dos serviços externos.
3. Organização dos dados por poluente e período.
4. Tratamento de valores e referências temporais.
5. Aplicação das regras de análise ambiental.
6. Cálculo dos indicadores e tendências implementados.
7. Disponibilização dos resultados para as telas.
8. Armazenamento em cache quando aplicável.

### 5.3. Indicadores e métricas utilizados

Entre os indicadores apresentados ou utilizados nas análises estão:

| Indicador | Finalidade |
|---|---|
| Concentração de MP2,5 | Acompanhamento de material particulado fino |
| Concentração de MP10 | Acompanhamento de material particulado inalável |
| Concentração de O₃ | Acompanhamento de ozônio atmosférico |
| Variação temporal | Comparação de concentrações entre períodos |
| Histórico de concentrações | Visualização da evolução das condições |
| Médias móveis | Análise de tendências e projeções |
| Maior concentração média prevista | Identificação de períodos desfavoráveis |
| Classificação ambiental | Contextualização dos indicadores |
| Cobertura dos dados | Identificação da disponibilidade de informações |
| Confiança da análise | Comunicação das limitações da interpretação |

As métricas apresentadas não devem ser confundidas automaticamente com medições oficiais ou com uma avaliação estatística de acurácia do modelo.

### 5.4. Geração dos alertas

Os alertas preditivos são produzidos por regras de análise aplicadas aos dados atmosféricos e às projeções disponíveis.

O processamento considera as informações ambientais utilizadas pela aplicação, as classificações implementadas e os períodos analisados.

O resultado busca identificar cenários que possam exigir atenção.

Cada alerta apresenta informações que auxiliam na interpretação, incluindo:

- Condição identificada.
- Evidência ou justificativa.
- Classificação do cenário.
- Informação de confiança.
- Limitações da análise.
- Período correspondente.

### 5.5. Transparência e confiança

O Aeris Pulse apresenta informações sobre a confiabilidade e as limitações de suas análises.

A disponibilidade dos dados pode ser indicada por métricas de cobertura, como a quantidade de períodos válidos em relação ao total solicitado.

**Cobertura de dados não equivale à precisão da previsão.**

A existência de uma série temporal completa não significa que a projeção tenha sido validada por medições locais.

O nível de confiança apresentado deve ser interpretado conforme a metodologia implementada e suas limitações.

Não se deve assumir uma probabilidade estatística de acerto sem validação quantitativa correspondente.

### 5.6. Limitações dos modelos

As informações apresentadas podem representar estimativas produzidas por modelos atmosféricos.

Entre suas limitações estão:

- Resolução espacial dos dados.
- Diferenças entre condições regionais e locais.
- Incerteza associada às projeções futuras.
- Possíveis lacunas nas séries temporais.
- Diferenças entre estimativas e medições de sensores.
- Dependência da disponibilidade dos serviços externos.
- Possibilidade de atualização ou revisão das previsões.

As condições reais de uma localidade específica podem diferir das estimativas disponíveis.

### 5.7. Possíveis vieses e fontes de incerteza

A utilização de modelos atmosféricos pode envolver limitações relacionadas à representatividade geográfica e temporal.

Por exemplo, uma estimativa regional pode não representar com exatidão as condições de uma rua ou bairro.

Também podem existir diferenças de cobertura e disponibilidade entre localidades e períodos.

Essas limitações devem ser consideradas durante a interpretação dos indicadores.

### 5.8. Quando as previsões não são confiáveis

O usuário deve ter cautela especialmente quando:

- Os dados estiverem incompletos ou desatualizados.
- A cobertura das informações for insuficiente.
- Houver falha de comunicação com o serviço externo.
- A localidade apresentar condições muito específicas não representadas pela resolução dos dados.
- A previsão estiver sendo utilizada como substituta de medições oficiais.
- Não houver validação local que permita quantificar a precisão das projeções.

### 5.9. Supervisão humana

Os alertas ambientais apresentados pelo Aeris Pulse possuem finalidade informativa.

O aplicativo não realiza decisões automáticas de alto impacto.

**A decisão final deve permanecer sob responsabilidade humana**, considerando as condições locais, as informações disponíveis e as orientações das autoridades competentes.

---

## 6. Privacidade, inclusão e acessibilidade

### 6.1. Privacidade dos usuários

O Aeris Pulse permite utilização sem cadastro, reduzindo a necessidade de fornecimento de informações pessoais para acessar as funcionalidades ambientais.

A autenticação é opcional.

Ao optar pelo cadastro, o usuário informa nome, e-mail e senha.

A autenticação é processada pelo Firebase Authentication.

### 6.2. Proteção de dados

O aplicativo utiliza mecanismos de armazenamento diferentes conforme o modo de acesso.

| Tipo de informação | Serviço utilizado |
|---|---|
| Identidade e autenticação | Firebase Authentication |
| Favoritos de usuário autenticado | Cloud Firestore |
| Cidade monitorada de usuário autenticado | Cloud Firestore |
| Preferências de visitante | SQLite local |
| Cache ambiental | Armazenamento local |

Os documentos associados aos usuários autenticados são organizados por identificador de conta, com controle de acesso por regras do Firebase.

As senhas não são armazenadas nos documentos de favoritos ou preferências do Firestore.

### 6.3. Consentimento

O cadastro possui uma etapa de consentimento explícito.

Antes de criar a conta, o usuário deve confirmar a leitura das informações de privacidade e concordar com o tratamento das informações necessárias à autenticação e à sincronização de preferências.

O aplicativo disponibiliza uma tela específica para consulta dessas informações.

### 6.4. Gerenciamento e exclusão de conta

Usuários autenticados podem solicitar a exclusão da conta diretamente pelo aplicativo.

O processo envolve confirmação da identidade e operações relacionadas à exclusão dos dados associados à conta.

A exclusão da conta em nuvem não significa necessariamente a remoção de todos os arquivos locais ou dados armazenados em cache.

### 6.5. Inclusão digital

O Aeris Pulse foi desenvolvido para permitir o acesso às informações ambientais mesmo sem cadastro.

Essa característica reduz barreiras de entrada e permite explorar as funcionalidades principais sem a necessidade de criar uma conta.

A interface também busca apresentar dados técnicos em linguagem compreensível, associando informações numéricas a classificações, gráficos e descrições.

### 6.6. Acessibilidade

A interface foi desenvolvida considerando recursos como:

- Contraste entre textos e superfícies.
- Hierarquia tipográfica.
- Identificação visual dos elementos interativos.
- Mensagens de validação e erro.
- Componentes reutilizáveis.
- Organização das informações por seções.
- Legibilidade com ampliação de texto.
- Adaptação a diferentes dimensões de tela.

Durante a validação visual, foram conferidos os temas, o contraste, a ampliação de fontes e a apresentação em diferentes tamanhos de tela.

Os controles que possuem descrições semânticas específicas contribuem para a identificação de suas funcionalidades por recursos de acessibilidade.

### 6.7. Benefício social

O Aeris Pulse apresenta um indicador de benefício social potencial, calculado a partir da antecedência estimada entre o horário de referência da previsão e o pico previsto de concentração de poluentes. Por exemplo, o aplicativo pode identificar 10 horas de antecedência até um pico de MP2,5, oferecendo uma janela potencial para planejamento preventivo. Esse indicador não representa impacto social diretamente medido e está sujeito às incertezas da previsão.

---

## 7. Tecnologias, arquitetura e decisões técnicas

### 7.1. Tecnologias utilizadas

| Tecnologia | Aplicação | Justificativa |
|---|---|---|
| **Flutter** | Desenvolvimento mobile | Permite construir interfaces com componentes reutilizáveis e identidade visual consistente |
| **Dart** | Implementação da aplicação | Linguagem utilizada pelo Flutter, com suporte a programação assíncrona e orientação a objetos |
| **Riverpod** | Gerenciamento de estado | Organiza estados compartilhados e dependências entre funcionalidades |
| **GoRouter** | Navegação | Facilita a definição de rotas e a organização dos fluxos de telas |
| **Firebase Authentication** | Autenticação | Disponibiliza cadastro, login e gerenciamento de usuários |
| **Cloud Firestore** | Persistência em nuvem | Permite armazenar e recuperar preferências vinculadas às contas |
| **SQLite** | Armazenamento local | Possibilita persistência estruturada e cache no dispositivo |
| **Open-Meteo/CAMS** | Dados atmosféricos | Disponibiliza estimativas e projeções ambientais para consulta |
| **Notificações Android** | Avisos locais | Permite apresentar notificações conforme permissões do dispositivo |
| **Git e GitHub** | Versionamento | Organiza e disponibiliza o código-fonte do projeto |

### 7.2. Organização da arquitetura

O Aeris Pulse possui uma estrutura modular, separando funcionalidades e responsabilidades.

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

### 7.3. Responsabilidades das camadas

**app/**

Contém componentes associados à estrutura principal da aplicação, incluindo a organização da navegação.

**core/**

Reúne recursos compartilhados, como regras ambientais, comunicação com serviços externos, armazenamento, providers, temas e widgets reutilizáveis.

**features/**

Contém os módulos funcionais do sistema.

Os módulos podem ser organizados em:

| Diretório | Responsabilidade |
|---|---|
| `data/` | Serviços, modelos e mecanismos de persistência |
| `domain/` | Regras de negócio e processamento |
| `presentation/` | Telas e componentes visuais |
| `providers/` | Estado e integração entre funcionalidades |

**main.dart**

Ponto de entrada da aplicação.

### 7.4. Fluxo de dados

O funcionamento geral da aplicação envolve:

1. O usuário seleciona uma funcionalidade ou cidade.
2. A interface consulta os estados necessários.
3. Os providers coordenam as informações utilizadas.
4. Os serviços verificam dados disponíveis localmente ou realizam consultas externas.
5. As respostas são processadas pelas regras implementadas.
6. Os resultados são disponibilizados para a interface.
7. As informações elegíveis são armazenadas em cache.
8. As preferências são persistidas localmente ou sincronizadas com o Firestore.
9. As telas apresentam os resultados por meio de gráficos, cartões, indicadores e alertas.

### 7.5. Decisões de arquitetura

**Organização modular**

A separação por funcionalidades facilita a manutenção e a evolução independente dos módulos.

**Gerenciamento de estado com Riverpod**

O Riverpod permite compartilhar informações entre diferentes telas e separar parte da lógica da interface.

**Persistência híbrida**

SQLite e Firestore são utilizados para atender necessidades distintas de armazenamento.

**Autenticação opcional**

O acesso como visitante permite utilizar o aplicativo sem criar uma conta.

**Cache ambiental**

O armazenamento de informações previamente consultadas reduz determinadas requisições repetidas e aumenta a utilidade do aplicativo em situações de conectividade limitada.

**Identidade visual própria**

O uso de tema centralizado e componentes reutilizáveis contribui para a consistência da experiência.

### 7.6. Testes automatizados

O projeto possui testes destinados a validar regras e comportamentos da aplicação.

Entre os assuntos cobertos estão:

- Análise de qualidade do ar.
- Classificações ambientais.
- Estatísticas de poluentes.
- Análises de previsões.
- Tratamento de horários e fusos.
- Regras de alertas.
- Validação de alertas seguros.
- Pesquisa de cidades.
- Seleção da cidade monitorada.
- Preferências de entrada.
- Armazenamento em cache.
- Cache de múltiplas cidades.
- Atualização global de dados.
- Componentes de interface.

### 7.7. Validação do aplicativo

O Aeris Pulse foi executado em ambiente Flutter para verificar seu funcionamento.

Foram utilizados os seguintes comandos de validação:

```bash
flutter analyze
flutter test
flutter run
```

Também foram realizadas verificações visuais da interface, incluindo temas claro e escuro, contraste, ampliação de texto e apresentação em diferentes dimensões de tela.

### 7.8. Desafios e aprendizados

O desenvolvimento permitiu aplicar conhecimentos relacionados a:

- Integração com serviços externos.
- Tratamento e apresentação de dados ambientais.
- Gerenciamento de estado com Riverpod.
- Desenvolvimento de interfaces em Flutter.
- Navegação entre múltiplas telas.
- Persistência com SQLite.
- Integração com Firebase.
- Autenticação e privacidade.
- Cache e funcionamento com conectividade limitada.
- Análises temporais e alertas preditivos.
- Testes automatizados.
- Versionamento e documentação técnica.

Esses conhecimentos foram aplicados na construção de uma solução que integra funcionalidades de interface, processamento de informações e serviços externos.

---

## 8. Como executar

### Pré-requisitos

Para executar o Aeris Pulse localmente, são necessários:

- Flutter SDK instalado e configurado.
- Android SDK.
- Android Studio ou Visual Studio Code.
- Emulador Android ou dispositivo físico.
- Projeto Firebase configurado.
- Conexão com a internet para consultas ambientais atualizadas.

O Dart SDK acompanha a instalação do Flutter.

### 8.1. Clonar o repositório

```bash
git clone https://github.com/jalbino0/Aeris_Pulse.git
```

### 8.2. Acessar a pasta

```bash
cd Aeris_Pulse
```

### 8.3. Instalar as dependências

```bash
flutter pub get
```

### 8.4. Configurar o Firebase

O aplicativo utiliza Firebase Authentication e Cloud Firestore.

Para executar o projeto, é necessário configurar uma aplicação Firebase compatível.

Os arquivos específicos da configuração Firebase não são disponibilizados neste repositório.

Entre eles:

```text
lib/firebase_options.dart
android/app/google-services.json
```

A configuração pode ser realizada com o FlutterFire CLI:

```bash
flutterfire configure
```

Também é necessário habilitar os serviços utilizados e configurar as regras de segurança do Firestore.

As regras devem restringir o acesso aos documentos associados a cada usuário autenticado.

### 8.5. Verificar os dispositivos disponíveis

```bash
flutter devices
```

### 8.6. Executar o aplicativo

```bash
flutter run
```

### 8.7. Executar os testes

Para realizar a análise estática:

```bash
flutter analyze
```

Para executar os testes automatizados:

```bash
flutter test
```

Para formatar o código:

```bash
dart format lib
```

### 8.8. Gerar o APK

Para compilar uma versão Release do aplicativo:

```bash
flutter build apk --release
```

Após uma compilação bem-sucedida, o APK é disponibilizado normalmente em:

```text
build/app/outputs/flutter-apk/app-release.apk
```

O APK precisa ser testado e possuir uma configuração de assinatura adequada à distribuição pretendida.

Os arquivos de instalação não são versionados diretamente junto ao código-fonte.

Uma versão instalável poderá ser disponibilizada por meio do recurso **GitHub Releases**.

---

## 9. Vídeo de demonstração

O vídeo apresenta o funcionamento do Aeris Pulse e suas principais funcionalidades.

A demonstração deverá contemplar:

- Apresentação do aplicativo.
- Navegação entre as telas principais.
- Monitoramento da qualidade do ar.
- Consulta de poluentes.
- Visualização de previsões.
- Demonstração de um alerta e de sua justificativa.
- Informações de confiança e limitações.
- Pesquisa e seleção de cidades.
- Autenticação e acesso como visitante.
- Personalização e configurações.

A apresentação será acompanhada de narração ou legendas explicativas.

**Duração máxima:** 3 minutos.

**Link do vídeo no YouTube:** a adicionar após a publicação.

---

## 10. Licença e finalidade acadêmica

O **Aeris Pulse** foi desenvolvido para fins acadêmicos no contexto da **Global Solution 2026.2 da FIAP**, no curso de Ciência da Computação.

O projeto corresponde ao desafio **Territory Predictive Insights**, da disciplina de Cross-Platform Application Development.

O repositório disponibiliza o código-fonte e a documentação do aplicativo para apresentação e avaliação.

Não foi definida uma licença de software específica neste repositório.

O projeto possui finalidade educacional e demonstrativa, e suas informações ambientais não substituem serviços oficiais de monitoramento ou orientações de autoridades competentes.

---

<p align="center">
  <strong>Aeris Pulse — Inteligência no ar. Clareza na vida.</strong>
</p>

<p align="center">
  Desenvolvido por João Pedro de Moura Albino, Kauê Silva Matheus e Giovanna Fernandes Pereira.
</p>
