# RePlay - Complete Architecture & Code Documentation

**Project Name:** RePlay - Gaming Marketplace  
**Purpose:** A mobile application for buying, selling, trading, and renting gaming items (games, consoles, accessories)  
**Framework:** Flutter + Dart  
**Backend:** Supabase (Database + Authentication)  
**State Management:** Flutter Bloc (Cubit pattern)

---

## 📱 1. UI STRUCTURE & SCREENS

### Overview
The app has a layered navigation structure with 8 main screens connected via a bottom navigation bar and modal navigation.

---

### 1.1 **Splash Screen** 
**Path:** `lib/presentation/screens/splash_screen.dart`

**Purpose:** First screen users see when opening the app. Shows the RePlay branding and motivates users to get started.

**UI Components:**
- App logo: "Re" (purple) + "Play" (white) + video game icon
- Tagline: "Trade. Play. Repeat."
- "Get Started" button

**User Actions:**
- Tap "Get Started" → Navigate to Login Screen

**Data Flow:**
- No data needed
- No API calls

---

### 1.2 **Login Screen**
**Path:** `lib/presentation/screens/auth/login_screen.dart`

**Purpose:** Allow existing users to sign in with email and password.

**UI Components:**
- RePlay logo
- Email input field
- Password input field (with show/hide toggle)
- "Login" button
- "Don't have an account? Register" link
- Loading spinner when submitting

**User Actions:**
1. Enter email and password
2. Tap "Login" button
3. If successful → Navigate to Home Screen
4. If failed → Show error message
5. Tap "Register" link → Navigate to Register Screen

**Data Flow:**
```
User Input (email, password)
    ↓
AuthCubit.login()
    ↓
AuthRepository.signIn()
    ↓
AuthService (Supabase Auth)
    ↓
AuthState → AuthAuthenticated / AuthError
    ↓
UI Updates + Navigation
```

**Associated Cubit State:**
- `AuthLoading` - While signing in
- `AuthAuthenticated` - Login successful
- `AuthError` - Login failed

**Triggers on Success:**
- Load all items via `ItemCubit.loadAllItems()`
- Load user favorites via `FavoriteCubit.loadFavorites()`
- Load user profile via `ProfileCubit.loadProfile()`
- Navigate to Home Screen

---

### 1.3 **Register Screen**
**Path:** `lib/presentation/screens/auth/register_screen.dart`

**Purpose:** Allow new users to create an account with email, password, username, and optional phone number.

**UI Components:**
- Email input field
- Password input field (with show/hide toggle)
- Confirm Password input field
- Username input field
- Phone number input field (optional)
- Profile picture upload option (optional)
- "Register" button
- "Already have an account? Login" link

**User Actions:**
1. Fill in all required fields
2. Optionally upload a profile picture
3. Tap "Register" button
4. If successful → Navigate to Home Screen
5. If failed → Show error message

**Data Flow:**
```
User Input (email, password, username, phone, image)
    ↓
AuthCubit.register()
    ↓
AuthRepository.signUp()
    ↓
AuthService.signUp()
    ├─ Create auth user in Supabase Auth
    └─ Create user profile in 'users' table
    ↓
Fetch UserModel via getCurrentUserModel()
    ↓
AuthState → AuthAuthenticated / AuthError
    ↓
UI Updates + Navigation
```

---

### 1.4 **Home Screen**
**Path:** `lib/presentation/screens/home/home_screen.dart`

**Purpose:** Main feed showing all available gaming items. Users can browse, search, filter by category, and manage favorites.

**UI Components:**
- Search bar at top
- Category filter pills (All, Games, Consoles, Accessories, Electronics)
- Grid of item cards displaying:
  - Product image
  - Title
  - Price
  - Listing type (Sell/Trade/Rent)
  - Favorite heart icon
- Bottom navigation bar (3 tabs):
  - Home (currently selected)
  - Add Listing (+ icon)
  - Profile

**User Actions:**
1. **Search:** Type in search bar → Filter items by title/description
2. **Filter by Category:** Tap category pill → Show only items in that category
3. **View Item Details:** Tap item card → Navigate to Product Page Screen
4. **Toggle Favorite:** Tap heart icon → Add/remove from favorites
5. **Add Listing:** Tap + icon in bottom nav → Navigate to Add Listing Screen
6. **View Profile:** Tap profile icon → Navigate to Profile Screen

**Data Flow:**
```
Screen Loads
    ↓
ItemCubit.loadAllItems()
    ↓
ItemRepository.getAllItems()
    ↓
ItemService.getAllItems()
    ↓
Supabase Query: SELECT * FROM items ORDER BY datecreated
    ↓
ItemState → ItemLoaded (with all items)
    ↓
UI Renders Item Cards
```

**Category Filtering:**
```
User taps category
    ↓
ItemCubit.filterByCategory(categoryName)
    ↓
ItemState.activeCategory = categoryName
    ↓
ItemState.filteredItems = filtered list
    ↓
UI Updates to show only filtered items
```

**Search:**
```
User types in search box
    ↓
ItemCubit.searchItems(query)
    ↓
Filter by title/description/category/platform (case-insensitive)
    ↓
ItemState.searchQuery = query
    ↓
ItemState.filteredItems = search results
    ↓
UI Updates to show search results
```

**Favorite Toggle:**
```
User taps heart icon
    ↓
FavoriteCubit.toggleFavorite(itemId, userId)
    ↓
FavoriteRepository.toggleFavorite()
    ↓
If not favorited: FavoriteService.addFavorite()
If favorited: FavoriteService.removeFavorite()
    ↓
Supabase INSERT/DELETE on 'favorites' table
    ↓
FavoriteState updates
    ↓
UI heart icon changes color
```

---

### 1.5 **Product Page Screen** (Item Details)
**Path:** `lib/presentation/screens/home/product_page_screen.dart`

**Purpose:** Display detailed information about a single gaming item. Users can contact the seller from this screen.

**UI Components:**
- Large product image (with error handling and loading spinner)
- Product title
- Price
- Listing type (Sell/Trade/Rent)
- Category
- Platform (if available)
- Detailed description
- Seller information card with:
  - Seller name
  - Seller profile picture
  - "Contact Seller" button
- Bottom navigation bar (same as Home Screen)

**User Actions:**
1. **View Image:** Image loads with error handling
2. **Contact Seller:** Tap "Contact Seller" button → Navigate to Contact Seller Screen
3. **Edit (if your item):** Tap edit icon → Navigate to Edit Item Screen
4. **Delete (if your item):** Tap delete icon → Show confirmation dialog → Delete from database
5. **Add to Favorites:** Tap heart icon → Add to favorites
6. **Navigate:** Use bottom nav to go to Home, Add Listing, or Profile

