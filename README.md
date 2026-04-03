# DharPay: Premium Off-Grid Fintech Solution

DharPay is a high-fidelity, secure mobile fintech application built with Flutter, designed to redefine the digital payment experience with a focus on **Off-Grid (Offline) Connectivity**. Combining a premium "Electric Violet" aesthetic with robust security features, DharPay allows users to transact even in environments with limited or no internet access.

## ✨ Key Features

- 📶 **Off-Grid Payments**: Seamlessly send and receive funds using local Hotspot (P2P/P2M) connectivity. No internet? No problem.
- 🛡️ **Biometric Security**: Advanced Fingerprint and Pin authentication to keep your assets safe.
- 💎 **Premium UI/UX**: A modern, dark-themed interface featuring glassmorphism, glowing accents, and intuitive navigation.
- 🔍 **QR Connect**: Instantly pair with other devices or merchants for rapid offline transactions.
- 🎙️ **Voice Interactions**: Integrated Speech-to-Text and Text-to-Speech for enhanced accessibility and hands-free control.
- 📊 **Wallet Management**: Real-time balance tracking, multi-method top-ups, and a comprehensive transaction history.

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend & REST API**: Flask (Python) with TinyDB
- **Local Storage**: Flutter Secure Storage, Shared Preferences
- **Hardware Integration**: Biometrics (Local Auth), QR Scanning (Mobile Scanner), WiFi IoT
- **Development Tools**: VS Code, Android Studio, Flutter SDK

## 📂 Backend Architecture (The `pay` folder)
The project includes a **REST API backend** built with Flask, located in the `pay/pay` directory. This backend handles:
- **Transaction Processing**: Endpoints like `/transact`, `/untransact`, and `/pay`.
- **History Management**: JSON-based storage using **TinyDB** (`history_db.json`, `transact_db.json`).
- **Device Pairing**: Handled via simple code-based authentication (`pair.code`).
- **Mock Interfaces**: Local web views for monitoring transactions (`/history`, `/transactions`).

## 🎨 Design System

DharPay follows a strict, premium design language:

- **Primary Colors**: Electric Violet (#8B5CF6), Amber Gold (#F59E0B), Cyan (#06B6D4)
- **Base**: Pure Black (#0D0D0D) with Zinc-based surface variations.
- **Styling**: Glass Cards, Neon Glows, and Bouncing Scroll Mechanics.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.9.2 or higher)
- Android Studio / Xcode
- A physical device (recommended for testing WiFi/Hotspot features)

### Installation
1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/dharpay.git
    cd dharpay
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the application**:
    ```bash
    flutter run
    ```

## 📂 Project Structure

```text
lib/
├── main.dart             # App Entry & Initial Routing
├── theme.dart            # Centralized Brand & Design Tokens
├── widgets.dart          # Reusable Premium UI Components
├── portfolio_page.dart   # Main Dashboard & Wallet View
├── payment_page.dart     # Detailed Transaction Logic
├── login_page.dart       # Secure User Onboarding
└── ...                   # Specialized Pages (Scan, Profile, Receive, etc.)
```

---

*DharPay — Empowering Financial Freedom, Everywhere.*
