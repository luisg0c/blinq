# Blinq: Aplicativo Bancário Digital

Blinq é um aplicativo bancário moderno desenvolvido com Flutter, oferecendo uma experiência financeira simplificada, segura e intuitiva.

## 📱 Funcionalidades Principais

- **Autenticação Segura**: Login/registro via Firebase Authentication
- **Gestão de Conta**: Visualização de saldo e informações em tempo real
- **Transferências PIX**: Transferências rápidas entre usuários
- **Depósitos**: Adicione fundos à sua conta
- **Histórico de Transações**: Rastreie todas suas operações financeiras
- **Segurança por Design**: Senha de transação dedicada para operações sensíveis

## 🛠️ Tecnologias Utilizadas

- **Flutter/Dart**: Framework multiplataforma para desenvolvimento
- **Firebase Auth**: Autenticação via Email/Senha
- **Cloud Firestore**: Banco de dados para contas e transações
- **GetX**: Gerenciamento de estado, navegação e injeção de dependências
- **Clean Architecture**: Estrutura de projeto modular e escalável

## 📐 Arquitetura

O projeto segue uma adaptação da Clean Architecture com separação clara em camadas:

```
lib/
├── core/                 # Utilitários e configurações
├── data/                 # Camada de dados (repositórios e serviços)
├── domain/               # Regras de negócio e entidades
├── presentation/         # Interface do usuário (controllers, pages, widgets)
└── main.dart             # Ponto de entrada do aplicativo
```

## 📷 Screenshots

<table>
  <tr>
    <td><img src="docs/screenshots/login.png" width="200"/></td>
    <td><img src="docs/screenshots/home.png" width="200"/></td>
    <td><img src="docs/screenshots/transfer.png" width="200"/></td>
    <td><img src="docs/screenshots/history.png" width="200"/></td>
  </tr>
</table>

## 🚀 Instalação e Execução

### Pré-requisitos
- Flutter SDK 3.0+
- Dart 2.17+
- Firebase CLI
- Conta no Firebase

### Configuração

1. Clone o repositório:
   ```bash
   git clone https://github.com/seu-usuario/blinq.git
   cd blinq
   ```

2. Instale as dependências:
   ```bash
   flutter pub get
   ```

3. Configure o Firebase:
   ```bash
   flutterfire configure
   ```

4. Execute o aplicativo:
   ```bash
   flutter run
   ```

## 📊 Estrutura do Firestore

- **accounts/<userId>**
  - `balance`: double
  - `email`: string
  - `transactionPassword`: string (hash)
  - `createdAt`: timestamp
  - `updatedAt`: timestamp

- **transactions/**
  - `senderId`: string
  - `receiverId`: string
  - `amount`: double
  - `timestamp`: timestamp
  - `participants`: array[string]
  - `type`: 'deposit' | 'transfer'
  - `status`: 'pending' | 'completed' | 'failed'

## 🔐 Segurança

- **Senha de Transação**: Necessária para todas operações financeiras
- **Validação de Saldo**: Verificação de saldo antes de transferências
- **Transações Atômicas**: Garantia de consistência em operações financeiras
- **Autenticação Robusta**: Integração completa com Firebase Auth

## 🔮 Próximos Passos

- [ ] Autenticação biométrica para validar transações
- [ ] Notificações push para alertas de transações
- [ ] Funcionalidades de planejamento financeiro
- [ ] Temas personalizáveis
- [ ] Suporte para múltiplas moedas

## 📜 Licença

Este projeto está licenciado sob a [Licença MIT](LICENSE).

## 👥 Contribuição

Contribuições são bem-vindas! Por favor, sinta-se à vontade para submeter um Pull Request.

1. Faça um fork do projeto
2. Crie sua branch de feature (`git checkout -b feature/amazing-feature`)
3. Faça commit das suas mudanças (`git commit -m 'Add some amazing feature'`)
4. Envie para a branch (`git push origin feature/amazing-feature`)
5. Abra um Pull Request

---

<p align="center">
  Desenvolvido utilizando Flutter e Firebase
</p>