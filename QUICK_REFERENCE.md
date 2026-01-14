# RePlay - Quick Reference Guide

**Last Updated:** January 14, 2026

---

## 📋 QUICK NAVIGATION

### Screen List
| # | Screen Name | File Path | Purpose |
|---|---|---|---|
| 1 | Splash | `splash_screen.dart` | Welcome screen |
| 2 | Login | `auth/login_screen.dart` | User login |
| 3 | Register | `auth/register_screen.dart` | New account creation |
| 4 | Home | `home/home_screen.dart` | Browse items (main feed) |
| 5 | Product Details | `home/product_page_screen.dart` | View single item |
| 6 | Contact Seller | `contact_seller_screen.dart` | Phone/Email/WhatsApp actions |
| 7 | Add Listing | `item/add_listing_screen.dart` | Post new item |
| 8 | Edit Listing | `item/edit_item_screen.dart` | Modify existing item |
| 9 | Profile | `profile_screen.dart` | User profile + My listings/favorites |
| 10 | Edit Profile | `edit_profile_screen.dart` | Update user info |

---

## 🎛️ CUBIT REFERENCE

| Cubit | File | Purpose | States |
|---|---|---|---|
| **AuthCubit** | `logic/auth_cubit/` | Authentication | AuthInitial, AuthLoading, AuthAuthenticated, AuthUnauthenticated, AuthError |
| **ItemCubit** | `logic/item_cubit/` | Items/Listings | ItemInitial, ItemLoading, ItemLoaded, ItemOperationInProgress, ItemOperationSuccess, ItemError |
| **FavoriteCubit** | `logic/favorite_cubit/` | Favorites | FavoriteInitial, FavoriteLoading, FavoriteLoaded, FavoriteError |
| **ProfileCubit** | `logic/profile_cubit/` | User Profile | ProfileInitial, ProfileLoading, ProfileLoaded, ProfileError |
| **LanguageCubit** | `logic/language_cubit/` | Localization | LanguageInitial, LanguageLoaded |

---

## 📊 DATABASE TABLES

### Users Table
```sql
CREATE TABLE users (
  userid INT PRIMARY KEY,
  username VARCHAR UNIQUE NOT NULL,
  email VARCHAR UNIQUE NOT NULL,
  phonenum INT,
  password VARCHAR NOT NULL,
  imageurl VARCHAR,
  isadmin BOOLEAN DEFAULT false,
  datecreated TIMESTAMP DEFAULT now()
);
```

### Items Table
```sql
CREATE TABLE items (
  itemid INT PRIMARY KEY,
  title VARCHAR NOT NULL,
  description TEXT,
  imageurl VARCHAR,
  category VARCHAR,
  type VARCHAR (sell/trade/rent),
  platform VARCHAR,
  price INT,
  userid INT REFERENCES users(userid),
  status BOOLEAN DEFAULT true,
  datecreated TIMESTAMP DEFAULT now()
);
```

### Favorites Table
```sql
CREATE TABLE favorites (
  userid INT REFERENCES users(userid),
  itemid INT REFERENCES items(itemid),
  PRIMARY KEY (userid, itemid)
);
```

---

## 🔑 KEY METHODS

### AuthCubit
```dart
// Check if user logged in on app start
await context.read<AuthCubit>().checkAuthStatus();

// User login
await context.read<AuthCubit>().login(email: 'user@example.com', password: 'pass');

// User registration
await context.read<AuthCubit>().register(
  email: 'new@example.com',
  password: 'pass',
  userName: 'john_gamer',
  phoneNum: 213555123456,
);

// User logout
await context.read<AuthCubit>().logout();
```

### ItemCubit
```dart
// Load all items
await context.read<ItemCubit>().loadAllItems();

// Load user's items
await context.read<ItemCubit>().loadUserItems(userId);

// Filter by category
context.read<ItemCubit>().filterByCategory('Games');

// Search items
context.read<ItemCubit>().searchItems('PS5');
```

### FavoriteCubit
```dart
// Load favorites for user
await context.read<FavoriteCubit>().loadFavorites(userId);

// Toggle favorite (add/remove)
await context.read<FavoriteCubit>().toggleFavorite(itemId, userId);
```