**Data Passed In:**
- `ItemModel item` - Full item details passed from Home Screen

**Note:** All data is passed as parameter, no API calls needed on this screen.

---

### 1.6 **Contact Seller Screen**
**Path:** `lib/presentation/screens/contact_seller_screen.dart`

**Purpose:** Show seller information and provide ways to contact them (phone call, email, WhatsApp).

**UI Components:**
- Seller profile picture
- Seller name
- Seller email
- Contact options section with three items:
  1. **Phone Number** - Tap to call
  2. **Email Address** - Tap to send email
  3. **Message Seller** button - Opens WhatsApp
- Loading state while fetching seller info
- Error state if seller not found
- Bottom navigation bar

**User Actions:**
1. **Call Seller:** Tap phone number → Opens phone dialer with formatted number
2. **Email Seller:** Tap email → Opens email client with pre-filled subject
3. **Message on WhatsApp:** Tap "Message Seller" → Opens WhatsApp with pre-filled message
4. Navigate using bottom nav

**Data Flow:**
```
ContactSellerScreen receives: sellerId
    ↓
_loadSellerInfo()
    ↓
UserService.getUserById(sellerId)
    ↓
Supabase Query: SELECT * FROM users WHERE userid = sellerId
    ↓
Parse response to UserModel
    ↓
Update UI with seller information
```

**Contact Handler Examples:**

**Phone Call:**
```dart
_handlePhoneCall()
    ↓
Validate phone number (must have ≥9 digits)
    ↓
Format phone number:
  - Remove non-digit chars except +
  - If starts with 0, remove and add country code 213
  - If < 10 digits, prepend country code 213
  - Add + prefix for tel: scheme
    ↓
Build URI: tel:+213XXXXXXXXX
    ↓
launchUrl(uri)
    ↓
Android opens phone dialer with number pre-filled
```

**Email:**
```dart
_handleEmail()
    ↓
Validate email format (regex: email@domain.com)
    ↓
Build URI: mailto:seller@email.com?subject=Inquiry from RePlay App
    ↓
launchUrl(uri)
    ↓
Android opens default email app with:
  - To: seller@email.com
  - Subject: Inquiry from RePlay App
```

**WhatsApp:**
```dart
_handleWhatsApp()
    ↓
Validate phone number
    ↓
Format phone number for WhatsApp (country code + number, no +)
    ↓
Build URI: https://wa.me/213XXXXXXXXX?text=Hi!%20I%20found%20your%20listing...
    ↓
launchUrl(uri, mode: LaunchMode.externalApplication)
    ↓
If WhatsApp installed: Open WhatsApp chat with pre-filled message
If WhatsApp not installed: Show error
```

---

### 1.7 **Add Listing Screen**
**Path:** `lib/presentation/screens/item/add_listing_screen.dart`

**Purpose:** Allow users to create a new item listing with all details and image.

**UI Components:**
- Product image upload section:
  - Options to upload from device or use URL
  - Image preview
  - Remove button
- Form fields:
  - Title (required)
  - Description (optional)
  - Price (required for sell/rent)
  - Category dropdown (Games, Consoles, Accessories, Electronics)
  - Listing type radio buttons (Sell, Trade, Rent)
  - Platform (optional)
- "Post Listing" button
- Loading spinner when submitting

**User Actions:**
1. **Upload Image:**
   - Option 1: Tap "Pick from Device" → Image Picker opens → Select image
   - Option 2: Paste image URL
   - See preview of selected image
2. **Fill Form:**
   - Enter title, description, price
   - Select category
   - Select listing type
   - Enter platform (if applicable)
3. **Post Listing:** Tap button → Validate → Upload image → Create item in database
4. **Success:** Item created → Navigate to Home Screen or call callback

**Data Flow:**
```
User fills form and selects image
    ↓
_submitListing()
    ↓
Validate all required fields
    ↓
If image selected:
  ├─ Upload to Supabase Storage (items/item_TIMESTAMP.jpg)
  └─ Get public URL
Else if URL provided:
  └─ Use URL as is
Else:
  └─ Use null
    ↓
Create ItemModel with all fields
    ↓
ItemRepository.createItem(itemModel)
    ↓
ItemService.createItem()
    ↓
Supabase INSERT into 'items' table
    ↓
Return created ItemModel with new itemId
    ↓
Show success message
    ↓
Navigate back or call onItemCreated callback
```

**Image Upload Process:**
```
User selects image file from device
    ↓
Store in _selectedImage (File object)
    ↓
Show preview in UI
    ↓
On submit:
  ├─ Generate unique filename: item_TIMESTAMP.jpg
  ├─ Upload to Supabase Storage: items/item_TIMESTAMP.jpg
  └─ Get public URL: https://storage.supabase.co/objects/public/item-images/items/item_TIMESTAMP.jpg
    ↓
Use public URL in ItemModel.imageUrl
    ↓
Save to database
```

---

### 1.8 **Edit Item Screen**
**Path:** `lib/presentation/screens/item/edit_item_screen.dart`

**Purpose:** Allow item owners to edit an existing listing.

**UI Components:**
- Same as Add Listing Screen but pre-filled with current values
- Additional "Delete Item" button
- Save changes button instead of "Post Listing"

**User Actions:**
1. **View Current Values:** Form pre-fills with existing item data
2. **Edit Fields:** Change any values (title, description, price, category, etc.)
3. **Change Image:**
   - Remove current image
   - Upload new image
   - Or keep existing
4. **Save Changes:** Validate → Upload new image if needed → Update in database
5. **Delete Item:** Show confirmation dialog → Delete from database
6. **Success:** Return to previous screen with updated item

**Data Flow:**
```
EditItemScreen receives: ItemModel item
    ↓
Pre-fill form fields with item values
    ↓
User edits fields
    ↓
User taps "Save Changes"
    ↓
Validate fields (not empty, price is number)
    ↓
Handle image:
  ├─ If new image selected: Upload to Supabase Storage
  ├─ If image deleted: Set imageUrl to null
  └─ If unchanged: Keep existing imageUrl
    ↓
Build updates map: {'title': ..., 'description': ..., 'imageurl': ..., ...}
    ↓
ItemService.updateItem(itemId, updates)
    ↓
Supabase UPDATE on 'items' table WHERE itemid = ?
    ↓
Return success/failure
    ↓
Show message
    ↓
Navigate back with updated ItemModel
```

---

