# TollGate Wi-Fi Access App

A Flutter mobile application that allows users to pay for Wi-Fi access using Bitcoin via Cashu tokens.

## 📱 Features

- **Wi-Fi Network Scanning**: Discover available Wi-Fi networks
- **Secure Payments**: Pay for Wi-Fi access using Cashu tokens (Bitcoin Lightning)
- **Wallet Management**: Built-in Cashu wallet for managing tokens
- **Connection Management**: Monitor your Wi-Fi connection status
- **Multi-platform Support**: Works on iOS, Android, macOS, Linux, and Windows

## 🛠️ Tech Stack

- **Framework**: Flutter 3.3+
- **State Management**: Riverpod
- **Navigation**: Go Router
- **Networking**: Dio, HTTP
- **Internationalization**: Flutter Localizations
- **Persistence**: Flutter Secure Storage, Shared Preferences

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.3 or higher
- Dart SDK 3.3 or higher

### Installation

1. Clone the repository:

   ```
   git clone https://github.com/yourusername/tollgate_app.git
   ```

2. Navigate to the project directory:

   ```
   cd tollgate_app
   ```

3. Get dependencies:

   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── config/             # App configuration
├── core/               # Core providers and services
├── data/               # Data services
├── domain/             # Business logic and models
├── ui/                 # UI components
│   ├── connection_details/
│   ├── core/           # Shared UI components
│   ├── home/
│   ├── network_scan/
│   ├── payment/
│   ├── settings/
│   └── wallet/
└── utils/              # Utility functions
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Authors

- Your Name
