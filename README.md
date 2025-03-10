# AirTrack - Air Quality Monitoring Application 🌍

## 1. Introduction
AirTrack is a Flutter-based application that allows users to monitor real-time **PM2.5, CO, NO₂, O₃, SO₂, and other air quality indices** by fetching data from the **OpenWeather API**. 

The app also provides historical data visualization and customizable alert thresholds for air quality monitoring. It supports user authentication via **Google Sign-In** and **Guest Mode**, with data caching for offline access.

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

    subgraph External API
        OpenWeather["OpenWeather API"]
    end

    Dashboard -->|Fetches data| Firestore
    Dashboard -->|Fetches data| OpenWeather
    Chart -->|Fetches historical data| Firestore
    Settings -->|Updates threshold| Firestore
    Firestore -->|Triggers notifications| CloudFunctions
    CloudFunctions -->|Sends alerts| FCM
    Auth -->|Handles user authentication| User
```

### Bloc Flow
```mermaid
stateDiagram-v2
    [*] --> AirQualityBloc : Initialize
    AirQualityBloc --> FetchAirQuality : User Requests Data
    FetchAirQuality --> OpenWeather : Fetch Data from API
    FetchAirQuality --> Firestore : Fetch Cached Data
    OpenWeather --> AirQualityBloc : Return Live Data
    Firestore --> AirQualityBloc : Return Cached Data (if available)
    AirQualityBloc --> DashboardScreen : Update UI

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
- **Firebase** (Backend)
- **http** (API Requests)

## 4. Installation & Running the Application
```sh
# Clone repository
git clone https://github.com/taitran501/air_track.git
cd AirTrack

# Load environment variables
cp .env.example .env

# Install dependencies
flutter pub get

# Run the application
flutter run
```

