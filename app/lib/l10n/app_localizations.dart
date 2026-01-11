import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'RePlay'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Unlock Your Gaming Universe'**
  String get appTagline;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @marketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone number (optional)'**
  String get phoneOptional;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account is a permanent action and cannot be undone.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @addListing.
  ///
  /// In en, this message translates to:
  /// **'Add Listing'**
  String get addListing;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @itemDetails.
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get itemDetails;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @listingType.
  ///
  /// In en, this message translates to:
  /// **'Listing Type'**
  String get listingType;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @submitListing.
  ///
  /// In en, this message translates to:
  /// **'Submit Listing'**
  String get submitListing;

  /// No description provided for @rent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rent;

  /// No description provided for @trade.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get trade;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @contactSeller.
  ///
  /// In en, this message translates to:
  /// **'Contact seller'**
  String get contactSeller;

  /// No description provided for @contactOptions.
  ///
  /// In en, this message translates to:
  /// **'Contact Options'**
  String get contactOptions;

  /// No description provided for @messageSeller.
  ///
  /// In en, this message translates to:
  /// **'Message Seller'**
  String get messageSeller;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @invalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get invalidPrice;

  /// No description provided for @priceMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Price must be greater than 0'**
  String get priceMustBePositive;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterTitle;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get pleaseEnterUsername;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get invalidPhoneNumber;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully!'**
  String get changesSaved;

  /// No description provided for @listingSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Listing submitted successfully!'**
  String get listingSubmitted;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deletion requested!'**
  String get accountDeleted;

  /// No description provided for @listingCreated.
  ///
  /// In en, this message translates to:
  /// **'Listing created successfully!'**
  String get listingCreated;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreated;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdated;

  /// No description provided for @imageUploaded.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded successfully!'**
  String get imageUploaded;

  /// No description provided for @imageSelected.
  ///
  /// In en, this message translates to:
  /// **'Image selected. Click Save Changes to upload.'**
  String get imageSelected;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search for games or accessories...'**
  String get searchPlaceholder;

  /// No description provided for @titlePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g., God of War Ragnarök (PS5)'**
  String get titlePlaceholder;

  /// No description provided for @descriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe your item, including condition, version, and any extras.'**
  String get descriptionPlaceholder;

  /// No description provided for @platformPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g., PS5, Xbox, Nintendo Switch'**
  String get platformPlaceholder;

  /// No description provided for @urlPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'https://example.com/image.jpg'**
  String get urlPlaceholder;

  /// No description provided for @enterItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter item title'**
  String get enterItemTitle;

  /// No description provided for @describeYourItem.
  ///
  /// In en, this message translates to:
  /// **'Describe your item...'**
  String get describeYourItem;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListings;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @noListings.
  ///
  /// In en, this message translates to:
  /// **'No listings yet'**
  String get noListings;

  /// No description provided for @startAddingItems.
  ///
  /// In en, this message translates to:
  /// **'Start adding items to sell, rent or trade'**
  String get startAddingItems;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @startFavoritingItems.
  ///
  /// In en, this message translates to:
  /// **'Start favoriting items you like'**
  String get startFavoritingItems;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @consoles.
  ///
  /// In en, this message translates to:
  /// **'Consoles'**
  String get consoles;

  /// No description provided for @accessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get accessories;

  /// No description provided for @electronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get electronics;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get noDescription;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the Gaming Community'**
  String get registerSubtitle;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or category'**
  String get tryDifferentSearch;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'UNAVAILABLE'**
  String get unavailable;

  /// No description provided for @pleaseLoginToFavorite.
  ///
  /// In en, this message translates to:
  /// **'Please log in to add favorites'**
  String get pleaseLoginToFavorite;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading seller information'**
  String get errorLoadingData;

  /// No description provided for @sellerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Seller not found'**
  String get sellerNotFound;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @productImage.
  ///
  /// In en, this message translates to:
  /// **'Product Image'**
  String get productImage;

  /// No description provided for @itemImage.
  ///
  /// In en, this message translates to:
  /// **'Item Image'**
  String get itemImage;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @url.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get url;

  /// No description provided for @tapToAddImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to add image'**
  String get tapToAddImage;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImage;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @platformOptional.
  ///
  /// In en, this message translates to:
  /// **'Platform (optional)'**
  String get platformOptional;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItem;

  /// No description provided for @deleteItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteItemConfirm;

  /// No description provided for @itemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted successfully'**
  String get itemDeleted;

  /// No description provided for @itemUpdated.
  ///
  /// In en, this message translates to:
  /// **'Item updated successfully'**
  String get itemUpdated;

  /// No description provided for @loadingSellerInfo.
  ///
  /// In en, this message translates to:
  /// **'Loading seller info...'**
  String get loadingSellerInfo;

  /// No description provided for @phoneNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Phone number not available'**
  String get phoneNotAvailable;

  /// No description provided for @emailNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Email not available'**
  String get emailNotAvailable;

  /// No description provided for @couldNotOpenPhoneDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not open phone dialer'**
  String get couldNotOpenPhoneDialer;

  /// No description provided for @couldNotOpenEmailClient.
  ///
  /// In en, this message translates to:
  /// **'Could not open email client'**
  String get couldNotOpenEmailClient;

  /// No description provided for @couldNotOpenWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp'**
  String get couldNotOpenWhatsApp;

  /// No description provided for @phoneNotAvailableForWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Phone number not available for WhatsApp'**
  String get phoneNotAvailableForWhatsApp;

  /// No description provided for @whatsAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi! I found your listing on RePlay and I\'m interested.'**
  String get whatsAppMessage;

  /// No description provided for @inquiryFromRePlay.
  ///
  /// In en, this message translates to:
  /// **'Inquiry from RePlay App'**
  String get inquiryFromRePlay;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendVerificationEmail;

  /// No description provided for @emailAlreadyVerified.
  ///
  /// In en, this message translates to:
  /// **'Email already verified'**
  String get emailAlreadyVerified;

  /// No description provided for @youMustBeLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in'**
  String get youMustBeLoggedIn;

  /// No description provided for @sendingVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Sending verification email...'**
  String get sendingVerificationEmail;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent to {email}'**
  String verificationEmailSent(String email);

  /// No description provided for @errorLoggingOut.
  ///
  /// In en, this message translates to:
  /// **'Error logging out: {error}'**
  String errorLoggingOut(String error);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @usernameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty'**
  String get usernameCannotBeEmpty;

  /// No description provided for @failedToUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image'**
  String get failedToUploadImage;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @enterImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter Image URL'**
  String get enterImageUrl;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Photo'**
  String get changeProfilePhoto;

  /// No description provided for @pricePerRent.
  ///
  /// In en, this message translates to:
  /// **'DZD{price}/rent'**
  String pricePerRent(int price);

  /// No description provided for @priceAmount.
  ///
  /// In en, this message translates to:
  /// **'DZD{price}'**
  String priceAmount(int price);

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @emailAction.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailAction;

  /// No description provided for @whatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsApp;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Listing Type'**
  String get type;

  /// No description provided for @platform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// No description provided for @platformHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., PS5, Xbox, Nintendo Switch'**
  String get platformHint;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit Listing'**
  String get submit;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get pleaseEnterDescription;

  /// No description provided for @pleaseEnterPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a price'**
  String get pleaseEnterPrice;

  /// No description provided for @pleaseEnterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get pleaseEnterValidPrice;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhone;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @listingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Listing created successfully!'**
  String get listingSuccess;

  /// No description provided for @listingError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create listing. Please try again.'**
  String get listingError;

  /// No description provided for @listingCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Listing created successfully!'**
  String get listingCreatedSuccess;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreatedSuccess;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Unlock Your Gaming Universe'**
  String get tagline;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for games or accessories...'**
  String get searchHint;

  /// No description provided for @pricePerDay.
  ///
  /// In en, this message translates to:
  /// **'\${price}/day'**
  String pricePerDay(int price);

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @mustBeLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in'**
  String get mustBeLoggedIn;

  /// No description provided for @verificationEmailSentTo.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent to {email}'**
  String verificationEmailSentTo(String email);

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @editListing.
  ///
  /// In en, this message translates to:
  /// **'Edit Listing'**
  String get editListing;

  /// No description provided for @deleteListing.
  ///
  /// In en, this message translates to:
  /// **'Delete Listing'**
  String get deleteListing;

  /// No description provided for @deleteListingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"? This action cannot be undone.'**
  String deleteListingConfirmation(String title);

  /// No description provided for @listingDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Listing deleted successfully'**
  String get listingDeletedSuccess;

  /// No description provided for @failedToDeleteListing.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete listing'**
  String get failedToDeleteListing;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @selectImageSource.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSource;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// No description provided for @pleaseSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Please select an image'**
  String get pleaseSelectImage;

  /// No description provided for @failedToUpdateItem.
  ///
  /// In en, this message translates to:
  /// **'Failed to update item'**
  String get failedToUpdateItem;

  /// No description provided for @failedToDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete item'**
  String get failedToDeleteItem;

  /// No description provided for @deleteItemConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteItemConfirmation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
