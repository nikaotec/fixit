// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'FixIt MVP';

  @override
  String get loginTitle => 'ログイン';

  @override
  String get emailLabel => 'メール';

  @override
  String get passwordLabel => 'パスワード';

  @override
  String get loginButton => 'ログイン';

  @override
  String get dashboardTitle => 'ダッシュボード';

  @override
  String get ordersTab => '作業指示';

  @override
  String get inventoryTab => '在庫';

  @override
  String get notificationsTab => 'アラート';

  @override
  String get profileTab => 'プロフィール';

  @override
  String get settingsTab => '設定';

  @override
  String get equipmentLabel => '設備';

  @override
  String get scanQrCode => 'QRコードをスキャン';

  @override
  String get checklistTitle => 'チェックリスト';

  @override
  String get signatureLabel => '署名';

  @override
  String get submitButton => '送信';

  @override
  String get languageLabel => '言語';

  @override
  String get logoutButton => 'ログアウト';

  @override
  String get statusOpen => 'オープン';

  @override
  String get statusInProgress => '進行中';

  @override
  String get statusFinished => '完了';

  @override
  String get profileTitle => 'プロフィール';

  @override
  String get accountSettings => 'アカウント設定';

  @override
  String get personalInformation => '個人情報';

  @override
  String get securityPassword => 'セキュリティとパスワード';

  @override
  String get preferences => '設定';

  @override
  String get notifications => '通知';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get maintenancePro => 'Maintenance Pro';

  @override
  String get allSystemsNormal => 'すべて正常です';

  @override
  String get quickActions => 'クイックアクション';

  @override
  String get newOrder => '新規作業指示';

  @override
  String get assets => '資産';

  @override
  String get reports => 'レポート';

  @override
  String get recentOrders => '最近の作業指示';

  @override
  String get viewAll => 'すべて表示';

  @override
  String get home => 'ホーム';

  @override
  String get searchPlaceholder => '作業指示、資産を検索...';

  @override
  String get statusOverdue => '期限超過';

  @override
  String get createEquipment => '設備を作成';

  @override
  String get createChecklist => 'チェックリストを作成';

  @override
  String get mainDashboard => 'メインダッシュボード';

  @override
  String get createNewClient => '新規顧客を作成';

  @override
  String get cancel => 'キャンセル';

  @override
  String get individual => '個人';

  @override
  String get corporate => '法人';

  @override
  String get basicInformation => '基本情報';

  @override
  String get fullName => '氏名 / 会社名';

  @override
  String get fullNameHint => '例：山田太郎 または Acme Corp';

  @override
  String get taxId => '税ID (CPF / CNPJ)';

  @override
  String get taxIdHint => '000.000.000-00';

  @override
  String get emailAddress => 'メールアドレス';

  @override
  String get emailHint => 'client@email.com';

  @override
  String get phoneNumber => '電話番号';

  @override
  String get phoneHint => '+55 (11) 99999-9999';

  @override
  String get locationDetails => '所在地の詳細';

  @override
  String get zipCode => '郵便番号 (CEP)';

  @override
  String get zipCodeHint => '00000-000';

  @override
  String get lookup => '検索';

  @override
  String get street => '通り';

  @override
  String get streetHint => 'メインストリート';

  @override
  String get number => '番号';

  @override
  String get numberHint => '123';

  @override
  String get neighborhood => '地区';

  @override
  String get neighborhoodHint => '中心街';

  @override
  String get city => '市';

  @override
  String get cityHint => 'サンフランシスコ';

  @override
  String get primaryContact => '主担当';

  @override
  String get optional => '任意';

  @override
  String get contactName => '担当者名';

  @override
  String get contactNameHint => '連絡先の人';

  @override
  String get position => '役職 / 役割';

  @override
  String get positionHint => '例：マネージャー、オーナー';

  @override
  String get internalNotes => '内部メモ';

  @override
  String get internalNotesHint => 'この顧客に関する具体的な指示や履歴を追加...';

  @override
  String get saveClient => '顧客を保存';

  @override
  String get clients => '顧客';

  @override
  String get searchClients => '名前または税IDで検索';

  @override
  String get all => 'すべて';

  @override
  String get active => '有効';

  @override
  String get region => '地域';

  @override
  String get overdue => '期限超過';

  @override
  String get addClient => '顧客を追加';

  @override
  String get noClientsFound => '顧客が見つかりません';

  @override
  String get noClientsMessage =>
      '顧客リストは空です。最初の個人または法人顧客を追加して、設備とサービス作業指示を管理してください。';

  @override
  String get addFirstClient => '最初の顧客を追加';

  @override
  String get addEquipment => '設備を追加';

  @override
  String get editEquipment => '設備を編集';

  @override
  String get equipmentDetails => '設備の詳細';

  @override
  String get equipmentDetailsSubtitle => 'Fixit データベースに新しい資産を登録します。';

  @override
  String get equipmentName => '設備名';

  @override
  String get equipmentNameHint => '例：産業用 HVAC ユニット 01';

  @override
  String get serialCode => 'シリアルコード';

  @override
  String get serialCodeHint => '例：SN-99234-XYZ';

  @override
  String get clientLocation => '顧客 / 場所';

  @override
  String get selectClient => '顧客を選択';

  @override
  String get geoCoordinates => '地理座標';

  @override
  String get latitude => '緯度';

  @override
  String get longitude => '経度';

  @override
  String get useCurrentLocation => '現在地を使用';

  @override
  String get uniqueQrLabel => 'ユニークQRラベル';

  @override
  String get generateQr => '生成';

  @override
  String get instantTechAccess => '技術者が即時アクセスできるよう生成';

  @override
  String get saveEquipment => '設備を保存';

  @override
  String get equipmentNameRequired => '設備名を入力してください';

  @override
  String get qrCodeTitle => 'QRコード';

  @override
  String qrCodeSubtitle(Object name) {
    return '設備ラベル: $name';
  }

  @override
  String get shareQrCode => 'QRコードを共有';

  @override
  String get printQrCode => 'QRコードを印刷';

  @override
  String get errorSharingQrCode => 'QRコードを共有できません。';

  @override
  String get errorPrintingQrCode => 'QRコードを印刷できません。';

  @override
  String get ok => 'OK';

  @override
  String equipmentNameLabel(Object name) {
    return '設備: $name';
  }

  @override
  String get locationServicesDisabled => '位置情報サービスが無効です。';

  @override
  String get locationPermissionsDenied => '位置情報の権限が拒否されました。';

  @override
  String get locationPermissionsDeniedForever => '位置情報の権限が永久に拒否されており、要求できません。';

  @override
  String errorGettingLocation(Object error) {
    return '位置情報の取得エラー: $error';
  }

  @override
  String errorSavingEquipment(Object error) {
    return '設備の保存エラー: $error';
  }

  @override
  String get deleteEquipmentTitle => '設備を削除しますか？';

  @override
  String get deleteEquipmentBody => 'この設備を削除してもよろしいですか？この操作は元に戻せません。';

  @override
  String get deleteAction => '削除';

  @override
  String errorDeletingEquipment(Object error) {
    return '削除エラー: $error';
  }

  @override
  String get save => '保存';

  @override
  String get equipmentInventory => '設備在庫';

  @override
  String get searchEquipmentPlaceholder => '名前またはシリアルで検索...';

  @override
  String get byClient => '顧客別';

  @override
  String get category => 'カテゴリ';

  @override
  String get status => 'ステータス';

  @override
  String itemsFound(int count) {
    return '$count 件見つかりました';
  }

  @override
  String get ordersTitle => '作業指示';

  @override
  String get serviceOrdersTitle => 'サービス作業指示';

  @override
  String get searchOrdersPlaceholder => '作業指示を検索';

  @override
  String get statusPending => '保留';

  @override
  String get statusCancelled => 'キャンセル';

  @override
  String get locationNotSpecified => '場所が指定されていません';

  @override
  String get noSchedule => '予定なし';

  @override
  String get orderDetailsTitle => '作業指示の詳細';

  @override
  String get startMaintenance => '保守を開始';

  @override
  String get clientAndLocation => '顧客と場所';

  @override
  String get assignedChecklist => '割り当てられたチェックリスト';

  @override
  String get checklistNotAssigned => 'チェックリスト未割り当て';

  @override
  String get assignedTechnician => '担当技術者';

  @override
  String get unassigned => '未割り当て';

  @override
  String get reassign => '再割り当て';

  @override
  String createdBy(Object name) {
    return '作成者: $name';
  }

  @override
  String get roleCreator => '作成者';

  @override
  String get roleResponsible => '担当者';

  @override
  String get roleCreatorResponsible => '作成者と担当者';

  @override
  String get checklistTemplates => 'チェックリストテンプレート';

  @override
  String get techniciansLabel => '技術者';

  @override
  String get forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get passwordMin6 => 'パスワードは6文字以上である必要があります';

  @override
  String get noAccountQuestion => 'アカウントをお持ちでないですか？';

  @override
  String get createAccount => 'アカウント作成';

  @override
  String get englishLabel => '英語';

  @override
  String get portugueseLabel => 'ポルトガル語';

  @override
  String get forgotPasswordTitle => 'パスワードをお忘れですか';

  @override
  String get forgotPasswordBody =>
      '現在、パスワードのリセットは管理者が行っています。資格情報のリセットは管理者に連絡してください。';

  @override
  String get registerTitle => 'アカウントを作成';

  @override
  String get emailRequired => 'メールアドレスを入力してください';

  @override
  String get emailInvalid => '有効なメールアドレスを入力してください';

  @override
  String get passwordLabelText => 'パスワード';

  @override
  String get passwordHint => 'パスワードを作成';

  @override
  String get passwordRequired => 'パスワードを入力してください';

  @override
  String get passwordMin8 => 'パスワードは8文字以上である必要があります';

  @override
  String get confirmPasswordLabel => 'パスワード確認';

  @override
  String get confirmPasswordHint => 'パスワードを再入力';

  @override
  String get confirmPasswordRequired => 'パスワードを確認してください';

  @override
  String get passwordsDoNotMatch => 'パスワードが一致しません';

  @override
  String get initialLanguage => '初期言語';

  @override
  String get alreadyHaveAccount => 'すでにアカウントをお持ちですか？';

  @override
  String get logIn => 'ログイン';

  @override
  String get termsPrefix => 'アカウントを作成することで、以下に同意します：';

  @override
  String get termsOfService => '利用規約';

  @override
  String get andConjunction => 'と';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get orderDetailsHeading => '作業指示の詳細';

  @override
  String get orderTypeLabel => '作業指示の種類';

  @override
  String get orderTypeMaintenance => '保守';

  @override
  String get orderTypeRepair => '修理';

  @override
  String get orderTypeOther => 'その他';

  @override
  String get problemDescriptionLabel => '問題の説明';

  @override
  String get problemDescriptionHint => '修理すべき問題を説明してください';

  @override
  String get problemDescriptionRequired => '問題を説明してください';

  @override
  String get problemDescriptionEmpty => '問題の説明がありません';

  @override
  String get brandLabel => 'ブランド';

  @override
  String get modelLabel => 'モデル';

  @override
  String get brandRequired => 'ブランドを入力してください';

  @override
  String get modelRequired => 'モデルを入力してください';

  @override
  String get voiceInput => '音声入力';

  @override
  String get listening => '聞き取り中...';

  @override
  String get transcribing => '文字起こし中';

  @override
  String get portugueseBrazil => 'ポルトガル語（BR）';

  @override
  String get englishUS => '英語（US）';

  @override
  String get voiceNotAvailable => '音声入力を利用できません';

  @override
  String get stopListening => '停止';

  @override
  String get selectEquipmentChecklist => '設備とチェックリストを選択';

  @override
  String get orderCreatedSuccess => '作業指示が正常に作成されました';

  @override
  String get userNotAuthenticated => 'ユーザーが認証されていません';

  @override
  String errorLoadingData(Object error) {
    return 'データの読み込みエラー: $error';
  }

  @override
  String errorCreatingOrder(Object error) {
    return '作業指示の作成エラー: $error';
  }

  @override
  String get serverRejectedTechnician => 'サーバーが選択した技術者を受け付けませんでした';

  @override
  String get scheduledDate => '予定日';

  @override
  String get selectDate => '日付を選択';

  @override
  String get saving => '保存中...';

  @override
  String get createOrder => '作業指示を作成';

  @override
  String get responsibleTechnician => '担当技術者';

  @override
  String get priorityLabel => '優先度';

  @override
  String get priorityHigh => '高';

  @override
  String get priorityMedium => '中';

  @override
  String get priorityLow => '低';

  @override
  String get doNotAssignNow => '今は割り当てない';

  @override
  String get meLabel => '自分';

  @override
  String meWithName(Object name) {
    return '自分（$name）';
  }

  @override
  String get meUnavailable => '自分（利用不可）';

  @override
  String get recentOrdersError => '最近の作業指示の読み込みエラー';

  @override
  String get noRecentOrders => '最近の作業指示はありません';

  @override
  String get createServiceOrderTitle => 'サービス作業指示を作成';

  @override
  String get ordersLoadError => '作業指示の読み込みエラー';

  @override
  String get noOrdersFound => '作業指示が見つかりません';
}
