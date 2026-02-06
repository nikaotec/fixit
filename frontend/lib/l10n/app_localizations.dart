import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

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
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FixIt MVP'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @ordersTab.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTab;

  /// No description provided for @inventoryTab.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventoryTab;

  /// No description provided for @notificationsTab.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get notificationsTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @equipmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipmentLabel;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCode;

  /// No description provided for @checklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checklistTitle;

  /// No description provided for @signatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get signatureLabel;

  /// No description provided for @submitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @statusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get statusOpen;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get statusFinished;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @securityPassword.
  ///
  /// In en, this message translates to:
  /// **'Security & Password'**
  String get securityPassword;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @maintenancePro.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Pro'**
  String get maintenancePro;

  /// No description provided for @allSystemsNormal.
  ///
  /// In en, this message translates to:
  /// **'All systems normal'**
  String get allSystemsNormal;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get newOrder;

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @recentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent Orders'**
  String get recentOrders;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search orders, assets...'**
  String get searchPlaceholder;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @createEquipment.
  ///
  /// In en, this message translates to:
  /// **'Create Equipment'**
  String get createEquipment;

  /// No description provided for @createChecklist.
  ///
  /// In en, this message translates to:
  /// **'Create Checklist'**
  String get createChecklist;

  /// No description provided for @mainDashboard.
  ///
  /// In en, this message translates to:
  /// **'Main Dashboard'**
  String get mainDashboard;

  /// No description provided for @createNewClient.
  ///
  /// In en, this message translates to:
  /// **'Create New Client'**
  String get createNewClient;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @corporate.
  ///
  /// In en, this message translates to:
  /// **'Corporate'**
  String get corporate;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name / Company Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. John Doe or Acme Corp'**
  String get fullNameHint;

  /// No description provided for @taxId.
  ///
  /// In en, this message translates to:
  /// **'Tax ID (CPF / CNPJ)'**
  String get taxId;

  /// No description provided for @taxIdHint.
  ///
  /// In en, this message translates to:
  /// **'000.000.000-00'**
  String get taxIdHint;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'client@email.com'**
  String get emailHint;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+55 (11) 99999-9999'**
  String get phoneHint;

  /// No description provided for @locationDetails.
  ///
  /// In en, this message translates to:
  /// **'Location Details'**
  String get locationDetails;

  /// No description provided for @zipCode.
  ///
  /// In en, this message translates to:
  /// **'ZIP Code (CEP)'**
  String get zipCode;

  /// No description provided for @zipCodeHint.
  ///
  /// In en, this message translates to:
  /// **'00000-000'**
  String get zipCodeHint;

  /// No description provided for @lookup.
  ///
  /// In en, this message translates to:
  /// **'Lookup'**
  String get lookup;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @streetHint.
  ///
  /// In en, this message translates to:
  /// **'Main St'**
  String get streetHint;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get number;

  /// No description provided for @numberHint.
  ///
  /// In en, this message translates to:
  /// **'123'**
  String get numberHint;

  /// No description provided for @neighborhood.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood'**
  String get neighborhood;

  /// No description provided for @neighborhoodHint.
  ///
  /// In en, this message translates to:
  /// **'Downtown'**
  String get neighborhoodHint;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @cityHint.
  ///
  /// In en, this message translates to:
  /// **'San Francisco'**
  String get cityHint;

  /// No description provided for @primaryContact.
  ///
  /// In en, this message translates to:
  /// **'Primary Contact'**
  String get primaryContact;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'OPTIONAL'**
  String get optional;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get contactName;

  /// No description provided for @contactNameHint.
  ///
  /// In en, this message translates to:
  /// **'Person to talk to'**
  String get contactNameHint;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position / Role'**
  String get position;

  /// No description provided for @positionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Manager, Owner'**
  String get positionHint;

  /// No description provided for @internalNotes.
  ///
  /// In en, this message translates to:
  /// **'Internal Notes'**
  String get internalNotes;

  /// No description provided for @internalNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add specific instructions or history about this client...'**
  String get internalNotesHint;

  /// No description provided for @saveClient.
  ///
  /// In en, this message translates to:
  /// **'Save Client'**
  String get saveClient;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// No description provided for @searchClients.
  ///
  /// In en, this message translates to:
  /// **'Search by name or tax ID'**
  String get searchClients;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @addClient.
  ///
  /// In en, this message translates to:
  /// **'Add Client'**
  String get addClient;

  /// No description provided for @noClientsFound.
  ///
  /// In en, this message translates to:
  /// **'No clients found'**
  String get noClientsFound;

  /// No description provided for @noClientsMessage.
  ///
  /// In en, this message translates to:
  /// **'Your client list is empty. Start adding your first individual or corporate client to manage their equipment and service orders.'**
  String get noClientsMessage;

  /// No description provided for @addFirstClient.
  ///
  /// In en, this message translates to:
  /// **'Add First Client'**
  String get addFirstClient;

  /// No description provided for @addEquipment.
  ///
  /// In en, this message translates to:
  /// **'Add Equipment'**
  String get addEquipment;

  /// No description provided for @editEquipment.
  ///
  /// In en, this message translates to:
  /// **'Edit Equipment'**
  String get editEquipment;

  /// No description provided for @equipmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Equipment Details'**
  String get equipmentDetails;

  /// No description provided for @equipmentDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register a new asset to the Fixit database.'**
  String get equipmentDetailsSubtitle;

  /// No description provided for @equipmentName.
  ///
  /// In en, this message translates to:
  /// **'Equipment Name'**
  String get equipmentName;

  /// No description provided for @equipmentNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Industrial HVAC Unit 01'**
  String get equipmentNameHint;

  /// No description provided for @serialCode.
  ///
  /// In en, this message translates to:
  /// **'Serial Code'**
  String get serialCode;

  /// No description provided for @serialCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. SN-99234-XYZ'**
  String get serialCodeHint;

  /// No description provided for @clientLocation.
  ///
  /// In en, this message translates to:
  /// **'Client / Location'**
  String get clientLocation;

  /// No description provided for @selectClient.
  ///
  /// In en, this message translates to:
  /// **'Select Client'**
  String get selectClient;

  /// No description provided for @geoCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Geographic Coordinates'**
  String get geoCoordinates;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get useCurrentLocation;

  /// No description provided for @uniqueQrLabel.
  ///
  /// In en, this message translates to:
  /// **'Unique QR Label'**
  String get uniqueQrLabel;

  /// No description provided for @generateQr.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generateQr;

  /// No description provided for @instantTechAccess.
  ///
  /// In en, this message translates to:
  /// **'Generate for instant tech access'**
  String get instantTechAccess;

  /// No description provided for @saveEquipment.
  ///
  /// In en, this message translates to:
  /// **'Save Equipment'**
  String get saveEquipment;

  /// No description provided for @equipmentNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter equipment name'**
  String get equipmentNameRequired;

  /// No description provided for @qrCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrCodeTitle;

  /// No description provided for @qrCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Equipment label: {name}'**
  String qrCodeSubtitle(Object name);

  /// No description provided for @shareQrCode.
  ///
  /// In en, this message translates to:
  /// **'Share QR Code'**
  String get shareQrCode;

  /// No description provided for @printQrCode.
  ///
  /// In en, this message translates to:
  /// **'Print QR Code'**
  String get printQrCode;

  /// No description provided for @errorSharingQrCode.
  ///
  /// In en, this message translates to:
  /// **'Unable to share the QR Code.'**
  String get errorSharingQrCode;

  /// No description provided for @errorPrintingQrCode.
  ///
  /// In en, this message translates to:
  /// **'Unable to print the QR Code.'**
  String get errorPrintingQrCode;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @equipmentNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Equipment: {name}'**
  String equipmentNameLabel(Object name);

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionsDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are denied.'**
  String get locationPermissionsDenied;

  /// No description provided for @locationPermissionsDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied, we cannot request permissions.'**
  String get locationPermissionsDeniedForever;

  /// No description provided for @errorGettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Error getting location: {error}'**
  String errorGettingLocation(Object error);

  /// No description provided for @errorSavingEquipment.
  ///
  /// In en, this message translates to:
  /// **'Error saving equipment: {error}'**
  String errorSavingEquipment(Object error);

  /// No description provided for @deleteEquipmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Equipment?'**
  String get deleteEquipmentTitle;

  /// No description provided for @deleteEquipmentBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this equipment? This action cannot be undone.'**
  String get deleteEquipmentBody;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @errorDeletingEquipment.
  ///
  /// In en, this message translates to:
  /// **'Error deleting: {error}'**
  String errorDeletingEquipment(Object error);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @equipmentInventory.
  ///
  /// In en, this message translates to:
  /// **'Equipment Inventory'**
  String get equipmentInventory;

  /// No description provided for @searchEquipmentPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by name or serial...'**
  String get searchEquipmentPlaceholder;

  /// No description provided for @byClient.
  ///
  /// In en, this message translates to:
  /// **'By Client'**
  String get byClient;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @itemsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} items found'**
  String itemsFound(int count);

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @serviceOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Orders'**
  String get serviceOrdersTitle;

  /// No description provided for @searchOrdersPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search orders'**
  String get searchOrdersPlaceholder;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @locationNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Location not specified'**
  String get locationNotSpecified;

  /// No description provided for @noSchedule.
  ///
  /// In en, this message translates to:
  /// **'No schedule'**
  String get noSchedule;

  /// No description provided for @orderDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetailsTitle;

  /// No description provided for @startMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Start Maintenance'**
  String get startMaintenance;

  /// No description provided for @clientAndLocation.
  ///
  /// In en, this message translates to:
  /// **'Client & Location'**
  String get clientAndLocation;

  /// No description provided for @assignedChecklist.
  ///
  /// In en, this message translates to:
  /// **'Assigned Checklist'**
  String get assignedChecklist;

  /// No description provided for @checklistNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'Checklist not assigned'**
  String get checklistNotAssigned;

  /// No description provided for @assignedTechnician.
  ///
  /// In en, this message translates to:
  /// **'Assigned Technician'**
  String get assignedTechnician;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @reassign.
  ///
  /// In en, this message translates to:
  /// **'Reassign'**
  String get reassign;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created by {name}'**
  String createdBy(Object name);

  /// No description provided for @roleCreator.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get roleCreator;

  /// No description provided for @roleResponsible.
  ///
  /// In en, this message translates to:
  /// **'Responsible'**
  String get roleResponsible;

  /// No description provided for @roleCreatorResponsible.
  ///
  /// In en, this message translates to:
  /// **'Creator and responsible'**
  String get roleCreatorResponsible;

  /// No description provided for @checklistTemplates.
  ///
  /// In en, this message translates to:
  /// **'Checklist Templates'**
  String get checklistTemplates;

  /// No description provided for @techniciansLabel.
  ///
  /// In en, this message translates to:
  /// **'Technicians'**
  String get techniciansLabel;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @passwordMin6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMin6;

  /// No description provided for @noAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountQuestion;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @englishLabel.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLabel;

  /// No description provided for @portugueseLabel.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portugueseLabel;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Password reset is managed by your administrator for now. Contact your manager to reset your credentials.'**
  String get forgotPasswordBody;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get registerTitle;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordLabelText.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabelText;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get passwordHint;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get passwordRequired;

  /// No description provided for @passwordMin8.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMin8;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get confirmPasswordHint;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @initialLanguage.
  ///
  /// In en, this message translates to:
  /// **'Initial Language'**
  String get initialLanguage;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @termsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to our '**
  String get termsPrefix;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @andConjunction.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get andConjunction;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @orderDetailsHeading.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetailsHeading;

  /// No description provided for @orderTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Order type'**
  String get orderTypeLabel;

  /// No description provided for @orderTypeMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get orderTypeMaintenance;

  /// No description provided for @orderTypeRepair.
  ///
  /// In en, this message translates to:
  /// **'Repair'**
  String get orderTypeRepair;

  /// No description provided for @orderTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get orderTypeOther;

  /// No description provided for @problemDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Problem description'**
  String get problemDescriptionLabel;

  /// No description provided for @problemDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem to be fixed'**
  String get problemDescriptionHint;

  /// No description provided for @problemDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please describe the problem'**
  String get problemDescriptionRequired;

  /// No description provided for @problemDescriptionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No problem description provided'**
  String get problemDescriptionEmpty;

  /// No description provided for @brandLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brandLabel;

  /// No description provided for @modelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get modelLabel;

  /// No description provided for @brandRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the brand'**
  String get brandRequired;

  /// No description provided for @modelRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the model'**
  String get modelRequired;

  /// No description provided for @voiceInput.
  ///
  /// In en, this message translates to:
  /// **'Voice input'**
  String get voiceInput;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @transcribing.
  ///
  /// In en, this message translates to:
  /// **'Transcribing'**
  String get transcribing;

  /// No description provided for @portugueseBrazil.
  ///
  /// In en, this message translates to:
  /// **'Portuguese (BR)'**
  String get portugueseBrazil;

  /// No description provided for @englishUS.
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get englishUS;

  /// No description provided for @voiceNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Voice input not available'**
  String get voiceNotAvailable;

  /// No description provided for @stopListening.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopListening;

  /// No description provided for @selectEquipmentChecklist.
  ///
  /// In en, this message translates to:
  /// **'Select equipment and checklist'**
  String get selectEquipmentChecklist;

  /// No description provided for @orderCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order created successfully'**
  String get orderCreatedSuccess;

  /// No description provided for @userNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get userNotAuthenticated;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String errorLoadingData(Object error);

  /// No description provided for @errorCreatingOrder.
  ///
  /// In en, this message translates to:
  /// **'Error creating order: {error}'**
  String errorCreatingOrder(Object error);

  /// No description provided for @serverRejectedTechnician.
  ///
  /// In en, this message translates to:
  /// **'The server did not accept the selected technician'**
  String get serverRejectedTechnician;

  /// No description provided for @scheduledDate.
  ///
  /// In en, this message translates to:
  /// **'Scheduled date'**
  String get scheduledDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @createOrder.
  ///
  /// In en, this message translates to:
  /// **'Create Order'**
  String get createOrder;

  /// No description provided for @responsibleTechnician.
  ///
  /// In en, this message translates to:
  /// **'Responsible technician'**
  String get responsibleTechnician;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityLabel;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @doNotAssignNow.
  ///
  /// In en, this message translates to:
  /// **'Do not assign now'**
  String get doNotAssignNow;

  /// No description provided for @meLabel.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get meLabel;

  /// No description provided for @meWithName.
  ///
  /// In en, this message translates to:
  /// **'Me ({name})'**
  String meWithName(Object name);

  /// No description provided for @meUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Me (unavailable)'**
  String get meUnavailable;

  /// No description provided for @recentOrdersError.
  ///
  /// In en, this message translates to:
  /// **'Error loading recent orders'**
  String get recentOrdersError;

  /// No description provided for @noRecentOrders.
  ///
  /// In en, this message translates to:
  /// **'No recent orders'**
  String get noRecentOrders;

  /// No description provided for @createServiceOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Service Order'**
  String get createServiceOrderTitle;

  /// No description provided for @ordersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading orders'**
  String get ordersLoadError;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get noOrdersFound;
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
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
