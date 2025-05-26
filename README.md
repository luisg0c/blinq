# Blinq 💸

**Banco digital minimalista construído com Flutter + Firebase**

Um app de transferências PIX simples, rápido e seguro.

## ✨ Features

- **Autenticação** - Login/registro com Firebase Auth
- **Transferências PIX** - Entre usuários Blinq via email ou QR Code
- **Depósitos** - Adicione dinheiro na conta (simulado)
- **Histórico** - Acompanhe todas as transações
- **PIN de segurança** - Proteção para operações sensíveis
- **Saldo protegido** - Visualização mediante PIN
- **Temas** - Modo claro/escuro com design neomorfo
- **Cotações** - Visualize câmbio de moedas

## 🚀 Setup Rápido

### Pré-requisitos
- Flutter 3.19+
- Firebase project configurado
- Android Studio / VS Code

### Instalação

```bash
# Clone
git clone https://github.com/seu-usuario/blinq.git
cd blinq

# Dependências
flutter pub get

# Configure o Firebase
# Adicione seus arquivos google-services.json e GoogleService-Info.plist

# Rodde
flutter run
```

### Firebase Setup

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com)
2. Habilite:
   - **Authentication** (Email/Password)
   - **Firestore Database**
   - **Cloud Messaging** (opcional)
3. Configure as plataformas Android/iOS
4. Baixe os arquivos de configuração

## 🏗️ Arquitetura

```
lib/
├── core/           # Utilitários, temas, exceções
├── data/           # Repositories, models, datasources
├── domain/         # Entities, usecases, contracts
├── presentation/   # Pages, controllers, components
└── routes/         # Navegação e bindings
```

**Clean Architecture + GetX** para separação de responsabilidades e gerenciamento de estado.

## 🔐 Segurança

- **PIN local** - Armazenado criptografado com FlutterSecureStorage
- **Validações** - Entrada de dados e limites de transação
- **Firebase Rules** - Acesso restrito por usuário
- **Hash de senhas** - SHA-256 com salt

## 🎨 Design

**Neomorfismo** - Interface moderna com sombras suaves e elementos "pressed"
- Cores principais: Verde Blinq (`#6EE1C6`) e Preto (`#0D1517`)
- Componentes customizados para consistência visual
- Animações fluidas e feedback tátil

## 📱 Fluxos Principais

1. **Onboarding** → **Login/Registro** → **Setup PIN** → **Home**
2. **Transferir** → **Inserir dados** → **PIN** → **Confirmação**
3. **Depositar** → **Valor** → **PIN** → **Sucesso**
4. **QR Code** → **Gerar/Escanear** → **Auto-preenchimento**

## 🛠️ Stack

- **Frontend**: Flutter 3.19 + Dart
- **Estado**: GetX (routes, controllers, dependency injection)
- **Backend**: Firebase (Auth, Firestore, Messaging)
- **Storage**: FlutterSecureStorage (PIN), SharedPreferences (preferências)
- **UI**: Design system próprio + animações custom

## 📊 Estrutura de Dados (Firestore)

```javascript
// Collection: accounts
{
  userId: "uid",
  balance: 1000.0,
  user: {
    id: "uid",
    name: "João Silva", 
    email: "joao@email.com"
  },
  createdAt: timestamp
}

// Collection: transactions  
{
  userId: "uid",
  type: "transfer|deposit|receive",
  amount: 100.0,
  date: timestamp,
  description: "PIX",
  counterparty: "Maria",
  status: "completed"
}
```

## 🧪 Testing

```bash
# Testes unitários
flutter test

# Testes de widget  
flutter test test/widget_test.dart

# Testes de integração
flutter test integration_test/
```

## 📦 Build

```bash
# Android
flutter build apk --release

# iOS  
flutter build ios --release
```

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-feature`)
3. Commit (`git commit -m 'Add nova feature'`) 
4. Push (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📄 Licença

MIT License - veja [LICENSE](LICENSE) para detalhes.

---

**Blinq** - Simplicidade financeira na palma da sua mão 🏦✨
