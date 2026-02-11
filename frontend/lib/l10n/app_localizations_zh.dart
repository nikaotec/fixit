// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'FixIt MVP';

  @override
  String get loginTitle => '登录';

  @override
  String get emailLabel => '邮箱';

  @override
  String get passwordLabel => '密码';

  @override
  String get loginButton => '登录';

  @override
  String get dashboardTitle => '仪表盘';

  @override
  String get ordersTab => '工单';

  @override
  String get inventoryTab => '库存';

  @override
  String get notificationsTab => '提醒';

  @override
  String get profileTab => '个人资料';

  @override
  String get settingsTab => '设置';

  @override
  String get equipmentLabel => '设备';

  @override
  String get scanQrCode => '扫描二维码';

  @override
  String get checklistTitle => '检查清单';

  @override
  String get signatureLabel => '签名';

  @override
  String get submitButton => '提交';

  @override
  String get languageLabel => '语言';

  @override
  String get logoutButton => '退出登录';

  @override
  String get statusOpen => '开放';

  @override
  String get statusInProgress => '进行中';

  @override
  String get statusFinished => '已完成';

  @override
  String get profileTitle => '个人资料';

  @override
  String get accountSettings => '账户设置';

  @override
  String get personalInformation => '个人信息';

  @override
  String get securityPassword => '安全与密码';

  @override
  String get preferences => '偏好设置';

  @override
  String get notifications => '通知';

  @override
  String get darkMode => '深色模式';

  @override
  String get maintenancePro => 'Maintenance Pro';

  @override
  String get allSystemsNormal => '系统一切正常';

  @override
  String get quickActions => '快捷操作';

  @override
  String get newOrder => '新工单';

  @override
  String get assets => '资产';

  @override
  String get reports => '报表';

  @override
  String get recentOrders => '最近工单';

  @override
  String get viewAll => '查看全部';

  @override
  String get home => '首页';

  @override
  String get searchPlaceholder => '搜索工单、资产...';

  @override
  String get statusOverdue => '已逾期';

  @override
  String get createEquipment => '创建设备';

  @override
  String get createChecklist => '创建检查清单';

  @override
  String get mainDashboard => '主仪表盘';

  @override
  String get createNewClient => '创建新客户';

  @override
  String get cancel => '取消';

  @override
  String get individual => '个人';

  @override
  String get corporate => '企业';

  @override
  String get basicInformation => '基本信息';

  @override
  String get fullName => '姓名 / 公司名称';

  @override
  String get fullNameHint => '例如：张三 或 Acme Corp';

  @override
  String get taxId => '税号 (CPF / CNPJ)';

  @override
  String get taxIdHint => '000.000.000-00';

  @override
  String get emailAddress => '邮箱地址';

  @override
  String get emailHint => 'client@email.com';

  @override
  String get phoneNumber => '电话号码';

  @override
  String get phoneHint => '+55 (11) 99999-9999';

  @override
  String get locationDetails => '地址信息';

  @override
  String get zipCode => '邮编 (CEP)';

  @override
  String get zipCodeHint => '00000-000';

  @override
  String get lookup => '查询';

  @override
  String get street => '街道';

  @override
  String get streetHint => '主街';

  @override
  String get number => '号';

  @override
  String get numberHint => '123';

  @override
  String get neighborhood => '街区';

  @override
  String get neighborhoodHint => '市中心';

  @override
  String get city => '城市';

  @override
  String get cityHint => '旧金山';

  @override
  String get primaryContact => '主要联系人';

  @override
  String get optional => '可选';

  @override
  String get contactName => '联系人姓名';

  @override
  String get contactNameHint => '联系人';

  @override
  String get position => '职位 / 角色';

  @override
  String get positionHint => '例如：经理、负责人';

  @override
  String get internalNotes => '内部备注';

  @override
  String get internalNotesHint => '添加关于该客户的具体说明或历史记录...';

  @override
  String get saveClient => '保存客户';

  @override
  String get clients => '客户';

  @override
  String get searchClients => '按姓名或税号搜索';

  @override
  String get all => '全部';

  @override
  String get active => '活跃';

  @override
  String get region => '地区';

  @override
  String get overdue => '逾期';

  @override
  String get addClient => '添加客户';

  @override
  String get noClientsFound => '未找到客户';

  @override
  String get noClientsMessage => '客户列表为空。先添加您的第一个个人或企业客户，以便管理其设备和服务工单。';

  @override
  String get addFirstClient => '添加首位客户';

  @override
  String get addEquipment => '添加设备';

  @override
  String get editEquipment => '编辑设备';

  @override
  String get equipmentDetails => '设备详情';

  @override
  String get equipmentDetailsSubtitle => '在 Fixit 数据库中登记新资产。';

  @override
  String get equipmentName => '设备名称';

  @override
  String get equipmentNameHint => '例如：工业 HVAC 设备 01';

  @override
  String get serialCode => '序列号';

  @override
  String get serialCodeHint => '例如：SN-99234-XYZ';

  @override
  String get clientLocation => '客户 / 地址';

  @override
  String get selectClient => '选择客户';

  @override
  String get geoCoordinates => '地理坐标';

  @override
  String get latitude => '纬度';

  @override
  String get longitude => '经度';

  @override
  String get useCurrentLocation => '使用当前位置';

  @override
  String get uniqueQrLabel => '唯一二维码标签';

  @override
  String get generateQr => '生成';

  @override
  String get instantTechAccess => '生成以便技术人员即时访问';

  @override
  String get saveEquipment => '保存设备';

  @override
  String get equipmentNameRequired => '请输入设备名称';

  @override
  String get qrCodeTitle => '二维码';

  @override
  String qrCodeSubtitle(Object name) {
    return '设备标签：$name';
  }

  @override
  String get shareQrCode => '分享二维码';

  @override
  String get printQrCode => '打印二维码';

  @override
  String get errorSharingQrCode => '无法分享二维码。';

  @override
  String get errorPrintingQrCode => '无法打印二维码。';

  @override
  String get ok => '确定';

  @override
  String equipmentNameLabel(Object name) {
    return '设备：$name';
  }

  @override
  String get locationServicesDisabled => '定位服务已关闭。';

  @override
  String get locationPermissionsDenied => '定位权限被拒绝。';

  @override
  String get locationPermissionsDeniedForever => '定位权限被永久拒绝，无法再次请求。';

  @override
  String errorGettingLocation(Object error) {
    return '获取位置出错：$error';
  }

  @override
  String errorSavingEquipment(Object error) {
    return '保存设备时出错：$error';
  }

  @override
  String get deleteEquipmentTitle => '删除设备？';

  @override
  String get deleteEquipmentBody => '确定要删除该设备吗？此操作无法撤销。';

  @override
  String get deleteAction => '删除';

  @override
  String errorDeletingEquipment(Object error) {
    return '删除时出错：$error';
  }

  @override
  String get save => '保存';

  @override
  String get equipmentInventory => '设备库存';

  @override
  String get searchEquipmentPlaceholder => '按名称或序列号搜索...';

  @override
  String get byClient => '按客户';

  @override
  String get category => '类别';

  @override
  String get status => '状态';

  @override
  String itemsFound(int count) {
    return '找到 $count 项';
  }

  @override
  String get ordersTitle => '工单';

  @override
  String get serviceOrdersTitle => '服务工单';

  @override
  String get searchOrdersPlaceholder => '搜索工单';

  @override
  String get statusPending => '待处理';

  @override
  String get statusCancelled => '已取消';

  @override
  String get locationNotSpecified => '未指定位置';

  @override
  String get noSchedule => '无计划';

  @override
  String get orderDetailsTitle => '工单详情';

  @override
  String get startMaintenance => '开始维护';

  @override
  String get clientAndLocation => '客户与地址';

  @override
  String get assignedChecklist => '已分配检查清单';

  @override
  String get checklistNotAssigned => '未分配检查清单';

  @override
  String get assignedTechnician => '已分配技师';

  @override
  String get unassigned => '未分配';

  @override
  String get reassign => '重新分配';

  @override
  String createdBy(Object name) {
    return '创建者：$name';
  }

  @override
  String get roleCreator => '创建者';

  @override
  String get roleResponsible => '负责人';

  @override
  String get roleCreatorResponsible => '创建者与负责人';

  @override
  String get checklistTemplates => '检查清单模板';

  @override
  String get techniciansLabel => '技师';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get passwordMin6 => '密码至少需要 6 个字符';

  @override
  String get noAccountQuestion => '没有账号？';

  @override
  String get createAccount => '创建账号';

  @override
  String get englishLabel => '英语';

  @override
  String get portugueseLabel => '葡萄牙语';

  @override
  String get forgotPasswordTitle => '忘记密码';

  @override
  String get forgotPasswordBody => '目前密码重置由管理员处理。请联系您的经理重置凭据。';

  @override
  String get registerTitle => '创建您的账户';

  @override
  String get emailRequired => '请输入邮箱';

  @override
  String get emailInvalid => '请输入有效邮箱';

  @override
  String get passwordLabelText => '密码';

  @override
  String get passwordHint => '创建密码';

  @override
  String get passwordRequired => '请输入密码';

  @override
  String get passwordMin8 => '密码至少需要 8 个字符';

  @override
  String get confirmPasswordLabel => '确认密码';

  @override
  String get confirmPasswordHint => '再次输入密码';

  @override
  String get confirmPasswordRequired => '请确认密码';

  @override
  String get passwordsDoNotMatch => '两次密码不一致';

  @override
  String get initialLanguage => '初始语言';

  @override
  String get alreadyHaveAccount => '已有账号？';

  @override
  String get logIn => '登录';

  @override
  String get termsPrefix => '创建账户即表示您同意我们的';

  @override
  String get termsOfService => '服务条款';

  @override
  String get andConjunction => '和';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get orderDetailsHeading => '工单详情';

  @override
  String get orderTypeLabel => '工单类型';

  @override
  String get orderTypeMaintenance => '维护';

  @override
  String get orderTypeRepair => '维修';

  @override
  String get orderTypeOther => '其他';

  @override
  String get problemDescriptionLabel => '问题描述';

  @override
  String get problemDescriptionHint => '描述需要修复的问题';

  @override
  String get problemDescriptionRequired => '请描述问题';

  @override
  String get problemDescriptionEmpty => '未提供问题描述';

  @override
  String get brandLabel => '品牌';

  @override
  String get modelLabel => '型号';

  @override
  String get brandRequired => '请输入品牌';

  @override
  String get modelRequired => '请输入型号';

  @override
  String get voiceInput => '语音输入';

  @override
  String get listening => '正在聆听...';

  @override
  String get transcribing => '转写中';

  @override
  String get portugueseBrazil => '葡萄牙语（巴西）';

  @override
  String get englishUS => '英语（美国）';

  @override
  String get voiceNotAvailable => '语音输入不可用';

  @override
  String get stopListening => '停止';

  @override
  String get selectEquipmentChecklist => '选择设备与检查清单';

  @override
  String get orderCreatedSuccess => '工单创建成功';

  @override
  String get userNotAuthenticated => '用户未认证';

  @override
  String errorLoadingData(Object error) {
    return '加载数据出错：$error';
  }

  @override
  String errorCreatingOrder(Object error) {
    return '创建工单出错：$error';
  }

  @override
  String get serverRejectedTechnician => '服务器未接受所选技师';

  @override
  String get scheduledDate => '计划日期';

  @override
  String get selectDate => '选择日期';

  @override
  String get saving => '保存中...';

  @override
  String get createOrder => '创建工单';

  @override
  String get responsibleTechnician => '负责人技师';

  @override
  String get assignToMe => 'Assign to me';

  @override
  String get priorityLabel => '优先级';

  @override
  String get priorityHigh => '高';

  @override
  String get priorityMedium => '中';

  @override
  String get priorityLow => '低';

  @override
  String get doNotAssignNow => '暂不分配';

  @override
  String get meLabel => '我';

  @override
  String meWithName(Object name) {
    return '我（$name）';
  }

  @override
  String get meUnavailable => '我（不可用）';

  @override
  String get recentOrdersError => '加载最近工单出错';

  @override
  String get noRecentOrders => '没有最近工单';

  @override
  String get createServiceOrderTitle => '创建服务工单';

  @override
  String get ordersLoadError => '加载工单出错';

  @override
  String get noOrdersFound => '未找到工单';

  @override
  String get maintenanceExecutionTitle => '维护执行';

  @override
  String get maintenanceExecutionStartTitle => '开始维护';

  @override
  String get maintenanceExecutionEntrySubtitle => '请输入设备代码或扫描二维码。';

  @override
  String get equipmentCodeLabel => '设备代码';

  @override
  String get equipmentCodeHint => '例如：GER-001 或 SO-123';

  @override
  String get lookupOrderButton => '查找工单';

  @override
  String get orDivider => '或';

  @override
  String get scanQrCodeButton => '扫描二维码';

  @override
  String get alignQrInstruction => '将二维码对准取景框';

  @override
  String get typeCodeButton => '输入代码';

  @override
  String get orderFoundTitle => '找到工单';

  @override
  String get orderNotFoundTitle => '未找到工单';

  @override
  String get tryAnotherCode => '请尝试其他代码。';

  @override
  String get tryAgainButton => '重试';

  @override
  String get equipmentCodeRequiredError => '请输入设备代码';

  @override
  String get userNotAuthenticatedError => '用户未认证';

  @override
  String get orderNotFoundError => '无法找到工单';

  @override
  String get qrNotRecognizedError => '二维码无法识别';

  @override
  String get orderCodeDetectedError => '检测到工单编号。请使用设备代码或扫描二维码。';

  @override
  String orderNumberLabel(Object id) {
    return '工单 #$id';
  }

  @override
  String clientLabel(Object name) {
    return '客户：$name';
  }

  @override
  String scheduledForLabel(Object date) {
    return '预计：$date';
  }

  @override
  String get goToChecklistButton => '进入检查清单';

  @override
  String get searchAnotherEquipmentButton => '查找其他设备';

  @override
  String get statusUnavailable => '状态不可用';

  @override
  String get scheduledNotDefined => '未设置';

  @override
  String get chooseEquipmentIdentification => '选择如何识别设备';

  @override
  String get continueButton => '继续';

  @override
  String equipmentCodeValue(Object code) {
    return '设备代码：$code';
  }

  @override
  String qrCodeValue(Object code) {
    return '二维码：$code';
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
}