### 1.9 **Profile Screen**
**Path:** `lib/presentation/screens/profile_screen.dart`

**Purpose:** Show current user's profile, their listings, and their favorites. Allow editing profile and managing listings.

**UI Components:**
- User information card:
  - Profile picture
  - Username
  - Email
  - Phone number (if available)
  - Edit Profile button
  - Logout button
- Two tabs:
  - **My Listings** - Grid of user's items
  - **Favorites** - Grid of favorited items
- Each item card has:
  - Image
  - Title
  - Price
  - Edit button (only for user's own items)
  - Delete button (only for user's own items)

**User Actions:**
1. **View Profile:** All user data displayed
2. **Edit Profile:** Tap "Edit Profile" → Navigate to Edit Profile Screen
3. **View My Listings:** Tab shows all items user has posted
4. **View Favorites:** Tab shows all items user has favorited
5. **Edit Item:** Tap edit button → Navigate to Edit Item Screen
6. **Delete Item:** Tap delete → Show confirmation → Delete
7. **Logout:** Tap "Logout" → Show confirmation → Sign out and return to Login Screen

**Data Flow:**
```
Profile Screen loads
    ↓
ProfileCubit.loadProfile()
    ↓
Get current user from AuthRepository.getCurrentUserModel()
    ↓
Load in parallel:
  ├─ ItemRepository.getItemsByUser(userId)
  └─ FavoriteRepository.getUserFavorites(userId)
    ↓
ProfileState → ProfileLoaded
  ├─ user: UserModel
  ├─ myListings: List<ItemModel>
  └─ myFavorites: List<ItemModel>
    ↓
UI displays all three in tabs
```

**Logout Flow:**
```
User taps "Logout"
    ↓
Show confirmation dialog
    ↓
User confirms
    ↓
AuthCubit.logout()
    ↓
AuthRepository.signOut()
    ↓
AuthService.signOut() → Supabase sign out
    ↓
AuthState → AuthUnauthenticated
    ↓
Listen to auth state change
    ↓
Navigate to Login Screen
```

---

### 1.10 **Edit Profile Screen**
**Path:** `lib/presentation/screens/edit_profile_screen.dart`

**Purpose:** Allow users to update their profile information (username, phone, profile picture).

**UI Components:**
- Profile picture upload/change option
- Username edit field
- Phone number edit field
- Email display (read-only)
- "Save Changes" button
- "Cancel" button

**User Actions:**
1. **Change Picture:** Tap picture → Select new image from device
2. **Edit Info:** Change username and/or phone number
3. **Save:** Validate fields → Upload new picture if needed → Update in database
4. **Cancel:** Go back without saving

---

## 🏗️ 2. ARCHITECTURE & DATA FLOW

### 2.1 Architecture Pattern: Cubit + Repository + Supabase

This app follows the **BLoC (Business Logic Component)** pattern with **Cubit** as the state management solution.

**Three-Layer Architecture:**

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  (Screens, Widgets, UI Components)                           │
│  - LoginScreen, HomeScreen, ProfileScreen, etc.              │
│  - CustomButton, CustomTextField, LoadingWidget              │
│  - Listen to Cubits and rebuild when state changes           │
└─────────────────────────────────────────────────────────────┘
                            ↑    ↓
          emit() states     │    │ listen() to states
                            │    │
┌─────────────────────────────────────────────────────────────┐
│                     LOGIC LAYER (Cubits)                     │
│  - AuthCubit (authentication state)                          │
│  - ItemCubit (items/listings state)                          │
│  - FavoriteCubit (favorites state)                           │
│  - ProfileCubit (profile state)                              │
│  - Each Cubit manages business logic and state               │
│  - Cubits call Repositories for data operations              │
└─────────────────────────────────────────────────────────────┘
                            ↑    ↓
         call methods       │    │ return data
                            │    │
┌─────────────────────────────────────────────────────────────┐
│                    DATA LAYER (Repositories)                 │
│  - AuthRepository (abstracts authentication)                 │
│  - ItemRepository (abstracts item operations)                │
│  - FavoriteRepository (abstracts favorite operations)        │
│  - UserRepository (abstracts user operations)                │
│  - Each Repository calls Services                            │
└─────────────────────────────────────────────────────────────┘
                            ↑    ↓
         call methods       │    │ return data
                            │    │
┌─────────────────────────────────────────────────────────────┐
│            DATA SOURCES LAYER (Services)                     │
│  - AuthService (Supabase Auth operations)                    │
│  - ItemService (Supabase items table CRUD)                   │
│  - UserService (Supabase users table CRUD)                   │
│  - FavoriteService (Supabase favorites table CRUD)           │
│  - SupabaseService (Supabase client singleton)               │
│  - Direct database and storage access                        │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                SUPABASE BACKEND                              │
│  - PostgreSQL Database (users, items, favorites tables)      │
│  - Authentication (email/password via Auth)                  │
│  - Storage (image files for items and profiles)              │
└─────────────────────────────────────────────────────────────┘
```

---

### 2.2 Complete Data Flow Example: User Login

**What happens when user logs in:**

```
1. USER INTERACTION (UI Layer)
   └─ User enters email & password in LoginScreen
   └─ Taps "Login" button
   
2. CUBIT ACTION (Logic Layer)
   └─ LoginScreen calls: context.read<AuthCubit>().login(email, password)
   └─ AuthCubit.login() emits AuthLoading state
   
3. REPOSITORY CALL (Data Layer)
   └─ AuthCubit calls: _authRepository.signIn(email, password)
   └─ AuthRepository.signIn() calls: _authService.signIn(email, password)
   
4. SERVICE CALL (Data Source Layer)
   └─ AuthService.signIn() calls: Supabase.auth.signInWithPassword(email, password)
   └─ Supabase authenticates the user and returns Session
   
5. RESPONSE
   └─ AuthService returns: User object (or null if failed)
   └─ AuthRepository receives User object
   
6. FETCH USER MODEL (Data Layer)
   └─ AuthRepository calls: _userService.getUserByEmail(email)
   └─ UserService queries: SELECT * FROM users WHERE email = email
   └─ Supabase returns user record
   
7. STATE EMISSION (Logic Layer)
   └─ AuthCubit receives UserModel
   └─ AuthCubit emits: AuthAuthenticated(userModel)
   
8. UI UPDATE (Presentation Layer)
   └─ LoginScreen listens to AuthCubit state
   └─ Receives AuthAuthenticated state
   └─ BlocListener triggers:
      - Loads favorites
      - Loads items
      - Navigates to HomeScreen
```

**Timeline:**
```
T=0ms   User taps Login
T=1ms   AuthCubit emits AuthLoading
T=10ms  AuthService calls Supabase.auth.signInWithPassword()
T=50ms  Supabase responds with User object
T=55ms  AuthRepository fetches UserModel from database
T=60ms  Supabase returns user record
T=65ms  AuthCubit emits AuthAuthenticated(userModel)
T=70ms  BlocListener receives AuthAuthenticated
T=100ms All data loaded, navigate to HomeScreen
```

---

### 2.3 Item Creation Flow (Add Listing)

```
1. USER UPLOADS IMAGE & FILLS FORM
   └─ AddListingScreen: User selects image from device storage
   └─ Image stored in _selectedImage (File object)
   └─ User fills title, description, price, category, type, platform
   
2. USER SUBMITS
   └─ Taps "Post Listing" button
   └─ Validation checks:
      ✓ Title not empty
      ✓ Price is valid number (if sell/rent)
      ✓ Category selected
      ✓ Type selected
   
3. IMAGE UPLOAD (if image selected)
   └─ ItemRepository.uploadItemImage(imageFile)
   └─ Supabase Storage request:
      POST /storage/v1/object/item-images/items/item_1733000000000.jpg
      └─ Binary image data
   └─ Supabase returns public URL:
      https://storage.supabase.co/objects/public/item-images/items/item_1733000000000.jpg
   
4. CREATE ITEM IN DATABASE
   └─ Build ItemModel with all fields + imageUrl
   └─ ItemRepository.createItem(itemModel)
   └─ ItemService.createItem() calls:
      INSERT INTO items (title, description, price, category, type, 
                         platform, imageurl, userid, status, datecreated)
      VALUES (...)
   └─ Supabase returns created item with new itemId
   
5. STATE UPDATE
   └─ ItemCubit can reload items or update local state
   
6. NAVIGATION
   └─ Navigate back to HomeScreen
   └─ Show success message
   └─ Call onItemCreated callback if provided
```

---

### 2.4 Search & Filter Flow (Home Screen)

**Category Filter:**
```
User taps "Games" category
    ↓
HomeScreen calls: context.read<ItemCubit>().filterByCategory('Games')
    ↓
ItemCubit.filterByCategory():
  1. Get current ItemLoaded state
  2. Filter allItems where category == 'Games'
  3. Emit new ItemLoaded state with:
     - filteredItems: [games only]
     - activeCategory: 'Games'
    ↓
BlocBuilder in HomeScreen rebuilds
    ↓
UI shows only games
```

**Search Query:**
```
User types "PlayStation 5" in search box
    ↓
HomeScreen calls: context.read<ItemCubit>().searchItems('PlayStation 5')
    ↓
ItemCubit.searchItems():
  1. Get current ItemLoaded state
  2. Filter items where title/description contains "PlayStation 5"
  3. If category active, apply category filter first
  4. Emit ItemLoaded with:
     - filteredItems: [matching items]
     - searchQuery: 'PlayStation 5'
    ↓
UI updates with search results in real-time
```

**Combined Search + Category:**
```
Active category: Games
User types: "Mario"
    ↓
ItemCubit.searchItems():
  1. Start with category filtered items (only games)
  2. Search within those games for "Mario"
  3. Return games that contain "Mario"
    ↓
UI shows: Mario games only
```

---

### 2.5 Favorite Toggle Flow

```
User taps heart icon on item card
    ↓
HomeScreen calls: _toggleFavorite(itemId)
    ↓
Check if item is in favorites by looking at FavoriteCubit state
    ↓
If NOT favorited:
  └─ FavoriteCubit.addFavorite(itemId, userId)
     └─ FavoriteRepository.addFavorite()
     └─ FavoriteService.addFavorite()
     └─ INSERT into favorites table:
        INSERT INTO favorites (userid, itemid) VALUES (123, 456)
     └─ FavoriteCubit emits updated state
If already favorited:
  └─ FavoriteCubit.removeFavorite(itemId, userId)
     └─ FavoriteService.removeFavorite()
     └─ DELETE from favorites table:
        DELETE FROM favorites WHERE userid=123 AND itemid=456
     └─ FavoriteCubit emits updated state
    ↓
Heart icon changes color (purple if favorited, grey if not)
```

---

## 📊 3. DATABASE & DATA MODELS

### 3.1 Database Tables

**Supabase PostgreSQL Database Structure:**

#### **Table: users**
```
Column Name    | Type      | Constraints          | Description
─────────────────────────────────────────────────────────────
userid         | INT       | PRIMARY KEY, AUTO    | User ID (unique identifier)
username       | VARCHAR   | UNIQUE, NOT NULL     | Display name
email          | VARCHAR   | UNIQUE, NOT NULL     | Email for login
phonenum       | INT       | (optional)           | Phone number (no + prefix)
password       | VARCHAR   | NOT NULL             | Hashed password (via Supabase Auth)
imageurl       | VARCHAR   | (optional)           | Profile picture URL
isadmin        | BOOLEAN   | DEFAULT: false       | Admin flag
datecreated    | TIMESTAMP | DEFAULT: now()       | Account creation date
```

**Example Row:**
```
userid: 1
username: "john_gamer"
email: "john@example.com"
phonenum: 213555123456
password: [hashed by Supabase Auth]
imageurl: "https://storage.supabase.co/objects/public/.../user_1.jpg"
isadmin: false
datecreated: "2024-12-01 10:30:00"
```

---

#### **Table: items**
```
Column Name    | Type      | Constraints          | Description
─────────────────────────────────────────────────────────────
itemid         | INT       | PRIMARY KEY, AUTO    | Item ID
title          | VARCHAR   | NOT NULL             | Item name
description    | TEXT      | (optional)           | Detailed description
imageurl       | VARCHAR   | (optional)           | Product image URL
category       | VARCHAR   | (Games, Consoles...) | Item category
type           | VARCHAR   | (sell, trade, rent)  | Listing type
platform       | VARCHAR   | (optional)           | Gaming platform
price          | INT       | (optional)           | Price (required if sell/rent)
userid         | INT       | FOREIGN KEY → users  | Seller's user ID
status         | BOOLEAN   | DEFAULT: true        | Active/Inactive listing
datecreated    | TIMESTAMP | DEFAULT: now()       | When listed
```

**Example Row:**
```
itemid: 456
title: "PlayStation 5 Bundle"
description: "PS5 with 2 controllers and 5 games. Excellent condition."
imageurl: "https://storage.supabase.co/objects/public/.../item_456.jpg"
category: "Consoles"
type: "sell"
platform: "PS5"
price: 450
userid: 1
status: true
datecreated: "2024-12-05 14:20:00"
```

---

#### **Table: favorites**
```
Column Name    | Type      | Constraints                    | Description
──────────────────────────────────────────────────────────────
userid         | INT       | FOREIGN KEY → users            | User ID
itemid         | INT       | FOREIGN KEY → items            | Item ID
PRIMARY KEY    |           | (userid, itemid) combination   | Unique favorite per user/item
```

**Example Row:**
```
userid: 2
itemid: 456
[This means: User 2 favorited Item 456]
```

**Example Queries:**
```sql
-- Get all favorites for a user
SELECT items.* FROM items
JOIN favorites ON items.itemid = favorites.itemid
WHERE favorites.userid = 2;

-- Check if item is favorited by user
SELECT * FROM favorites WHERE userid = 2 AND itemid = 456;

-- Remove from favorites
DELETE FROM favorites WHERE userid = 2 AND itemid = 456;
```

---

### 3.2 Dart Models (Mapping to Database)

#### **UserModel**
```dart
class UserModel {
  final int? userId;              // ← maps to: userid
  final String userName;          // ← maps to: username
  final String email;             // ← maps to: email
  final int? phoneNum;            // ← maps to: phonenum
  final String password;          // ← maps to: password
  final String? imageUrl;         // ← maps to: imageurl
  final bool isAdmin;             // ← maps to: isadmin
  final DateTime? dateCreated;    // ← maps to: datecreated
  
  // Constructor & methods...
}
```

**Usage:**
```dart
// Fetch from database
UserModel user = UserModel.fromJson(
  {
    'userid': 1,
    'username': 'john_gamer',
    'email': 'john@example.com',
    'phonenum': 213555123456,
    'password': '[hashed]',
    'imageurl': 'https://...',
    'isadmin': false,
    'datecreated': '2024-12-01...'
  }
);

// Update and send to database
Map<String, dynamic> updateMap = {
  'username': 'new_username',
  'phonenum': 213666444555,
};
```

---

#### **ItemModel**
```dart
class ItemModel {
  final int? itemId;              // ← maps to: itemid
  final String? imageUrl;         // ← maps to: imageurl
  final String title;             // ← maps to: title
  final String? description;      // ← maps to: description
  final String? type;             // ← maps to: type (sell/trade/rent)
  final String? category;         // ← maps to: category
  final String? platform;         // ← maps to: platform
  final int? price;               // ← maps to: price
  final int userId;               // ← maps to: userid
  final bool status;              // ← maps to: status
  final DateTime? dateCreated;    // ← maps to: datecreated
  
  // Constructor & methods...
}
```

---

#### **FavoriteItemModel**
```dart
class FavoriteItemModel {
  final int userId;               // ← maps to: userid
  final int itemId;               // ← maps to: itemid
  
  // Constructor & methods...
}
```

---

### 3.3 Relationships Between Tables

**One-to-Many: Users → Items**
```
One user can have many items.

SELECT * FROM items WHERE userid = 1;
// Returns all items posted by user 1
```

**Many-to-Many: Users ↔ Items (via Favorites)**
```
One user can favorite many items.
One item can be favorited by many users.

SELECT items.* FROM items
JOIN favorites ON items.itemid = favorites.itemid
WHERE favorites.userid = 2;
// Returns all items favorited by user 2

SELECT COUNT(*) FROM favorites WHERE itemid = 456;
// Returns how many users favorited item 456
```

---

## 🧠 4. STATE MANAGEMENT WITH CUBITS

### 4.1 AuthCubit - Authentication Management

**File:** `lib/logic/auth_cubit/auth_cubit.dart`

**Responsibility:** Manage user authentication (login, register, logout, session)

**States:**
- `AuthInitial` - App just started, no auth check done yet
- `AuthLoading` - Checking auth or logging in
- `AuthAuthenticated` - User is logged in, contains UserModel
- `AuthUnauthenticated` - User not logged in
- `AuthError` - Something went wrong

**Key Methods:**
```dart
Future<void> checkAuthStatus()
// Called when app starts
// Checks if user has active session
// Emits AuthAuthenticated if logged in, else AuthUnauthenticated

Future<void> login({required String email, required String password})
// User login
// Emits: AuthLoading → AuthAuthenticated OR AuthError

Future<void> register({
  required String email,
  required String password,
  required String userName,
  int? phoneNum,
  String? imageUrl,
})
// User registration
// Creates auth user + database user record
// Emits: AuthLoading → AuthAuthenticated OR AuthError

Future<void> logout()
// User logout
// Signs out from Supabase
// Emits: AuthLoading → AuthUnauthenticated
```

**Data Flow Example:**
```
User taps Login
    ↓
LoginScreen calls: context.read<AuthCubit>().login(email, password)
    ↓
AuthCubit emits: AuthLoading()
    ↓
LoginScreen shows loading spinner
    ↓
AuthCubit calls: _authRepository.signIn(email, password)
    ↓
[Supabase processes...]
    ↓
AuthCubit gets UserModel back
    ↓
AuthCubit emits: AuthAuthenticated(userModel)
    ↓
LoginScreen listens and navigates to HomeScreen
```

---

### 4.2 ItemCubit - Listings Management

**File:** `lib/logic/item_cubit/item_cubit.dart`

**Responsibility:** Manage items/listings (load, filter, search, create, update, delete)

**States:**
- `ItemInitial` - No items loaded yet
- `ItemLoading` - Loading items from database
- `ItemLoaded` - Items loaded, contains allItems, filteredItems, activeCategory, searchQuery
- `ItemOperationInProgress` - Creating/updating/deleting an item
- `ItemOperationSuccess` - Operation successful, may contain updated item
- `ItemError` - Something went wrong

**Key Methods:**
```dart
Future<void> loadAllItems()
// Load all items from database
// Emits: ItemLoading → ItemLoaded

Future<void> loadUserItems(int userId)
// Load items for a specific user
// Emits: ItemLoading → ItemLoaded

void filterByCategory(String? category)
// Filter loaded items by category (in-memory)
// Doesn't re-query database, filters current allItems
// Emits: ItemLoaded with updated filteredItems

void searchItems(String query)
// Search loaded items by title/description
// Emits: ItemLoaded with updated filteredItems

void createItem(ItemModel item)
void updateItem(int itemId, ItemModel item)
void deleteItem(int itemId)
// CRUD operations
// Call repository methods
```

**State Details:**
```dart
class ItemLoaded extends ItemState {
  final List<ItemModel> allItems;       // All items from database
  final List<ItemModel> filteredItems;  // Items after filter/search
  final String? activeCategory;         // Currently active category
  final String? searchQuery;            // Current search query
}
```

**Example State:**
```dart
ItemLoaded(
  allItems: [50 items from database],
  filteredItems: [
    Item: "PlayStation 5",
    Item: "Xbox Series X",
    Item: "Nintendo Switch",
  ], // Only consoles
  activeCategory: "Consoles",
  searchQuery: null,
)
```

**Filter Flow:**
```
Initial State:
  allItems: 50 items (mixed categories)
  filteredItems: 50 items
  
User selects "Games" category:
  allItems: still 50 items (unchanged)
  filteredItems: 20 items (games only)
  activeCategory: "Games"
  
User types "Mario":
  allItems: still 50 items (unchanged)
  filteredItems: 5 items (games with "Mario")
  activeCategory: "Games"
  searchQuery: "Mario"
  
User clears search:
  allItems: 50 items
  filteredItems: 20 items (back to games)
  searchQuery: null
```

---

### 4.3 FavoriteCubit - Favorites Management

**Responsibility:** Manage user's favorite items

**States:**
- `FavoriteInitial`
- `FavoriteLoading`
- `FavoriteLoaded` - Contains List<ItemModel> of favorites
- `FavoriteError`

**Key Methods:**
```dart
Future<void> loadFavorites(int userId)
// Load all favorites for a user
// Query favorites table and join with items

Future<void> toggleFavorite(int itemId, int userId)
// Add or remove from favorites
// Checks current state to determine action
```

---

### 4.4 ProfileCubit - User Profile Management

**Responsibility:** Load and manage user profile data

**States:**
- `ProfileInitial`
- `ProfileLoading`
- `ProfileLoaded` - Contains UserModel, myListings, myFavorites
- `ProfileError`

**Key Methods:**
```dart
Future<void> loadProfile()
// Load current logged-in user's profile
// Also loads their listings and favorites in parallel
// Emits: ProfileLoading → ProfileLoaded

Future<void> updateProfile(UserModel updatedUser)
// Update user info (username, phone, image)
// Emits: ProfileLoading → ProfileLoaded

Future<void> loadUserProfile(int userId)
// Load another user's profile (for viewing)
// Only shows their listings, not their favorites
```

**Profile Load Flow:**
```
ProfileScreen mounts
    ↓
_loadUserData() calls: context.read<ProfileCubit>().loadProfile()
    ↓
ProfileCubit emits: ProfileLoading()
    ↓
ProfileCubit does in parallel:
  ├─ Fetch current user from AuthRepository
  ├─ Fetch user's items from ItemRepository
  └─ Fetch user's favorites from FavoriteRepository
    ↓
All three complete
    ↓
ProfileCubit emits: ProfileLoaded(
  user: UserModel,
  myListings: [items],
  myFavorites: [items]
)
    ↓
BlocBuilder rebuilds UI with all data
    ↓
Tabs show listings and favorites
```

---

## 🎨 5. REUSABLE COMPONENTS & HELPERS

### 5.1 CustomButton Widget

**File:** `lib/core/widgets/custom_button.dart`

**Purpose:** Reusable button component for consistent styling across app

**Constructor:**
```dart
CustomButton({
  required String text,              // Button label
  VoidCallback? onPressed,           // Tap callback
  Color? backgroundColor,            // Button color
  Color? textColor,                  // Text color
  double? width,                     // Custom width
  double? height,                    // Custom height
  double? fontSize,                  // Text size
  FontWeight? fontWeight,            // Text weight
  BorderRadius? borderRadius,        // Corner radius
  bool isLoading = false,            // Show spinner?
  IconData? icon,                    // Optional leading icon
  bool isOutlined = false,           // Outlined style?
})
```

**Usage Examples:**
```dart
// Filled button
CustomButton(
  text: 'Login',
  onPressed: _handleLogin,
  backgroundColor: AppColors.primary,
)

// Outlined button
CustomButton(
  text: 'Cancel',
  onPressed: () => Navigator.pop(context),
  isOutlined: true,
)

// Loading state
CustomButton(
  text: 'Signing in...',
  isLoading: true,
  onPressed: null,
)
```

---

### 5.2 CustomTextField Widget

**File:** `lib/core/widgets/custom_textfield.dart`

**Purpose:** Reusable input field with styling and validation

**Constructor:**
```dart
CustomTextField({
  TextEditingController? controller,
  String? hintText,                 // Placeholder text
  String? labelText,                // Label above field
  IconData? prefixIcon,             // Icon on left
  Widget? suffixIcon,               // Icon on right (e.g., visibility toggle)
  bool obscureText = false,         // Hide text (password)
  TextInputType? keyboardType,      // Number, email, etc.
  String? Function(String?)? validator,  // Validation function
  void Function(String)? onChanged,
  int? maxLines = 1,
  int? maxLength,
  bool readOnly = false,
  // ... many more customization options
})
```

**Usage Examples:**
```dart
// Email field
CustomTextField(
  controller: _emailController,
  hintText: 'Enter email',
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Email required';
    if (!value!.contains('@')) return 'Invalid email';
    return null;
  },
)

// Password field with visibility toggle
CustomTextField(
  controller: _passwordController,
  hintText: 'Enter password',
  obscureText: !_showPassword,
  prefixIcon: Icons.lock,
  suffixIcon: IconButton(
    icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
    onPressed: () => setState(() => _showPassword = !_showPassword),
  ),
)

// Multi-line text area
CustomTextField(
  controller: _descriptionController,
  hintText: 'Item description',
  maxLines: 5,
  keyboardType: TextInputType.multiline,
)
```

---

### 5.3 LoadingWidget

**File:** `lib/core/widgets/loading_widget.dart`

**Purpose:** Show loading indicator with message

**Usage:**
```dart
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return LoadingWidget(message: 'Signing in...');
    }
    // ... rest of UI
  },
)
```

---

### 5.4 Helpers Class - Contact Actions

**File:** `lib/core/utils/helpers.dart`

**Purpose:** Utility functions for phone calls, emails, WhatsApp

**Key Methods:**

#### **1. Phone Call**
```dart
static Future<void> makePhoneCall(String phoneNumber) async
// Opens phone dialer with given number
// Requires: url_launcher package
// On Android: Calls the system phone app
// Example:
//   await Helpers.makePhoneCall('213555123456');
//   → Opens dialer with +213555123456
```

#### **2. Email**
```dart
static Future<void> sendEmail(
  String email, {
  String? subject,
  String? body,
}) async
// Opens default email app
// Pre-fills recipient, subject, body
// Example:
//   await Helpers.sendEmail(
//     'seller@email.com',
//     subject: 'Inquiry about item',
//     body: 'Hi, I am interested in your listing...'
//   );
```

#### **3. WhatsApp**
```dart
static Future<void> openWhatsApp(
  String phoneNumber,
  [String? message]
) async
// Opens WhatsApp with pre-filled message
// Uses https://wa.me/ deep link
// Example:
//   await Helpers.openWhatsApp(
//     '213555123456',
//     'Hi! I found your listing on RePlay'
//   );
```

#### **4. Phone Validation**
```dart
static bool isValidPhoneNumber(String? phoneNumber)
// Checks if phone has at least 9 digits
// Returns: true/false
```

#### **5. Email Validation**
```dart
static bool isValidEmail(String? email)
// Regex check for email format
// Returns: true/false
```

#### **6. Phone Formatting**
```dart
static String formatPhoneForInternational(
  String phoneNumber,
  {String defaultCountryCode = '213'}
)
// Formats phone for international use
// Examples:
//   '0555123456' → '213555123456'
//   '555123456' → '213555123456'
//   '213555123456' → '213555123456' (unchanged)
```

#### **7. Snackbar Methods**
```dart
static void showSnackbar(BuildContext context, String message, {...})
static void showSuccessSnackbar(BuildContext context, String message)
static void showErrorSnackbar(BuildContext context, String message)
static void showInfoSnackbar(BuildContext context, String message)
// Show temporary messages at bottom of screen
```

**Contact Seller Example Flow:**
```
User taps "Message on WhatsApp"
    ↓
