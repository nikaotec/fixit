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
}