### ProfileCubit
```dart
// Load current user's profile
await context.read<ProfileCubit>().loadProfile();

// Load another user's profile
await context.read<ProfileCubit>().loadUserProfile(userId);
```

### LanguageCubit
```dart
// Load saved language on app start
await context.read<LanguageCubit>().loadLanguage();

// Change language (English/French)
await context.read<LanguageCubit>().changeLanguage(Locale('fr'));

// Get localized strings
final l10n = AppLocalizations.of(context)!;
Text(l10n.appName);  // "RePlay"
Text(l10n.login);    // "Login" or "Connexion"
```

---

## 🧩 REUSABLE WIDGETS

### CustomButton
```dart
CustomButton(
  text: 'Login',
  onPressed: _handleLogin,
  backgroundColor: AppColors.primary,
  isLoading: isLoading,
)
```

### CustomTextField
```dart
CustomTextField(
  controller: _emailController,
  hintText: 'Email address',
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
)
```

### LoadingWidget
```dart
LoadingWidget(message: 'Loading items...')
```

---

## 📞 HELPER FUNCTIONS

### Contact Actions
```dart
// Make phone call
await Helpers.makePhoneCall('213555123456');

// Send email
await Helpers.sendEmail(
  'seller@example.com',
  subject: 'Inquiry',
  body: 'Interested in your item'
);

// Open WhatsApp
await Helpers.openWhatsApp(
  '213555123456',
  'Hi! I found your listing on RePlay'
);
```

### Validation
```dart
// Validate phone (≥9 digits)
bool isValid = Helpers.isValidPhoneNumber('0555123456');

// Validate email
bool isValid = Helpers.isValidEmail('user@example.com');
```

### Formatting
```dart
// Format phone to international
String formatted = Helpers.formatPhoneForInternational('0555123456');
// Result: '213555123456'
```

### Notifications
```dart
Helpers.showSuccessSnackbar(context, 'Item posted!');
Helpers.showErrorSnackbar(context, 'Error occurred');
Helpers.showInfoSnackbar(context, 'Information');
```

---

## 🎨 APP COLORS

```dart
AppColors.primary              // #9C4DFF (Purple)
AppColors.background           // #121212 (Dark grey)
AppColors.cardBackground       // #1E1E1E (Slightly lighter)
AppColors.textPrimary          // White
AppColors.textSecondary        // Grey
AppColors.error                // Red
AppColors.success              // Green
```

---

## 🔄 DATA FLOW PATTERNS

### Pattern 1: Load & Display
```
Screen Init
  ↓
Cubit.load...()
  ↓
Emit Loading State
  ↓
Repository calls Service
  ↓
Service queries Supabase
  ↓
Cubit emits Loaded State
  ↓
BlocBuilder rebuilds UI
```

### Pattern 2: Create/Update/Delete
```
User Action (Button tap)
  ↓
Validate Input
  ↓
Cubit.create...() / update...() / delete...()
  ↓
Emit InProgress State
  ↓
Repository → Service → Supabase
  ↓
Emit Success State
  ↓
Show message
  ↓
Update UI / Navigate
```

### Pattern 3: Search/Filter (Local)
```
User types in search box / selects filter
  ↓
Cubit.search() / filter()
  ↓
Filter already-loaded items in memory
  ↓
Emit Loaded State with filtered items
  ↓
BlocBuilder rebuilds UI
```

---

## 📱 BOTTOM NAVIGATION

The app has 3 main tabs (always accessible):

| Icon | Name | Screen | Action |
|---|---|---|---|
| 🏠 | Home | HomeScreen | Browse items |
| ➕ | Add | AddListingScreen | Post new item |
| 👤 | Profile | ProfileScreen | View my items & favorites |

---

## 🔐 AUTHENTICATION FLOW

```
App Starts
  ↓
checkAuthStatus()
  ├─ Check if active session exists
  ├─ If YES → emit AuthAuthenticated
  │         → Show HomeScreen
  └─ If NO  → emit AuthUnauthenticated
           → Show LoginScreen
```

---

## 💾 IMAGE STORAGE

**Item Images:**
- Path: `/storage/v1/object/item-images/items/`
- Naming: `item_TIMESTAMP.jpg`
- Example: `item_1733000000000.jpg`
- URL: `https://storage.supabase.co/objects/public/item-images/items/item_...jpg`

