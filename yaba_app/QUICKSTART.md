# YABA Quick Start Guide

## 🚀 Running the App

### For macOS
```bash
cd /Users/momo/Projects/yaba-full/yaba_app
flutter run -d macos
```

### For Android
1. Connect an Android device or start an emulator
2. Run:
```bash
cd /Users/momo/Projects/yaba-full/yaba_app
flutter run -d android
```

### For Windows
```bash
cd /Users/momo/Projects/yaba-full/yaba_app
flutter run -d windows
```

## 📱 Using the App

### Adding Your First Transaction
1. Click the **"Add Transaction"** floating button
2. Choose transaction type (Income or Expense)
3. Enter details:
   - Title (e.g., "Groceries", "Salary")
   - Amount
   - Category
   - Date
   - Optional notes
4. Toggle **Recurring** if this transaction repeats monthly
5. Toggle **Frozen** if this should always appear (e.g., rent)
6. Tap "Add Transaction"

### Dashboard Overview
The main dashboard shows:
- **Current Month** with navigation arrows
- **Summary Cards**: Total Income, Total Expenses, Balance
- **Expense Breakdown**: Visual chart by category
- **Transaction List**: All transactions for the month

### Managing Transactions
- **Edit**: Tap any transaction to edit
- **Delete**: Long-press → Select Delete
- **Mark Recurring**: Long-press → Toggle recurring
- **Freeze**: Long-press → Toggle frozen

### Viewing History
1. Tap the **History** icon in the app bar
2. Browse all previous months
3. Tap a month to view details
4. Export frozen months to CSV

### Comparing Months
1. In History screen, tap the **checkbox** icon
2. Select 2+ months
3. Tap **Compare** icon
4. View side-by-side comparison
5. Export comparison to CSV

## 🧪 Running Tests

```bash
# All tests
flutter test

# Specific tests
flutter test test/models_test.dart
```

## 🔍 Key Features

### Automatic Month Freezing
- Previous months automatically freeze when a new month starts
- Frozen months are read-only
- Can be viewed and exported anytime

### Recurring Transactions
- Marked transactions copy to next month
- Great for regular expenses like subscriptions

### Frozen Transactions
- Always appear in future months
- Perfect for fixed expenses (rent, utilities)

### Data Export
- Export any frozen month to CSV
- Compare and export multiple months
- All data saved locally

## 📊 Understanding Your Budget

### Summary Cards
- **Income (Green)**: All money coming in
- **Expenses (Red)**: All money going out
- **Balance (Blue/Orange)**: 
  - Blue = positive (money left over)
  - Orange = negative (overspending)

### Category Breakdown
Shows what percentage of your expenses goes to each category:
- Groceries
- Transportation
- Utilities
- Entertainment
- Dining Out
- Healthcare
- Other

## 💡 Tips

1. **Set up recurring transactions first** - Add your regular income and expenses
2. **Freeze fixed costs** - Rent, subscriptions, etc.
3. **Check your balance daily** - See if you're on track
4. **Export monthly** - Keep records of your spending patterns
5. **Compare months** - Identify trends and areas to improve

## 🐛 Troubleshooting

### App won't start
- Make sure you've run `flutter pub get`
- Check Flutter doctor: `flutter doctor`

### Data not saving
- Check permissions (especially on Android)
- Ensure app has storage access

### Export not working
- Grant file system permissions
- Try a different save location

## 📁 Data Location

Data is stored locally using Hive:
- **macOS**: `~/Library/Application Support/com.yaba.yabaApp`
- **Windows**: `%APPDATA%\com.yaba.yaba_app`
- **Android**: App's private storage

## 🔒 Privacy

- All data stays on your device
- No internet connection required
- No data sent anywhere
- You own your data completely

## 🎯 Next Steps

1. Add your current month's transactions
2. Review the expense breakdown
3. Set up recurring bills
4. Track your progress!

---

**Built with Flutter** 🎯
Cross-platform budgeting made simple.
