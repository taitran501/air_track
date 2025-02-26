# AirTrack - Air Quality Monitoring Application 🌍

## 1. Introduction
AirTrack is a Flutter-based application that enables users to monitor real-time **PM2.5, CO2, temperature, and humidity** data from IoT sensors.

## 2. Architecture
The application follows the **Clean Architecture + Bloc Pattern**.

### System Architecture
```mermaid
graph TD;

    User["User (Flutter App)"] -->|Interacts| Dashboard["Dashboard Screen"]
    User -->|Interacts| Chart["Chart Screen"]
    User -->|Interacts| Settings["Settings Screen"]

    subgraph Firebase Services
        Firestore["Firestore Database"]
        CloudFunctions["Firebase Cloud Functions"]
        FCM["Firebase Cloud Messaging"]
        Auth["Firebase Authentication"]
    end

    Dashboard -->|Fetches data| Firestore
    Chart -->|Fetches historical data| Firestore
    Settings -->|Updates threshold| Firestore
    Firestore -->|Triggers notifications| CloudFunctions
    CloudFunctions -->|Sends alerts| FCM
    Auth -->|Handles user authentication| User
```

### Bloc Flow
```mermaid
stateDiagram-v2
    [*] --> DashboardBloc : Initialize
    DashboardBloc --> GetAirQualityEvent : User Requests Data
    GetAirQualityEvent --> Firestore : Fetch Data Realtime
    Firestore --> DashboardBloc : Stream Data
    DashboardBloc --> DashboardScreen : Update UI

    SettingsBloc --> SetAlertThresholdEvent : User Updates Threshold
    SetAlertThresholdEvent --> Firestore : Store new settings
    Firestore --> CloudFunctions : Trigger Alert Check
    CloudFunctions --> FCM : Send Notification
    SettingsBloc --> SettingsScreen : Update UI
```

### Use Case
![Use Case Diagram](docs/use_case.png)

## 3. Technologies Used
- **Flutter** (UI)
- **Bloc Pattern** (State Management)
- **Firebase/MQTT/PostgreSQL** (Backend)
- **Dio** (API Requests)

## 4. Installation & Running the Application
```sh
# Install dependencies
flutter pub get

# Run the application
flutter run
```