**User Profile Images:**
- Path: `/storage/v1/object/user-images/users/`
- Naming: `user_TIMESTAMP.jpg`
- URL: `https://storage.supabase.co/objects/public/user-images/users/user_...jpg`

---

## 🧪 TESTING TIPS

### Check Authentication
```dart
final authState = context.read<AuthCubit>().state;
if (authState is AuthAuthenticated) {
  print('User: ${authState.user.userName}');
}
```

### Debug Item Loading
```dart
final itemState = context.read<ItemCubit>().state;
if (itemState is ItemLoaded) {
  print('Total items: ${itemState.allItems.length}');
  print('Filtered items: ${itemState.filteredItems.length}');
}
```

### Check Favorites
```dart
final favState = context.read<FavoriteCubit>().state;
if (favState is FavoriteLoaded) {
  print('Favorites count: ${favState.favorites.length}');
}
```

---

## 🐛 COMMON ISSUES & FIXES

| Issue | Cause | Fix |
|---|---|---|
| "Couldn't open WhatsApp" | WhatsApp not installed or invalid phone | Ensure phone has 9+ digits, try `Helpers.isValidPhoneNumber()` |
| "Could not open email" | No email app configured | Device must have email app (Gmail, Outlook, etc.) |
| Phone call doesn't work | Invalid number format | Use `Helpers.formatPhoneForInternational()` |
| Items not loading | Network issue | Check internet connection, try pull-to-refresh |
| Images not showing | Invalid URL or network | Check image URL is valid and accessible |
| Logout fails | Auth state not cleared | Make sure `AuthCubit.logout()` is called, not just navigation |
| Favorites not persisting | Not saved to database | Verify `FavoriteCubit.toggleFavorite()` completes before navigation |

---

## 📦 PROJECT STRUCTURE

```
lib/
├── main.dart                           # App entry point
├── l10n/                               # Localization files
│   ├── app_en.arb                     # English translations (220+ keys)
│   ├── app_fr.arb                     # French translations (220+ keys)
│   ├── app_localizations.dart         # Generated localization class
│   ├── app_localizations_en.dart      # Generated English impl
│   └── app_localizations_fr.dart      # Generated French impl
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_strings.dart
│   ├── utils/
│   │   ├── helpers.dart               # Phone, email, WhatsApp
│   │   └── validators.dart
│   └── widgets/
│       ├── custom_button.dart
│       ├── custom_textfield.dart
│       └── loading_widget.dart
├── data/
│   ├── datasources/
│   │   ├── auth_service.dart          # Supabase Auth
│   │   ├── item_service.dart          # Items CRUD
│   │   ├── user_service.dart          # Users CRUD
│   │   ├── favorite_service.dart      # Favorites CRUD
│   │   ├── language_service.dart      # Language persistence
│   │   └── supabase_service.dart      # Supabase client
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── item_model.dart
│   │   └── favorite_item_model.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── item_repository.dart
│       ├── user_repository.dart
│       └── favorite_repository.dart
├── logic/
│   ├── auth_cubit/
│   │   ├── auth_cubit.dart
│   │   └── auth_state.dart
│   ├── item_cubit/
│   │   ├── item_cubit.dart
│   │   └── item_state.dart
│   ├── favorite_cubit/
│   │   ├── favorite_cubit.dart
│   │   └── favorite_state.dart
│   ├── profile_cubit/
│   │   ├── profile_cubit.dart
│   │   └── profile_state.dart
│   └── language_cubit/
│       ├── language_cubit.dart
│       └── language_state.dart
└── presentation/
    └── screens/
        ├── splash_screen.dart
        ├── contact_seller_screen.dart
        ├── edit_profile_screen.dart
        ├── profile_screen.dart
        ├── auth/
        │   ├── login_screen.dart
        │   └── register_screen.dart
        ├── home/
        │   ├── home_screen.dart
        │   └── product_page_screen.dart
        └── item/
            ├── add_listing_screen.dart
            └── edit_item_screen.dart
```

---

## 🚀 COMMON OPERATIONS

