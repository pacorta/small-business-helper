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
(After git commit #6)
5. Instead of Anonymous Auth, enable Google Auth (In Firebase Console)
    5.1. If also using Android, pay attention to the warning about making sure to register your app's SHA-1 and SHA-256 fingerprints in the Firebase Console. 
         This is required for Google Sign-In and other Firebase services to work on Android. 
         (See the Firebase setup instructions for how to obtain your app's SHA-1/SHA-256.)
6. Put the new GoogleService-info.plist into its place
7. Put the new google-services.json
8. Edit Info.plist in ios to include the 'YOUR-REVERSED-CLIENT-ID' found in 'GoogleService-info.plist'.

I was having some dependency issues, but what helped was to keep everything (google_sign_in, firebase, etc.) up to date, most importantly Flutter, which I upgraded from 3.24.5 to 3.29.3.

Many of the errors that show up are related to anrdoid SDK's, not the app itself. May be easier to test this app on an ios simulator than an android emulator.

If problems arise with android, follow the GRADLE-CONFIGURATION.md, in which I described how I solved some issues.


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

### Git commit #4.5

- Updated README.md File
- Made that, by default, every payment method (except cash) has the sales tax option as “on”. 
- Fixed bug where the weekly sales wouldnt show when filtered.
- Fixed bug where, if the user selected many items, the screen would overflow in the confirm_sale_screen.dart. Now user can select as many items as they want.
- Added filters for sale locations.
- Re-arranged the previous sales screen for more intuitive UI.
- Added more date range filters.

### Git commit #5

- Migrated from SharedPreferences to Firebase Firestore for storing sales data both in android and ios.

### Git commit #6

- Centralized Configuration with ConfigService
	•	All dynamic lists (items, payment methods, locations) are now fetched and updated through a single service connected to Firestore.
- Settings & Configuration Editor UI
	•	New SettingsScreen allows in-app editing of items, locations, and payment methods.
	•	New ConfigEditorScreen provides a simple way to add, delete, and reorder list elements.
- ConfigService uses local caching to reduce reads and improve performance.
- Added App Drawer
- Added libraries that make the UI feel more modern.

Bugs:
- There's a slight twitch when editing a sale.

Observation:
- If there's a large gap between recorded sales, average daily earnings may appear inaccurate.

### Git commit #7

- Added Firebase login functionality.
- The name of the signed-in user is now attached to each sale they make.
- Added user roles (admin/employees) to profiles.
- Only admin users can view and edit the list of employees and their roles.
- Fixed dependency issues for Google Sign-In and Firebase on both Android and iPhone.

Goals for next commit:
- Add an invitation system so that an admin can invite employees (businessId is assigned to employee upon invitation).
- Custom sales data export in CSV format to email, WhatsApp, etc.

### Git commit #8

- Set up employee invitation system with code generation and expiration
- Set up onboarding and role-selection system via AuthWrapper
- Added real-time user state listening using Firestore snapshots
- Implemented RoleSelectionScreen with invitation code verification (New business admin option is pending)
- Added support for pending invitations and cancellation (EmployeesScreen)
- Updated AppUser model to detect onboarding status (needsOnboarding)
- Added CSV export functionality in PreviousSalesScreen
- Applied UI/UX refinements to login and employee management screens
- Refactored main.dart to use AuthWrapper and route onboarding correctly

#### The following section contains a little bit of brainstorm and rambling on:
Goals to achieve the MVP:
- Add the possibility to become the admin of a new business.
  - Add a new dashboard in case someone is the admin of multiple businesses.
  - Give them the option to switch between businesses easily.
  - Maybe give the option of combining the earnings of two businesses?
- Add limits of invitations to new employees to avoid abuse of tokens.
- Improve the HTML of the email sent in invitation. Also add more info/instructions.

Future improvements:
- Add different ways to calculate the total of the entire sale. The point of the app is to calculate between sales, so it has to be fast and efficient.
- Add new sales info filters. By date-ranges, employees (only viewed by admin), etc.
- Notifications to the owner when the new employee accepts the invitation.

Monetization ideas:
- Owning multiple businesses could be a paid feature.
- Multiple employees could also be a paid feature.

#### Notes:
- In the future, I will need to update the version of Node.js and firebase-functions.
- The way I handle the idling of new registered users from the login screen going to the role selection screen is not the best, but it works. It creates a new document in firebase temporarily; if the user decides not to do anything, the document will be deleted. The ideal situation is to never create this document, but I will leave it for later.
- Had to manually add the roles of the App Engine default service account (Cloud Build Service Account, Cloud Functions Developer, Editor). Don't know if this is normal.