_handleWhatsApp() called
    ↓
1. Validate phone: Helpers.isValidPhoneNumber(phoneNum)
   → Must have ≥9 digits
    ↓
2. Format phone: Helpers.formatPhoneForInternational(phoneNum)
   → If starts with 0: remove and add 213 prefix
   → Result: '213555123456'
    ↓
3. Open WhatsApp: await Helpers.openWhatsApp(phone, message)
   → Build URL: https://wa.me/213555123456?text=Hi!%20...
   → Launch URL with LaunchMode.externalApplication
    ↓
4. If WhatsApp installed: Opens chat with seller
   If not installed: Shows error "Could not open WhatsApp"
```

---

### 5.5 App Constants & Colors

**File:** `lib/core/constants/app_colors.dart`
```dart
class AppColors {
  static const Color primary = Color(0xFF9C4DFF);      // Purple
  static const Color background = Color(0xFF121212);   // Dark grey
  static const Color cardBackground = Color(0xFF1E1E1E); // Slightly lighter
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.grey;
  static const Color error = Colors.red;
  static const Color success = Colors.green;
  // ... more colors
}
```

**File:** `lib/core/constants/app_strings.dart`
```dart
class AppStrings {
  static const String appName = 'RePlay';
  static const String home = 'Home';
  static const String profile = 'Profile';
  static const String add = 'Add';
  static const String contactSeller = 'Contact Seller';
  static const String phoneNumber = 'Phone Number';
  static const String emailAddress = 'Email Address';
  static const String messageSeller = 'Message Seller';
  // ... all UI strings
}
```

---

## 📐 6. ARCHITECTURE DIAGRAM

### High-Level System Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                          USER (Mobile Device)                         │
│                         Android / iOS Screen                          │
└──────────────────────────────────────────────────────────────────────┘
                                     ↑
                                     │ UI Updates & User Input
                                     │
┌──────────────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER (UI)                           │
│  ┌─────────────────┐  ┌──────────────┐  ┌────────────────┐           │
│  │ Login/Register  │  │ Home Screen  │  │ Product Page   │           │
│  │ (Auth Screens)  │  │ (Listings)   │  │ (Item Details) │           │
│  └─────────────────┘  └──────────────┘  └────────────────┘           │
│                                                                       │
│  ┌──────────────────┐  ┌────────────┐  ┌─────────────────┐          │
│  │ Profile Screen   │  │ Add/Edit   │  │ Contact Seller  │          │
│  │ (My Info)        │  │ Listing    │  │ (Phone/Email)   │          │
│  └──────────────────┘  └────────────┘  └─────────────────┘          │
│                                                                       │
│  ┌──────────────────────────────────────────────────────────┐        │
│  │   WIDGETS & COMPONENTS                                   │        │
│  │  CustomButton  CustomTextField  LoadingWidget  Helpers   │        │
│  └──────────────────────────────────────────────────────────┘        │
└──────────────────────────────────────────────────────────────────────┘
                                     ↑
                        listen() / BlocBuilder & BlocListener
                                     │
┌──────────────────────────────────────────────────────────────────────┐
│                    LOGIC LAYER (State Management)                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                │
│  │ AuthCubit    │  │ ItemCubit    │  │ProfileCubit  │                │
│  │ - login      │  │ - loadItems  │  │ - loadProf.  │                │
│  │ - register   │  │ - search     │  │ - updateProf │                │
│  │ - logout     │  │ - filter     │  │              │                │
│  │ - checkAuth  │  │ - create     │  │              │                │
│  └──────────────┘  └──────────────┘  └──────────────┘                │
│  ┌──────────────┐                                                     │
│  │FavoriteCubit │                                                     │
│  │ - load       │                                                     │
│  │ - toggle     │                                                     │
│  └──────────────┘                                                     │
└──────────────────────────────────────────────────────────────────────┘
                              ↑        ↓
                   call methods / return data
                              │        │
┌──────────────────────────────────────────────────────────────────────┐
│                    DATA LAYER (Repositories)                          │
│  ┌──────────────────┐  ┌──────────────────┐  ┌─────────────────┐   │
│  │ AuthRepository   │  │ ItemRepository   │  │ FavoriteRepository │   │
│  │ - signIn         │  │ - createItem     │  │ - addFavorite   │   │
│  │ - signUp         │  │ - getAllItems    │  │ - removeFav.    │   │
│  │ - signOut        │  │ - updateItem     │  │ - getFavorites  │   │
│  │ - getCurrentUser │  │ - deleteItem     │  │                 │   │
│  └──────────────────┘  └──────────────────┘  └─────────────────┘   │
│  ┌──────────────────┐                                               │
│  │ UserRepository   │                                               │
│  │ - getUser        │                                               │
│  │ - updateUser     │                                               │
│  └──────────────────┘                                               │
└──────────────────────────────────────────────────────────────────────┘
                              ↑        ↓
                   call methods / return data
                              │        │
┌──────────────────────────────────────────────────────────────────────┐
│              DATA SOURCES LAYER (Services)                            │
│  ┌──────────────────┐  ┌──────────────────┐  ┌─────────────────┐   │
│  │ AuthService      │  │ ItemService      │  │ UserService     │   │
│  │ (Supabase Auth)  │  │ (Items CRUD)     │  │ (Users CRUD)    │   │
│  └──────────────────┘  └──────────────────┘  └─────────────────┘   │
│  ┌──────────────────┐  ┌──────────────────┐                        │
│  │ FavoriteService  │  │ SupabaseService  │                        │
│  │ (Favorites CRUD) │  │ (Client Singleton)                        │
│  └──────────────────┘  └──────────────────┘                        │
└──────────────────────────────────────────────────────────────────────┘
                              ↑        ↓
                   REST/Real-time queries
                              │        │
┌──────────────────────────────────────────────────────────────────────┐
│                        SUPABASE BACKEND                               │
│  ┌────────────────────────────────────────────────────────────┐      │
│  │  PostgreSQL Database                                       │      │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────────┐             │      │
│  │  │  users   │  │  items   │  │  favorites   │             │      │
│  │  │ (100 MB) │  │ (200 MB) │  │ (50 MB)      │             │      │
│  │  └──────────┘  └──────────┘  └──────────────┘             │      │
│  └────────────────────────────────────────────────────────────┘      │
│  ┌────────────────────────────────────────────────────────────┐      │
│  │  Authentication (Supabase Auth)                            │      │
│  │  - Email/Password login & registration                     │      │
│  │  - Session management                                      │      │
│  └────────────────────────────────────────────────────────────┘      │
│  ┌────────────────────────────────────────────────────────────┐      │
│  │  Storage (Supabase Storage)                                │      │
│  │  - /item-images/ (product photos)                          │      │
│  │  - /user-images/ (profile pictures)                        │      │
│  └────────────────────────────────────────────────────────────┘      │
└──────────────────────────────────────────────────────────────────────┘
```