### User Registration Flow
```dart
// 1. RegisterScreen collects data
final email = _emailController.text;
final password = _passwordController.text;
final userName = _userNameController.text;
final phoneNum = int.tryParse(_phoneController.text);

// 2. Call AuthCubit
context.read<AuthCubit>().register(
  email: email,
  password: password,
  userName: userName,
  phoneNum: phoneNum,
);

// 3. Listen to state changes in BlocListener
listener: (context, state) {
  if (state is AuthAuthenticated) {
    // Load data and navigate
    context.read<ItemCubit>().loadAllItems();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }
}
```

### Post Item Listing
```dart
// 1. User fills form and selects image
final item = ItemModel(
  title: _titleController.text,
  description: _descriptionController.text,
  price: int.tryParse(_priceController.text),
  category: _selectedCategory,
  type: _selectedType,
  imageUrl: null, // Will upload
  userId: currentUserId,
  status: true,
);

// 2. Upload image to storage
final imageUrl = await itemRepository.uploadItemImage(imageFile);

// 3. Update item with image URL
item = item.copyWith(imageUrl: imageUrl);

// 4. Create in database
final created = await itemRepository.createItem(item);

// 5. Navigate back
Navigator.pop(context, created);
```

### Contact Seller
```dart
// 1. Load seller info
final seller = await userService.getUserById(sellerId);

// 2. Handle phone call
final phone = seller.phoneNum.toString();
if (Helpers.isValidPhoneNumber(phone)) {
  await Helpers.makePhoneCall(phone);
}

// 3. Handle email
final email = seller.email;
if (Helpers.isValidEmail(email)) {
  await Helpers.sendEmail(email, subject: 'Inquiry from RePlay');
}

// 4. Handle WhatsApp
if (Helpers.isValidPhoneNumber(phone)) {
  await Helpers.openWhatsApp(phone, 'Hi! I found your listing...');
}
```

---

## 📈 Performance Notes

- **ItemCubit caches items** in memory (no re-fetch on filter/search)
- **Images are lazy-loaded** from network with error handling
- **Favorites loaded in parallel** with other profile data
- **Phone numbers stored as INT** to save space (validate before use)
- **Search is case-insensitive** for better UX

---

## 🔒 Security Considerations

1. **Passwords:** Handled by Supabase Auth (hashed, never stored locally)
2. **Email:** Lowercase & trimmed before queries
3. **Session:** Stored in Supabase, cleared on logout
4. **Image URLs:** Public, but only valid Supabase links
5. **Phone numbers:** Validated & formatted before external apps

---

## 🌍 LOCALIZATION (i18n)

### Supported Languages
- **English (en)** - Default
- **French (fr)**

### Key Translation Files
- `lib/l10n/app_en.arb` - English (220+ keys)
- `lib/l10n/app_fr.arb` - French (220+ keys)

### Usage in Screens
```dart
// Get localizations
final l10n = AppLocalizations.of(context)!;

// Use translated strings
Text(l10n.appName);        // "RePlay"
Text(l10n.login);          // "Login" or "Connexion"
Text(l10n.contactSeller);  // "Contact Seller" or "Contacter le vendeur"
```

### Change Language
```dart
// Switch to French
context.read<LanguageCubit>().changeLanguage(Locale('fr'));

// Switch to English
context.read<LanguageCubit>().changeLanguage(Locale('en'));
```

### Language Persistence
- Language preference saved to **SharedPreferences**
- Automatically restored on app restart
- Default: English if no preference saved

### Key Translation Categories
- **App Branding:** appName, appTagline
- **Auth:** login, signUp, email, password, logout
- **Navigation:** home, profile, marketplace
- **Categories:** games, consoles, accessories, electronics
- **Actions:** save, cancel, delete, edit, contactSeller
- **Validation:** requiredField, invalidEmail, passwordTooShort
- **Messages:** changesSaved, listingSuccess, listingError

### Dependencies
```yaml
flutter_localizations: sdk
intl: any
shared_preferences: ^2.3.5
```

---

## 📚 RESOURCES

- **Flutter Bloc Package:** https://bloclibrary.dev/
- **Supabase Docs:** https://supabase.com/docs
- **Material Design:** https://material.io/design
- **Dart Language:** https://dart.dev/

---

**End of Quick Reference**
