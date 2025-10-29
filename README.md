# Conexão Cidadania

## Descrição do Projeto

Conexão Cidadania é uma aplicação web desenvolvida com o framework Flutter. O propósito do projeto é servir como uma plataforma digital para a protocolização de ações judiciais focadas em direitos sociais. A aplicação permite que os usuários iniciem novas ações, anexoem a documentação necessária e acompanhem o andamento processual de forma simplificada.

## Funcionalidades Principais

* **Autenticação de Usuários:** Sistema completo de cadastro, login e recuperação de senha.
* **Fluxo de Cadastro em Etapas:** Coleta organizada de informações do usuário (dados pessoais, endereço e credenciais de acesso) em um fluxo guiado.
* **Criação de Ações:** Permite ao usuário iniciar diferentes tipos de ações judiciais (ex: Remédio de Alto Custo, Vaga em Creche).
* **Gerenciamento de Documentos:** Funcionalidade de upload de arquivos (documentos pessoais, comprovantes) associados a cada ação judicial.
* **Visualização e Gerenciamento:** Tela principal para listar, pesquisar e acessar os detalhes de todas as ações cadastradas pelo usuário.
* **Acompanhamento Processual:** Exibição do status atual da ação e um histórico de movimentações processuais.

## Tecnologias e Serviços

### Tecnologias (Frontend)

* **Flutter:** Framework principal utilizado para a construção da interface de usuário (UI) da aplicação web.
* **Dart:** Linguagem de programação base do Flutter.

### Serviços (Backend e APIs)

* **Firebase (BaaS):** Utilizado como o principal provedor de backend.
    * **Firebase Authentication:** Gerencia todo o ciclo de vida da autenticação de usuários (email/senha).
    * **Cloud Firestore:** Banco de dados NoSQL utilizado para armazenar os dados dos usuários e os detalhes das ações judiciais.
    * **Firebase Storage:** Utilizado para o armazenamento seguro dos documentos e arquivos enviados pelos usuários.
* **Datajud (API Pública):** A arquitetura permite a integração com a API pública do Datajud (Base Nacional de Metadados Processuais do Poder Judiciário Brasileiro) para a consulta e exibição do andamento processual em tempo real.

## Padrões de Desenvolvimento e Arquitetura

O projeto está estruturado visando a separação de responsabilidades, organizando o código da seguinte forma:

* **Separação de Camadas:** O código é dividido em:
    * **View (Apresentação):** Contém os widgets do Flutter que compõem as telas (ex: `styled_home_view.dart`, `styled_login_view.dart`).
    * **Controller (Lógica de Estado e Negócio):** Classes que gerenciam o estado da aplicação e orquestram a lógica de negócio, fazendo a ponte entre a UI e os serviços de dados (ex: `lawsuit_controller.dart`, `user_controller.dart`).
    * **Model:** Classes puras em Dart que definem a estrutura de dados (ex: `lawsuit_model.dart`, `user_model.dart`).
* **Gerenciamento de Estado:** Os controllers utilizam `ChangeNotifier` para gerenciar o estado e notificar a UI sobre mudanças.
* **Injeção de Dependência:** O padrão Service Locator é utilizado através do pacote `get_it` para disponibilizar instâncias dos controllers (como singletons) para a camada de visualização (View).