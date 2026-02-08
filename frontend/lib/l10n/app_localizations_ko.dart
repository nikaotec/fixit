// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'FixIt MVP';

  @override
  String get loginTitle => '로그인';

  @override
  String get emailLabel => '이메일';

  @override
  String get passwordLabel => '비밀번호';

  @override
  String get loginButton => '로그인';

  @override
  String get dashboardTitle => '대시보드';

  @override
  String get ordersTab => '작업 지시';

  @override
  String get inventoryTab => '재고';

  @override
  String get notificationsTab => '알림';

  @override
  String get profileTab => '프로필';

  @override
  String get settingsTab => '설정';

  @override
  String get equipmentLabel => '장비';

  @override
  String get scanQrCode => 'QR 코드 스캔';

  @override
  String get checklistTitle => '체크리스트';

  @override
  String get signatureLabel => '서명';

  @override
  String get submitButton => '제출';

  @override
  String get languageLabel => '언어';

  @override
  String get logoutButton => '로그아웃';

  @override
  String get statusOpen => '열림';

  @override
  String get statusInProgress => '진행 중';

  @override
  String get statusFinished => '완료됨';

  @override
  String get profileTitle => '프로필';

  @override
  String get accountSettings => '계정 설정';

  @override
  String get personalInformation => '개인 정보';

  @override
  String get securityPassword => '보안 및 비밀번호';

  @override
  String get preferences => '환경설정';

  @override
  String get notifications => '알림';

  @override
  String get darkMode => '다크 모드';

  @override
  String get maintenancePro => 'Maintenance Pro';

  @override
  String get allSystemsNormal => '모든 시스템 정상';

  @override
  String get quickActions => '빠른 작업';

  @override
  String get newOrder => '새 작업 지시';

  @override
  String get assets => '자산';

  @override
  String get reports => '보고서';

  @override
  String get recentOrders => '최근 작업 지시';

  @override
  String get viewAll => '전체 보기';

  @override
  String get home => '홈';

  @override
  String get searchPlaceholder => '작업 지시, 자산 검색...';

  @override
  String get statusOverdue => '기한 초과';

  @override
  String get createEquipment => '장비 생성';

  @override
  String get createChecklist => '체크리스트 생성';

  @override
  String get mainDashboard => '메인 대시보드';

  @override
  String get createNewClient => '새 고객 생성';

  @override
  String get cancel => '취소';

  @override
  String get individual => '개인';

  @override
  String get corporate => '기업';

  @override
  String get basicInformation => '기본 정보';

  @override
  String get fullName => '이름 / 회사명';

  @override
  String get fullNameHint => '예: 홍길동 또는 Acme Corp';

  @override
  String get taxId => '세금 ID (CPF / CNPJ)';

  @override
  String get taxIdHint => '000.000.000-00';

  @override
  String get emailAddress => '이메일 주소';

  @override
  String get emailHint => 'client@email.com';

  @override
  String get phoneNumber => '전화번호';

  @override
  String get phoneHint => '+55 (11) 99999-9999';

  @override
  String get locationDetails => '위치 정보';

  @override
  String get zipCode => '우편번호 (CEP)';

  @override
  String get zipCodeHint => '00000-000';

  @override
  String get lookup => '조회';

  @override
  String get street => '거리';

  @override
  String get streetHint => '메인 스트리트';

  @override
  String get number => '번호';

  @override
  String get numberHint => '123';

  @override
  String get neighborhood => '동네';

  @override
  String get neighborhoodHint => '도심';

  @override
  String get city => '도시';

  @override
  String get cityHint => '샌프란시스코';

  @override
  String get primaryContact => '주요 연락처';

  @override
  String get optional => '선택';

  @override
  String get contactName => '담당자 이름';

  @override
  String get contactNameHint => '연락할 사람';

  @override
  String get position => '직책 / 역할';

  @override
  String get positionHint => '예: 매니저, 대표';

  @override
  String get internalNotes => '내부 메모';

  @override
  String get internalNotesHint => '이 고객에 대한 구체적인 지침이나 이력을 추가하세요...';

  @override
  String get saveClient => '고객 저장';

  @override
  String get clients => '고객';

  @override
  String get searchClients => '이름 또는 세금 ID로 검색';

  @override
  String get all => '전체';

  @override
  String get active => '활성';

  @override
  String get region => '지역';

  @override
  String get overdue => '연체';

  @override
  String get addClient => '고객 추가';

  @override
  String get noClientsFound => '고객을 찾을 수 없음';

  @override
  String get noClientsMessage =>
      '고객 목록이 비어 있습니다. 첫 개인 또는 기업 고객을 추가하여 장비와 서비스 작업 지시를 관리하세요.';

  @override
  String get addFirstClient => '첫 고객 추가';

  @override
  String get addEquipment => '장비 추가';

  @override
  String get editEquipment => '장비 수정';

  @override
  String get equipmentDetails => '장비 상세';

  @override
  String get equipmentDetailsSubtitle => 'Fixit 데이터베이스에 새 자산을 등록하세요.';

  @override
  String get equipmentName => '장비 이름';

  @override
  String get equipmentNameHint => '예: 산업용 HVAC 유닛 01';

  @override
  String get serialCode => '일련 번호';

  @override
  String get serialCodeHint => '예: SN-99234-XYZ';

  @override
  String get clientLocation => '고객 / 위치';

  @override
  String get selectClient => '고객 선택';

  @override
  String get geoCoordinates => '지리 좌표';

  @override
  String get latitude => '위도';

  @override
  String get longitude => '경도';

  @override
  String get useCurrentLocation => '현재 위치 사용';

  @override
  String get uniqueQrLabel => '고유 QR 라벨';

  @override
  String get generateQr => '생성';

  @override
  String get instantTechAccess => '즉시 기술자 접근용 생성';

  @override
  String get saveEquipment => '장비 저장';

  @override
  String get equipmentNameRequired => '장비 이름을 입력하세요';

  @override
  String get qrCodeTitle => 'QR 코드';

  @override
  String qrCodeSubtitle(Object name) {
    return '장비 라벨: $name';
  }

  @override
  String get shareQrCode => 'QR 코드 공유';

  @override
  String get printQrCode => 'QR 코드 인쇄';

  @override
  String get errorSharingQrCode => 'QR 코드를 공유할 수 없습니다.';

  @override
  String get errorPrintingQrCode => 'QR 코드를 인쇄할 수 없습니다.';

  @override
  String get ok => '확인';

  @override
  String equipmentNameLabel(Object name) {
    return '장비: $name';
  }

  @override
  String get locationServicesDisabled => '위치 서비스가 비활성화되어 있습니다.';

  @override
  String get locationPermissionsDenied => '위치 권한이 거부되었습니다.';

  @override
  String get locationPermissionsDeniedForever =>
      '위치 권한이 영구적으로 거부되어 요청할 수 없습니다.';

  @override
  String errorGettingLocation(Object error) {
    return '위치를 가져오는 중 오류: $error';
  }

  @override
  String errorSavingEquipment(Object error) {
    return '장비 저장 오류: $error';
  }

  @override
  String get deleteEquipmentTitle => '장비를 삭제하시겠습니까?';

  @override
  String get deleteEquipmentBody => '이 장비를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get deleteAction => '삭제';

  @override
  String errorDeletingEquipment(Object error) {
    return '삭제 오류: $error';
  }

  @override
  String get save => '저장';

  @override
  String get equipmentInventory => '장비 재고';

  @override
  String get searchEquipmentPlaceholder => '이름 또는 일련 번호로 검색...';

  @override
  String get byClient => '고객별';

  @override
  String get category => '카테고리';

  @override
  String get status => '상태';

  @override
  String itemsFound(int count) {
    return '$count개 항목 발견';
  }

  @override
  String get ordersTitle => '작업 지시';

  @override
  String get serviceOrdersTitle => '서비스 작업 지시';

  @override
  String get searchOrdersPlaceholder => '작업 지시 검색';

  @override
  String get statusPending => '대기';

  @override
  String get statusCancelled => '취소됨';

  @override
  String get locationNotSpecified => '위치 미지정';

  @override
  String get noSchedule => '일정 없음';

  @override
  String get orderDetailsTitle => '작업 지시 상세';

  @override
  String get startMaintenance => '정비 시작';

  @override
  String get clientAndLocation => '고객 및 위치';

  @override
  String get assignedChecklist => '할당된 체크리스트';

  @override
  String get checklistNotAssigned => '체크리스트 미할당';

  @override
  String get assignedTechnician => '할당된 기술자';

  @override
  String get unassigned => '미할당';

  @override
  String get reassign => '재할당';

  @override
  String createdBy(Object name) {
    return '작성자: $name';
  }

  @override
  String get roleCreator => '작성자';

  @override
  String get roleResponsible => '담당자';

  @override
  String get roleCreatorResponsible => '작성자 및 담당자';

  @override
  String get checklistTemplates => '체크리스트 템플릿';

  @override
  String get techniciansLabel => '기술자';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get passwordMin6 => '비밀번호는 최소 6자여야 합니다';

  @override
  String get noAccountQuestion => '계정이 없으신가요?';

  @override
  String get createAccount => '계정 생성';

  @override
  String get englishLabel => '영어';

  @override
  String get portugueseLabel => '포르투갈어';

  @override
  String get forgotPasswordTitle => '비밀번호 찾기';

  @override
  String get forgotPasswordBody =>
      '현재 비밀번호 재설정은 관리자에 의해 처리됩니다. 관리자에게 연락해 자격 증명을 재설정하세요.';

  @override
  String get registerTitle => '계정 만들기';

  @override
  String get emailRequired => '이메일을 입력하세요';

  @override
  String get emailInvalid => '유효한 이메일을 입력하세요';

  @override
  String get passwordLabelText => '비밀번호';

  @override
  String get passwordHint => '비밀번호 생성';

  @override
  String get passwordRequired => '비밀번호를 입력하세요';

  @override
  String get passwordMin8 => '비밀번호는 최소 8자여야 합니다';

  @override
  String get confirmPasswordLabel => '비밀번호 확인';

  @override
  String get confirmPasswordHint => '비밀번호를 다시 입력하세요';

  @override
  String get confirmPasswordRequired => '비밀번호를 확인하세요';

  @override
  String get passwordsDoNotMatch => '비밀번호가 일치하지 않습니다';

  @override
  String get initialLanguage => '초기 언어';

  @override
  String get alreadyHaveAccount => '이미 계정이 있나요?';

  @override
  String get logIn => '로그인';

  @override
  String get termsPrefix => '계정을 만들면 다음에 동의하게 됩니다: ';

  @override
  String get termsOfService => '서비스 약관';

  @override
  String get andConjunction => ' 및 ';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get orderDetailsHeading => '작업 지시 상세';

  @override
  String get orderTypeLabel => '작업 지시 유형';

  @override
  String get orderTypeMaintenance => '정비';

  @override
  String get orderTypeRepair => '수리';

  @override
  String get orderTypeOther => '기타';

  @override
  String get problemDescriptionLabel => '문제 설명';

  @override
  String get problemDescriptionHint => '수리할 문제를 설명하세요';

  @override
  String get problemDescriptionRequired => '문제를 설명하세요';

  @override
  String get problemDescriptionEmpty => '문제 설명이 없습니다';

  @override
  String get brandLabel => '브랜드';

  @override
  String get modelLabel => '모델';

  @override
  String get brandRequired => '브랜드를 입력하세요';

  @override
  String get modelRequired => '모델을 입력하세요';

  @override
  String get voiceInput => '음성 입력';

  @override
  String get listening => '듣는 중...';

  @override
  String get transcribing => '전사 중';

  @override
  String get portugueseBrazil => '포르투갈어 (BR)';

  @override
  String get englishUS => '영어 (US)';

  @override
  String get voiceNotAvailable => '음성 입력을 사용할 수 없습니다';

  @override
  String get stopListening => '중지';

  @override
  String get selectEquipmentChecklist => '장비와 체크리스트를 선택하세요';

  @override
  String get orderCreatedSuccess => '작업 지시가 성공적으로 생성되었습니다';

  @override
  String get userNotAuthenticated => '사용자가 인증되지 않았습니다';

  @override
  String errorLoadingData(Object error) {
    return '데이터 로드 오류: $error';
  }

  @override
  String errorCreatingOrder(Object error) {
    return '작업 지시 생성 오류: $error';
  }

  @override
  String get serverRejectedTechnician => '서버가 선택한 기술자를 승인하지 않았습니다';

  @override
  String get scheduledDate => '예정 날짜';

  @override
  String get selectDate => '날짜 선택';

  @override
  String get saving => '저장 중...';

  @override
  String get createOrder => '작업 지시 생성';

  @override
  String get responsibleTechnician => '담당 기술자';

  @override
  String get priorityLabel => '우선순위';

  @override
  String get priorityHigh => '높음';

  @override
  String get priorityMedium => '중간';

  @override
  String get priorityLow => '낮음';

  @override
  String get doNotAssignNow => '지금 배정하지 않음';

  @override
  String get meLabel => '나';

  @override
  String meWithName(Object name) {
    return '나 ($name)';
  }

  @override
  String get meUnavailable => '나 (사용 불가)';

  @override
  String get recentOrdersError => '최근 작업 지시를 불러오는 중 오류';

  @override
  String get noRecentOrders => '최근 작업 지시 없음';

  @override
  String get createServiceOrderTitle => '서비스 작업 지시 생성';

  @override
  String get ordersLoadError => '작업 지시 로드 오류';

  @override
  String get noOrdersFound => '작업 지시를 찾을 수 없음';
}
