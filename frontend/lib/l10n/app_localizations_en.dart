// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FixIt MVP';

  @override
  String get loginTitle => 'Login';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get ordersTab => 'Orders';

  @override
  String get inventoryTab => 'Inventory';

  @override
  String get notificationsTab => 'Alerts';

  @override
  String get profileTab => 'Profile';

  @override
  String get settingsTab => 'Settings';

  @override
  String get equipmentLabel => 'Equipment';

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get checklistTitle => 'Checklist';

  @override
  String get signatureLabel => 'Signature';

  @override
  String get submitButton => 'Submit';

  @override
  String get languageLabel => 'Language';

  @override
  String get logoutButton => 'Logout';

  @override
  String get statusOpen => 'Open';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusFinished => 'Finished';

  @override
  String get profileTitle => 'Profile';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get securityPassword => 'Security & Password';

  @override
  String get preferences => 'Preferences';

  @override
  String get notifications => 'Notifications';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get maintenancePro => 'Maintenance Pro';

  @override
  String get allSystemsNormal => 'All systems normal';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get newOrder => 'New Order';

  @override
  String get assets => 'Assets';

  @override
  String get reports => 'Reports';

  @override
  String get recentOrders => 'Recent Orders';

  @override
  String get viewAll => 'View All';

  @override
  String get home => 'Home';

  @override
  String get searchPlaceholder => 'Search orders, assets...';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get createEquipment => 'Create Equipment';

  @override
  String get createChecklist => 'Create Checklist';

  @override
  String get mainDashboard => 'Main Dashboard';

  @override
  String get createNewClient => 'Create New Client';

  @override
  String get cancel => 'Cancel';

  @override
  String get individual => 'Individual';

  @override
  String get corporate => 'Corporate';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get fullName => 'Full Name / Company Name';

  @override
  String get fullNameHint => 'e.g. John Doe or Acme Corp';

  @override
  String get taxId => 'Tax ID (CPF / CNPJ)';

  @override
  String get taxIdHint => '000.000.000-00';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get emailHint => 'client@email.com';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneHint => '+55 (11) 99999-9999';

  @override
  String get locationDetails => 'Location Details';

  @override
  String get zipCode => 'ZIP Code (CEP)';

  @override
  String get zipCodeHint => '00000-000';

  @override
  String get lookup => 'Lookup';

  @override
  String get street => 'Street';

  @override
  String get streetHint => 'Main St';

  @override
  String get number => 'No.';

  @override
  String get numberHint => '123';

  @override
  String get neighborhood => 'Neighborhood';

  @override
  String get neighborhoodHint => 'Downtown';

  @override
  String get city => 'City';

  @override
  String get cityHint => 'San Francisco';

  @override
  String get primaryContact => 'Primary Contact';

  @override
  String get optional => 'OPTIONAL';

  @override
  String get contactName => 'Contact Name';

  @override
  String get contactNameHint => 'Person to talk to';

  @override
  String get position => 'Position / Role';

  @override
  String get positionHint => 'e.g. Manager, Owner';

  @override
  String get internalNotes => 'Internal Notes';

  @override
  String get internalNotesHint =>
      'Add specific instructions or history about this client...';

  @override
  String get saveClient => 'Save Client';

  @override
  String get clients => 'Clients';

  @override
  String get searchClients => 'Search by name or tax ID';

  @override
  String get all => 'All';

  @override
  String get active => 'Active';

  @override
  String get region => 'Region';

  @override
  String get overdue => 'Overdue';

  @override
  String get addClient => 'Add Client';

  @override
  String get noClientsFound => 'No clients found';

  @override
  String get noClientsMessage =>
      'Your client list is empty. Start adding your first individual or corporate client to manage their equipment and service orders.';

  @override
  String get addFirstClient => 'Add First Client';

  @override
  String get addEquipment => 'Add Equipment';

  @override
  String get editEquipment => 'Edit Equipment';

  @override
  String get equipmentDetails => 'Equipment Details';

  @override
  String get equipmentDetailsSubtitle =>
      'Register a new asset to the Fixit database.';

  @override
  String get equipmentName => 'Equipment Name';

  @override
  String get equipmentNameHint => 'e.g. Industrial HVAC Unit 01';

  @override
  String get serialCode => 'Serial Code';

  @override
  String get serialCodeHint => 'e.g. SN-99234-XYZ';

  @override
  String get clientLocation => 'Client / Location';

  @override
  String get selectClient => 'Select Client';

  @override
  String get geoCoordinates => 'Geographic Coordinates';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get useCurrentLocation => 'Use my current location';

  @override
  String get uniqueQrLabel => 'Unique QR Label';

  @override
  String get generateQr => 'Generate';

  @override
  String get instantTechAccess => 'Generate for instant tech access';

  @override
  String get saveEquipment => 'Save Equipment';

  @override
  String get equipmentNameRequired => 'Please enter equipment name';

  @override
  String get qrCodeTitle => 'QR Code';

  @override
  String qrCodeSubtitle(Object name) {
    return 'Equipment label: $name';
  }

  @override
  String get shareQrCode => 'Share QR Code';

  @override
  String get printQrCode => 'Print QR Code';

  @override
  String get errorSharingQrCode => 'Unable to share the QR Code.';

  @override
  String get errorPrintingQrCode => 'Unable to print the QR Code.';

  @override
  String get ok => 'OK';

  @override
  String equipmentNameLabel(Object name) {
    return 'Equipment: $name';
  }

  @override
  String get locationServicesDisabled => 'Location services are disabled.';

  @override
  String get locationPermissionsDenied => 'Location permissions are denied.';

  @override
  String get locationPermissionsDeniedForever =>
      'Location permissions are permanently denied, we cannot request permissions.';

  @override
  String errorGettingLocation(Object error) {
    return 'Error getting location: $error';
  }

  @override
  String errorSavingEquipment(Object error) {
    return 'Error saving equipment: $error';
  }

  @override
  String get deleteEquipmentTitle => 'Delete Equipment?';

  @override
  String get deleteEquipmentBody =>
      'Are you sure you want to delete this equipment? This action cannot be undone.';

  @override
  String get deleteAction => 'Delete';

  @override
  String errorDeletingEquipment(Object error) {
    return 'Error deleting: $error';
  }

  @override
  String get save => 'Save';

  @override
  String get equipmentInventory => 'Equipment Inventory';

  @override
  String get searchEquipmentPlaceholder => 'Search by name or serial...';

  @override
  String get byClient => 'By Client';

  @override
  String get category => 'Category';

  @override
  String get status => 'Status';

  @override
  String itemsFound(int count) {
    return '$count items found';
  }

  @override
  String get ordersTitle => 'Orders';

  @override
  String get serviceOrdersTitle => 'Service Orders';

  @override
  String get searchOrdersPlaceholder => 'Search orders';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get locationNotSpecified => 'Location not specified';

  @override
  String get noSchedule => 'No schedule';

  @override
  String get orderDetailsTitle => 'Order Details';

  @override
  String get startMaintenance => 'Start Maintenance';

  @override
  String get clientAndLocation => 'Client & Location';

  @override
  String get assignedChecklist => 'Assigned Checklist';

  @override
  String get checklistNotAssigned => 'Checklist not assigned';

  @override
  String get assignedTechnician => 'Assigned Technician';

  @override
  String get unassigned => 'Unassigned';

  @override
  String get reassign => 'Reassign';

  @override
  String createdBy(Object name) {
    return 'Created by $name';
  }

  @override
  String get roleCreator => 'Creator';

  @override
  String get roleResponsible => 'Responsible';

  @override
  String get roleCreatorResponsible => 'Creator and responsible';

  @override
  String get checklistTemplates => 'Checklist Templates';

  @override
  String get techniciansLabel => 'Technicians';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get passwordMin6 => 'Password must be at least 6 characters';

  @override
  String get noAccountQuestion => 'Don\'t have an account?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get englishLabel => 'English';

  @override
  String get portugueseLabel => 'Portuguese';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordBody =>
      'Password reset is managed by your administrator for now. Contact your manager to reset your credentials.';

  @override
  String get registerTitle => 'Create Your Account';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordLabelText => 'Password';

  @override
  String get passwordHint => 'Create a password';

  @override
  String get passwordRequired => 'Please enter a password';

  @override
  String get passwordMin8 => 'Password must be at least 8 characters';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Repeat your password';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get initialLanguage => 'Initial Language';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get logIn => 'Log in';

  @override
  String get termsPrefix => 'By creating an account, you agree to our ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get andConjunction => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get orderDetailsHeading => 'Order Details';

  @override
  String get orderTypeLabel => 'Order type';

  @override
  String get orderTypeMaintenance => 'Maintenance';

  @override
  String get orderTypeRepair => 'Repair';

  @override
  String get orderTypeOther => 'Other';

  @override
  String get problemDescriptionLabel => 'Problem description';

  @override
  String get problemDescriptionHint => 'Describe the problem to be fixed';

  @override
  String get problemDescriptionRequired => 'Please describe the problem';

  @override
  String get problemDescriptionEmpty => 'No problem description provided';

  @override
  String get brandLabel => 'Brand';

  @override
  String get modelLabel => 'Model';

  @override
  String get brandRequired => 'Please enter the brand';

  @override
  String get modelRequired => 'Please enter the model';

  @override
  String get voiceInput => 'Voice input';

  @override
  String get listening => 'Listening...';

  @override
  String get transcribing => 'Transcribing';

  @override
  String get portugueseBrazil => 'Portuguese (BR)';

  @override
  String get englishUS => 'English (US)';

  @override
  String get voiceNotAvailable => 'Voice input not available';

  @override
  String get stopListening => 'Stop';

  @override
  String get selectEquipmentChecklist => 'Select equipment and checklist';

  @override
  String get orderCreatedSuccess => 'Order created successfully';

  @override
  String get userNotAuthenticated => 'User not authenticated';

  @override
  String errorLoadingData(Object error) {
    return 'Error loading data: $error';
  }

  @override
  String errorCreatingOrder(Object error) {
    return 'Error creating order: $error';
  }

  @override
  String get serverRejectedTechnician =>
      'The server did not accept the selected technician';

  @override
  String get scheduledDate => 'Scheduled date';

  @override
  String get selectDate => 'Select date';

  @override
  String get saving => 'Saving...';

  @override
  String get createOrder => 'Create Order';

  @override
  String get responsibleTechnician => 'Responsible technician';

  @override
  String get assignToMe => 'Assign to me';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get doNotAssignNow => 'Do not assign now';

  @override
  String get meLabel => 'Me';

  @override
  String meWithName(Object name) {
    return 'Me ($name)';
  }

  @override
  String get meUnavailable => 'Me (unavailable)';

  @override
  String get recentOrdersError => 'Error loading recent orders';

  @override
  String get noRecentOrders => 'No recent orders';

  @override
  String get createServiceOrderTitle => 'Create Service Order';

  @override
  String get ordersLoadError => 'Error loading orders';

  @override
  String get noOrdersFound => 'No orders found';

  @override
  String get maintenanceExecutionTitle => 'Maintenance Execution';

  @override
  String get maintenanceExecutionStartTitle => 'Start maintenance';

  @override
  String get maintenanceExecutionEntrySubtitle =>
      'Enter the equipment code or scan the QR code.';

  @override
  String get equipmentCodeLabel => 'Equipment code';

  @override
  String get equipmentCodeHint => 'e.g. GER-001 or SO-123';

  @override
  String get lookupOrderButton => 'Find order';

  @override
  String get orDivider => 'or';

  @override
  String get scanQrCodeButton => 'Scan QR code';

  @override
  String get alignQrInstruction => 'Align the QR code inside the frame';

  @override
  String get typeCodeButton => 'Type code';

  @override
  String get orderFoundTitle => 'Order found';

  @override
  String get orderNotFoundTitle => 'Order not found';

  @override
  String get tryAnotherCode => 'Try another code.';

  @override
  String get tryAgainButton => 'Try again';

  @override
  String get equipmentCodeRequiredError => 'Enter the equipment code';

  @override
  String get userNotAuthenticatedError => 'User not authenticated';

  @override
  String get orderNotFoundError => 'Unable to find the order';

  @override
  String get qrNotRecognizedError => 'QR code not recognized';

  @override
  String get orderCodeDetectedError =>
      'Order code detected. Use the equipment code or scan the QR code.';

  @override
  String orderNumberLabel(Object id) {
    return 'Order #$id';
  }

  @override
  String clientLabel(Object name) {
    return 'Client: $name';
  }

  @override
  String scheduledForLabel(Object date) {
    return 'Scheduled: $date';
  }

  @override
  String get goToChecklistButton => 'Go to checklist';

  @override
  String get searchAnotherEquipmentButton => 'Search another equipment';

  @override
  String get statusUnavailable => 'Status unavailable';

  @override
  String get scheduledNotDefined => 'Not set';

  @override
  String get chooseEquipmentIdentification =>
      'Choose how to identify the equipment';

  @override
  String get continueButton => 'Continue';

  @override
  String equipmentCodeValue(Object code) {
    return 'Equipment code: $code';
  }

  @override
  String qrCodeValue(Object code) {
    return 'QR code: $code';
  }

  @override
  String get loginFailed => 'Login failed. Check your credentials.';

  @override
  String get appTagline =>
      'Professional maintenance and service\nmanagement for global teams.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get emailHintLogin => 'name@company.com';

  @override
  String percentOfTotal(Object percent) {
    return '$percent of total';
  }

  @override
  String get noItemsFound => 'No items found';

  @override
  String get noEquipmentYet => 'No equipment registered yet';

  @override
  String get noEquipmentMessage =>
      'Tap the + button to register your first piece of equipment.';

  @override
  String get searchingLocation => 'Searching location...';

  @override
  String get locationUnavailable => 'Location unavailable';

  @override
  String get locationFetchError => 'Error fetching location';

  @override
  String daysAgo(int count) {
    return '$count days';
  }

  @override
  String hoursAgo(int count) {
    return '$count h';
  }

  @override
  String minutesAgo(int count) {
    return '$count min';
  }

  @override
  String get locationCaptured => 'Location captured';

  @override
  String get locationNotCaptured => 'No location set';

  @override
  String get noClientSelected => 'None (no client)';

  @override
  String get basicInfoSection => 'BASIC INFORMATION';

  @override
  String get clientSection => 'CLIENT';

  @override
  String get locationSectionLabel => 'LOCATION';

  @override
  String get capturingLocation => 'Capturing location...';

  @override
  String get locationMethodGps => 'Current GPS';

  @override
  String get locationMethodAddress => 'Type address';

  @override
  String get addressSearchHint =>
      'e.g. 1600 Amphitheatre Parkway, Mountain View';

  @override
  String get searchingAddress => 'Searching address...';

  @override
  String get addressNotFound => 'Address not found. Try being more specific.';

  @override
  String get selectAddress => 'Select the address';

  @override
  String get addressSearchError => 'Error searching address';

  @override
  String get deleteConfirmation => 'Delete Item?';

  @override
  String get deleteMessage =>
      'Are you sure you want to delete this item? This action cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get itemDeleted => 'Item deleted successfully';
}
