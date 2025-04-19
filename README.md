This is an app for small businesses. It's a point of sale app that allows the user to register sales and see analytics.

## Features

- Register sales
- See analytics
- Filter sales by payment method, location and date range
- Support for multiple sale locations during each session/transaction

##Architecture
The app is built with:
-Flutter for the frontend
-Firebase for the backend:
  -Firestore Database for storing sales data
  -Firebase Auth for authentication

### Firebase Configuration Steps:

1. Create a new project in [Firebase Console](https://console.firebase.google.com/)
2. Add your apps:
   - For Android: Download `google-services.json` and place it in `android/app/`
   - For iOS: Download `GoogleService-Info.plist` and place it in `ios/Runner/`
3. Enable Authentication (Anonymous auth is used)
4. Enable Firestore Database
   - Create a database in test mode
   - Set up your security rules


## Register Sales

![location_selection](https://github.com/user-attachments/assets/3313005d-6eac-46f7-b34f-39742659b97a)
Choose current sales location.

![item_selection](https://github.com/user-attachments/assets/d62db180-b052-411e-b006-d7ec7497a61d)
Select the items sold in this transaction.

![payment_method_selection](https://github.com/user-attachments/assets/7a019869-2cfb-45cf-8e49-ef0f40f33ef0)
Choose payment method
  (sales tax on automatically for all payment methods except cash)

![confirm_sale](https://github.com/user-attachments/assets/36dec941-f649-4df2-9b34-fd518d9ddb96)
Confirm sale details

## Review Past Sales:

![previous_sales](https://github.com/user-attachments/assets/ed92f96f-c774-4219-b675-df03e21e44a3)
Look back at all previous sales

![filters](https://github.com/user-attachments/assets/02d85fc1-d879-4fff-bbbe-542cc82c3b6e)
Filter out for specific sales you want to see, based on date, payment method, or location.

Git commit #4.5

- Updated README.md File
- Made that, by default, every payment method (except cash) has the sales tax option as “on”. 
- Fixed bug where the weekly sales wouldnt show when filtered.
- Fixed bug where, if the user selected many items, the screen would overflow in the confirm_sale_screen.dart. Now user can select as many items as they want.
- Added filters for sale locations.
- Re-arranged the previous sales screen for more intuitive UI.
- Added more date range filters.

Git commit #5

- Migrated from SharedPreferences to Firebase Firestore for storing sales data both in android and ios.