---

### Data Flow: Complete Example (User Posts Item + Favorites It)

```
TIMELINE: User creates listing and favorites it

T=0ms   User fills form on AddListingScreen
        ├─ Title: "PS5 Bundle"
        ├─ Price: 450
        ├─ Category: Consoles
        ├─ Image: selected from device
        └─ Type: sell

T=10ms  User taps "Post Listing"
        └─ Validation passes ✓

T=20ms  Image upload starts
        ├─ ItemRepository.uploadItemImage(imageFile)
        └─ Generate filename: item_1733000000020.jpg

T=50ms  Supabase Storage responds
        └─ Public URL returned

T=100ms CREATE item in database
        ├─ ItemRepository.createItem(itemModel)
        ├─ ItemService.createItem()
        └─ INSERT INTO items (...)

T=150ms Supabase responds with created item
        ├─ New itemId: 999
        ├─ ItemCubit.state updates
        └─ UI shows success message

T=160ms Navigate back to HomeScreen
        ├─ ItemCubit.loadAllItems()
        └─ Reload all items (now includes new item)

T=200ms Home screen loaded
        ├─ User sees new "PS5 Bundle" in grid
        └─ Heart icon is grey (not favorited)

T=210ms User taps heart icon on new item
        ├─ _toggleFavorite(999) called
        ├─ Check: is item 999 in FavoriteCubit.myFavorites?
        │   → NO (not in favorites)
        └─ ADD to favorites

T=220ms FavoriteCubit.addFavorite(999, userId)
        ├─ FavoriteRepository.addFavorite(999, userId)
        ├─ FavoriteService.addFavorite()
        └─ INSERT INTO favorites (userid, itemid)

T=250ms Supabase responds: favorite added ✓
        ├─ FavoriteCubit.state updates
        └─ Heart icon turns purple

T=260ms User views Profile Screen
        ├─ ProfileCubit.loadProfile()
        ├─ Fetch user's listings (includes new item)
        ├─ Fetch user's favorites (includes item 999)
        └─ Show in both tabs
```

