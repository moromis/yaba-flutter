# YABA - Yet Another Budget App

A cross-platform budgeting application built with Flutter for Windows, macOS, and Android.

## Features

- ✅ **Add Transactions**: Easily add income and expense transactions
- 📊 **Category Breakdown**: Visual breakdown of spending by category
- 🔄 **Recurring Transactions**: Mark transactions to auto-copy to future months
- 📌 **Frozen Transactions**: Pin transactions to always appear in new months
- 🔒 **Month Freezing**: Previous months automatically freeze for historical records
- 📈 **Month Comparison**: Compare multiple months side-by-side
- 💾 **Data Export**: Export month data and comparisons to CSV
- 🎨 **Modern UI**: Clean Material Design 3 interface with dark mode support
- 💯 **Fully Tested**: Comprehensive unit, widget, and integration tests

## Architecture

### Models
- `Transaction`: Individual income/expense entries with categories, dates, and flags
- `MonthData`: Container for monthly transactions with calculations
- `Category`: Predefined categories with icons and colors

### Services
- `StorageService`: Hive-based local data persistence
- `ExportService`: CSV export functionality for reports

### Providers
- `BudgetProvider`: State management using Provider pattern
  - Manages current month data
  - Handles transaction CRUD operations
  - Auto-freezes previous months
  - Auto-copies recurring/frozen transactions

### Screens
- `DashboardScreen`: Main view with summary cards, category breakdown, and transaction list
- `AddTransactionScreen`: Form to add/edit transactions
- `MonthHistoryScreen`: View all past months with export options
- `MonthComparisonScreen`: Compare selected months with averages

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Platform-specific requirements:
  - **Windows**: Windows 10 or higher
  - **macOS**: macOS 10.15 or higher
  - **Android**: API level 21 (Android 5.0) or higher

### Installation

1. Navigate to the project directory:
```bash
cd /Users/momo/Projects/yaba-full/yaba_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For macOS
flutter run -d macos

# For Windows
flutter run -d windows

# For Android (with device/emulator connected)
flutter run -d android
```

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/models_test.dart
```

## Project Structure

```
lib/
├── models/              # Data models
│   ├── transaction_model.dart
│   ├── month_data.dart
│   └── category_model.dart
├── services/            # Business logic services
│   ├── storage_service.dart
│   └── export_service.dart
├── providers/           # State management
│   └── budget_provider.dart
├── screens/             # UI screens
│   ├── dashboard_screen.dart
│   ├── add_transaction_screen.dart
│   └── month_history_screen.dart
├── widgets/             # Reusable widgets
│   ├── transaction_list_item.dart
│   └── category_breakdown_chart.dart
└── main.dart            # App entry point

test/
├── models_test.dart
├── storage_service_test.dart
├── budget_provider_test.dart
└── widget_test.dart
```

## Key Features Explained

### Recurring Transactions
Transactions marked as "Recurring" are automatically copied to the next month when it's first accessed.

### Frozen Transactions
Transactions marked as "Frozen" are permanently copied to all future months, ideal for fixed expenses like rent.

### Month Freezing
When a new month begins, all previous months are automatically frozen to preserve historical data. Frozen months are read-only and can be exported.

### Category Breakdown
The dashboard displays a visual breakdown showing:
- Percentage of total expenses per category
- Amount spent per category
- Progress bars for easy visualization

### Month Comparison
Select multiple months to compare:
- Side-by-side transaction counts
- Income, expenses, and balance for each month
- Average calculations across selected months
- Export comparison data to CSV

## Data Persistence

The app uses Hive for local storage:
- All data is stored locally on your device
- No internet connection required
- Fast read/write operations
- Automatic data serialization

## Building for Release

### macOS
```bash
flutter build macos --release
```

### Windows
```bash
flutter build windows --release
```

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

