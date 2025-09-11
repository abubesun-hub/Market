# Market Flutter App (Windows)

## Getting Started

1. Ensure Flutter SDK is installed and Windows desktop is enabled
```powershell
flutter doctor
flutter config --enable-windows-desktop
```

2. Create/Use this project as a Flutter app (if not yet initialized)
```powershell
# If you haven't created a Flutter app here, run:
flutter create .
```

3. Add dependencies
```powershell
flutter pub add flutter_riverpod go_router intl
```

4. Run the app
```powershell
flutter run -d windows
```

## Next steps (already prepared in server)
- API endpoints for settings, branches, warehouses are ready.
- We'll build screens:
  - Home (Dashboard placeholder)
  - Settings: language (AR/EN), currency display, change IQD step, set exchange rate (manual)
  - Branches list/create
  - Warehouses list/create (filtered by branch)

## i18n
- We'll use `intl` with AR/EN and enable RTL in MaterialApp when AR is active.