---

## 🔄 7. NAVIGATION FLOW

### Navigation Routes

**Authentication Flow:**
```
SplashScreen
    ↓ "Get Started"
LoginScreen ←→ RegisterScreen
    ↓ (Login successful)
HomeScreen
```

**Main App Navigation (Bottom Navigation Bar):**
```
HomeScreen (Default)
    ↑ ↓
ProfileScreen (Profile Tab)
    ↑ ↓
AddListingScreen (+ Tab)
```

**Modal Navigation (from main screens):**
```
HomeScreen
  ├─ Tap item card → ProductPage Screen
  ├─ Tap heart → favorite toggle (stays on screen)
  └─ Tap + → AddListingScreen

ProductPage
  ├─ Tap "Contact Seller" → ContactSeller Screen
  ├─ Tap edit → EditItem Screen
  └─ Tap back → return to HomeScreen

ProfileScreen
  ├─ Tap "Edit Profile" → EditProfile Screen
  ├─ Tap item → ProductPage Screen
  ├─ Tap edit on listing → EditItem Screen
  └─ Tap "Logout" → LoginScreen
```

---

## 🚀 8. DEPENDENCIES & PACKAGES

**Key Packages (from `pubspec.yaml`):**

```yaml
flutter_bloc: ^8.1.3
  # State management
  # Provides Cubit, BlocBuilder, BlocListener, etc.

supabase_flutter: ^2.10.3
  # Backend as a Service (BaaS)
  # Database, Authentication, Storage
  # Real-time updates

flutter_dotenv: ^5.1.0
  # Load environment variables from .env file
  # For storing API keys securely

image_picker: ^1.0.7
  # Pick images from device camera or gallery

url_launcher: ^6.2.5
  # Open URLs, phone calls, emails
  # Used for contacting seller (WhatsApp, phone, email)

equatable: ^2.0.5
  # Simplify equality comparison
  # Used in state classes
```

---

## ✅ SUMMARY

The **RePlay** app is a well-structured Flutter application using:

1. **Architecture:** Cubit + Repository + Service pattern
2. **UI:** 8 main screens with bottom navigation + modals
3. **State:** 4 Cubits managing auth, items, profile, favorites
4. **Backend:** Supabase for database, auth, and storage
5. **Features:** Browse items, add listings, search/filter, favorites, contact sellers

The three-layer architecture (UI → Logic → Data) provides:
- **Separation of concerns:** Each layer has a specific responsibility
- **Reusability:** Services, repositories, and cubits can be reused
- **Testability:** Easy to write unit/widget tests
- **Scalability:** Easy to add new features or modify existing ones
- **Maintainability:** Clear code organization and flow

---

**End of Documentation**
