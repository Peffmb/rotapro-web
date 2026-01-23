# 🏍️ RotaGo - Gestão de Entregas em Tempo Real

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
</p>

---

## 📌 Sobre o Projeto

O **RotaGo** é uma solução completa de monitoramento logístico desenvolvida para ajudar lanchonetes. A ferramenta permite a gestão centralizada de entregadores, monitoramento em tempo real via mapa interativo e vinculação de dispositivos através de tokens únicos, ele será implementado em um app em flutter também que já está criado por mim e em uso, focado no motoboy do dia a dia que faz entregas privadas.

O projeto foi construído com foco em **escalabilidade** e **performance**, utilizando o que há de mais moderno no ecossistema Flutter Web e Firebase.

## 🚀 Funcionalidades Principais

- 🔐 **Autenticação Segura**: Sistema de login, registro e recuperação de senha via Firebase Auth.
- 📍 **Monitoramento em Tempo Real**: Mapa interativo integrado com OpenStreetMap para rastreio de frotas.
- 👥 **Gestão de Entregadores**: CRUD completo (Criação, Consulta e Exclusão) de colaboradores.
- 🔑 **Sistema de Tokens**: Geração automática de chaves de vínculo para integração com o aplicativo mobile.
- 📊 **Telemetria Simulada**: Visualização dinâmica de velocidade, bateria e status dos entregadores.
- 🎨 **UI Customizada**: Interface adaptada para a identidade visual da marca (Vermelho/Preto).

---

## 🛠️ Tecnologias Utilizadas

- **Framework:** [Flutter](https://flutter.dev) (Web)
- **Backend:** [Firebase](https://firebase.google.com) (Authentication & Cloud Firestore)
- **Mapas:** [Flutter Map](https://pub.dev/packages/flutter_map) + [OpenStreetMap](https://www.openstreetmap.org/)
- **Gerenciamento de Estado:** StatefulWidget / Streams
- **Estilização:** Material Design 3 (Personalizado)


## ⚙️ Como executar o projeto

1. **Pré-requisitos:**
   - Flutter SDK instalado.
   - Um projeto configurado no Firebase.

2. **Clonar o repositório:**
   ```bash
   git clone [https://github.com/seu-usuario/rotago_web.git](https://github.com/seu-usuario/rotago_web.git)
