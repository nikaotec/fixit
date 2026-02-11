# FixIt - Sistema de Ordem de Serviço

## 🚀 Visão Geral
Sistema de gestão de ordens de serviço (OS) para manutenção de equipamentos, construído com **Flutter** e **Firebase**.

O sistema permite:
- Gestão de Clientes e Equipamentos
- Criação e acompanhamento de Ordens de Serviço
- Execução de manutenção com checklist e upload de evidências
- Geração de relatórios em PDF
- Gestão de Técnicos e avaliações

## 🛠️ Arquitetura
O projeto migrou de um backend Java monolítico para uma arquitetura **Serverless** usando **Firebase**:

- **Authentication**: Gestão de usuários (Login Google/Email)
- **Firestore**: Banco de dados NoSQL em tempo real
- **Storage**: Armazenamento de fotos e evidências
- **Flutter**: Frontend mobile cross-platform

## 📱 Executando o Projeto

### Pré-requisitos
- Flutter SDK instalado
- Conta configurada no Firebase

### Passo a passo

1. **Clone o repositório**

2. **Configure o Firebase**
   - Certifique-se de ter o arquivo `google-services.json` (Android) e `GoogleService-Info.plist` (iOS) nas respectivas pastas:
     - `frontend/android/app/google-services.json`
     - `frontend/ios/Runner/GoogleService-Info.plist`

3. **Instale as dependências**

```bash
cd frontend
flutter pub get
```

4. **Execute o App**

```bash
flutter run
```

## 🔒 Regras de Segurança (Firestore)
As regras de segurança garantem que cada empresa acesse apenas seus dados. O arquivo `firestore.rules` contém a definição atual.

## 📦 Estrutura do Projeto (Frontend)
- `lib/models`: Modelos de dados (Order, Client, Technician, etc.)
- `lib/services`: Serviços de integração com Firestore (`FirestoreOrderService`, `FirestoreClientService`, etc.)
- `lib/screens`: Telas da aplicação
- `lib/providers`: Gestão de estado (UserProvider)

## 📝 Próximos Passos (Backlog)
- Implementar Cloud Functions para notificações push automáticas
- Melhorar modo offline
