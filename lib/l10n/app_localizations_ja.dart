// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get transactionBook => '取引帳';

  @override
  String get wallet => 'ウォレット';

  @override
  String get statistics => '統計';

  @override
  String get settings => '設定';

  @override
  String get hello => 'こんにちは';

  @override
  String get monday => '月曜日';

  @override
  String get tuesday => '火曜日';

  @override
  String get wednesday => '水曜日';

  @override
  String get thursday => '木曜日';

  @override
  String get friday => '金曜日';

  @override
  String get saturday => '土曜日';

  @override
  String get sunday => '日曜日';

  @override
  String get myWallet => '私の財布';

  @override
  String get jan => '1月';

  @override
  String get feb => '2月';

  @override
  String get mar => '3月';

  @override
  String get apr => '4月';

  @override
  String get may => '5月';

  @override
  String get jun => '6月';

  @override
  String get jul => '7月';

  @override
  String get aug => '8月';

  @override
  String get sep => '9月';

  @override
  String get oct => '10月';

  @override
  String get nov => '11月';

  @override
  String get dec => '12月';

  @override
  String get income => '収入';

  @override
  String get expense => '支出';

  @override
  String get myAccount => '私のアカウント';

  @override
  String get selectGroup => '取引グループを選択';

  @override
  String get transactionName => '取引名';

  @override
  String get transactionAmount => '取引金額';

  @override
  String get addFriend => '友達を追加';

  @override
  String get dueDate => '期日';

  @override
  String get note => 'メモ';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get category => 'カテゴリー';

  @override
  String get month => '月';

  @override
  String get year => '年';

  @override
  String get week => '週';

  @override
  String get statisticsBy => '支出統計';

  @override
  String get linkBank => '銀行を連携';

  @override
  String get linkBankDialogTitle => '銀行を連携';

  @override
  String get linkBankDialogContent => 'この機能は今後開発されます。';

  @override
  String get close => '閉じる';

  @override
  String get compareExpenseTypes => '支出タイプの比較';

  @override
  String get compareIncomeTypes => 'So sánh các loại thu nhập';

  @override
  String get selectPeriod => 'Chọn kỳ';

  @override
  String get monthly => 'Hàng tháng';

  @override
  String get weekly => 'Hàng tuần';

  @override
  String get language => '言語';

  @override
  String get manageCategory => 'カテゴリーの管理';

  @override
  String get systemTheme => 'システムテーマ';

  @override
  String get userManagement => 'ユーザー管理';

  @override
  String get account => 'アカウント';

  @override
  String get notification => '通知';

  @override
  String get chooseLanguage => '言語を選択';

  @override
  String get themeSettings => 'テーマ設定';

  @override
  String get theme => 'テーマ';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get system => 'システム';

  @override
  String get primaryColor => 'テーマカラー';

  @override
  String get fontFamily => 'フォント';

  @override
  String get fontSize => '文字サイズ';

  @override
  String get effect => 'エフェクト';

  @override
  String get saveSettings => '設定を保存';

  @override
  String get previewNote => '現在の設定によるプレビュー画面です';

  @override
  String get languageChanged => '言語が正常に変更されました';

  @override
  String get settingsSaved => '設定が正常に保存されました';

  @override
  String get sign_in_to_access => 'サインインして自分だけの体験にアクセスする';

  @override
  String get continue_with_google => 'Googleで続ける';

  @override
  String get or => 'または';

  @override
  String get continue_without_account => 'アカウントなしで続ける';

  @override
  String get agree_terms => '続行することで、利用規約に同意したことになります';

  @override
  String get moneySources => '資金源';

  @override
  String get totalMoney => '合計金額';

  @override
  String sourcesAvailable(Object count) {
    return '$count 件の資金源';
  }

  @override
  String get cash => '現金';

  @override
  String get physicalCash => '現金（物理）';

  @override
  String get digitalWallet => 'デジタルウォレット';

  @override
  String get bankingAccount => '銀行口座';

  @override
  String get addMoneySource => '資金源を追加';

  @override
  String get sourceName => '資金源名';

  @override
  String get initialBalance => '初期残高';

  @override
  String get descriptionOptional => '説明（オプション）';

  @override
  String get iconLabel => 'アイコン:';

  @override
  String get colorLabel => '色';

  @override
  String get add => '追加';

  @override
  String get customSource => 'カスタム資金源';

  @override
  String get addRemoveMoney => '入出金';

  @override
  String get useMinusForRemove => 'マイナスで出金';

  @override
  String get update => '更新';

  @override
  String get editSource => '資金源を編集';

  @override
  String get description => '説明';

  @override
  String get deleteSource => '資金源を削除';

  @override
  String deleteSourceConfirm(Object name) {
    return '\"$name\"を削除してもよろしいですか？';
  }

  @override
  String get delete => '削除';

  @override
  String get chooseIcon => 'アイコンを選択';

  @override
  String get chooseColor => '色を選択';

  @override
  String get edit => '編集';

  @override
  String get typeLabel => '資金タイプ';

  @override
  String get typeCash => '現金';

  @override
  String get typeEwallet => '電子ウォレット';

  @override
  String get typeBanking => '銀行';

  @override
  String get typeOther => 'その他';

  @override
  String get currencyLabel => '通貨';

  @override
  String get currencyVnd => 'VND';

  @override
  String get currencyUsd => 'USD';

  @override
  String get accountDetail => 'アカウントの詳細';

  @override
  String get active => '有効';

  @override
  String get inactive => '無効';

  @override
  String get personalInformation => '個人情報';

  @override
  String get contactInformation => '連絡先情報';

  @override
  String get fullName => '氏名';

  @override
  String get enterFullName => '氏名を入力してください';

  @override
  String get dateOfBirth => '生年月日';

  @override
  String get day => '日';

  @override
  String get pleaseEnterName => '名前を入力してください';

  @override
  String get pleaseEnterValidNumbers => '日、月、年の有効な数字を入力してください';

  @override
  String get pleaseEnterValidDate => '有効な日付を入力してください';

  @override
  String get loginToAccess => 'サインインして自分だけの体験にアクセスする';

  @override
  String get continueAgreement => '続行することで、利用規約に同意したことになります';

  @override
  String savedInfoMessage(Object day, Object month, Object name, Object year) {
    return '保存されました：$name、$day/$month/$year生まれ';
  }

  @override
  String get success => '成功';

  @override
  String get error => 'エラー';

  @override
  String get email => 'メール';

  @override
  String get pleaseFillRequiredFields => '必須項目をすべて入力してください';

  @override
  String get invalidEmailFormat => 'メール形式が無効です';

  @override
  String get profileUpdateSuccess => 'プロフィールが正常に更新されました！';

  @override
  String get imagePickerFeatureComingSoon => '画像選択機能は後で追加されます';

  @override
  String get savings => '貯金';

  @override
  String get creditCard => 'クレジットカード';

  @override
  String get dining => '外食';

  @override
  String get travel => '旅行';

  @override
  String get salary => '給料';

  @override
  String get medical => '医療';

  @override
  String get transport => '交通';

  @override
  String get waterBill => '水道料金';

  @override
  String get noTransactions => '取引がありません。';

  @override
  String get done => '完了';

  @override
  String get restore => '復元';

  @override
  String get restoreDefault => 'デフォルトに戻す';

  @override
  String get restoreDefaultConfirm =>
      'すべてのカテゴリをデフォルトに戻しますか？ カスタムカテゴリはすべて削除されます。';

  @override
  String get titleNotification => '支出を管理';

  @override
  String get bodyNotification => '今日はどれくらい使いましたか？';

  @override
  String get notificationSettings => 'Cài đặt Thông báo';

  @override
  String get generalNotifications => 'Thông báo tổng quát';

  @override
  String get enableNotifications => 'Bật thông báo';

  @override
  String get enableNotificationsDesc => 'Nhận tất cả thông báo từ ứng dụng';

  @override
  String get notificationSound => 'Âm thanh thông báo';

  @override
  String get reminders => 'Nhắc nhở';

  @override
  String get dailyReminder => 'Nhắc nhở hàng ngày';

  @override
  String get dailyReminderDesc => 'Nhận thông báo nhắc nhở mỗi ngày';

  @override
  String get reminderTime => 'Thời gian nhắc nhở';

  @override
  String get weeklyReport => 'Báo cáo tuần';

  @override
  String get weeklyReportDesc => 'Nhận báo cáo tổng kết hàng tuần';

  @override
  String get testNotification => 'Gửi thông báo thử nghiệm';

  @override
  String get testNotificationSent => 'Đã gửi thông báo thử nghiệm!';

  @override
  String reminderTimeFormat(Object time) {
    return 'Thời gian nhắc nhở: $time';
  }

  @override
  String get allCategories => 'すべてのカテゴリ';

  @override
  String get dailyExpenses => '1日の支出';

  @override
  String get weeklyExpenses => '1週間の支出';

  @override
  String get monthlyExpenses => '1か月の支出';

  @override
  String get yearlyExpenses => '1年の支出';

  @override
  String get dailyIncome => '1日の収入';

  @override
  String get weeklyIncome => '1週間の収入';

  @override
  String get monthlyIncome => '1か月の収入';

  @override
  String get yearlyIncome => '1年の収入';

  @override
  String get today => '今日';

  @override
  String get yesterday => '昨日';

  @override
  String get dailyView => '日表示';

  @override
  String get weeklyView => '週表示';

  @override
  String get monthlyView => '月表示';

  @override
  String get yearlyView => '年表示';

  @override
  String get noData => 'データなし';

  @override
  String get noDataAvailable => 'データがありません';

  @override
  String get selectView => '表示を選択';

  @override
  String get selectCategory => 'カテゴリを選択';

  @override
  String get selectYear => '年を選択';

  @override
  String get selectMonth => '月を選択';

  @override
  String get selectWeek => '週を選択';

  @override
  String get scrollToSeeMore => 'スクロールしてもっと見る';

  @override
  String get iconHome => '家';

  @override
  String get iconShoppingCart => 'ショッピング';

  @override
  String get iconFastfood => '食事';

  @override
  String get iconPets => 'ペット';

  @override
  String get iconWork => '仕事';

  @override
  String get iconMusicNote => '音楽';

  @override
  String get iconMovie => 'エンターテイメント';

  @override
  String get iconSportsSoccer => 'スポーツ';

  @override
  String get iconFlight => '旅行';

  @override
  String get iconSchool => '教育';

  @override
  String get iconLocalCafe => 'カフェ';

  @override
  String get iconFitnessCenter => 'フィットネス';

  @override
  String get iconDirectionsCar => '交通';

  @override
  String get iconBeachAccess => 'レジャー';

  @override
  String get iconCameraAlt => '写真';

  @override
  String get iconBrush => 'アート';

  @override
  String get iconNature => '自然';

  @override
  String get iconHealing => '健康';

  @override
  String get iconCake => 'お祝い';

  @override
  String get iconFavorite => 'お気に入り';

  @override
  String get iconWbSunny => '天気';

  @override
  String get iconNightlightRound => '夜';

  @override
  String get iconLocalFlorist => '花';

  @override
  String get iconLightbulb => '公共料金';

  @override
  String get iconBook => '本';

  @override
  String get iconLuggage => '旅行';

  @override
  String get iconEvent => 'イベント';

  @override
  String get iconPayment => '支払い';

  @override
  String get iconCreditCard => 'クレジットカード';

  @override
  String get iconAccessTime => '時間';

  @override
  String get iconPeople => 'ソーシャル';

  @override
  String get iconPublic => '公共';

  @override
  String get iconSecurity => 'セキュリティ';

  @override
  String get iconWineBar => '飲み物';

  @override
  String get iconLocalBar => 'バー';

  @override
  String get iconRestaurant => 'レストラン';

  @override
  String get iconLocalGroceryStore => '食料品';

  @override
  String get iconBabyChangingStation => '赤ちゃん';

  @override
  String get iconBugReport => 'メンテナンス';

  @override
  String get iconBuild => 'ツール';

  @override
  String get iconAttachMoney => 'お金';

  @override
  String get iconCardGiftcard => 'ギフト';

  @override
  String get iconTrendingUp => '投資';

  @override
  String get iconStorefront => 'ビジネス';

  @override
  String get iconHouse => '不動産';

  @override
  String get iconSavings => '貯金';

  @override
  String get iconRedeem => '報酬';

  @override
  String get iconRefresh => '更新';

  @override
  String get iconSchoolIncome => '教育収入';

  @override
  String get iconMonetizationOn => '収益化';

  @override
  String get iconCurrencyBitcoin => '暗号通貨';

  @override
  String get iconWorkOutline => '仕事収入';

  @override
  String get iconMoreHoriz => 'その他';

  @override
  String get weekOf => 'theo tuần';

  @override
  String get dataSync => 'データ同期';

  @override
  String get lastSync => '最終同期';

  @override
  String get syncingData => 'データを同期中...';

  @override
  String get readyToSync => 'データ同期の準備ができました';

  @override
  String get uploadData => 'アップロード';

  @override
  String get downloadData => 'ダウンロード';

  @override
  String get logout => 'ログアウト';

  @override
  String get loggedOut => 'ログアウトしました';

  @override
  String get syncRequiresGoogleLogin => '同期には Google ログインが必要です';

  @override
  String get signInRequired => 'サインインが必要です';

  @override
  String get signInToManageProfile => 'プロフィールを管理してデータを同期するには、サインインしてください';

  @override
  String get signIn => 'サインイン';

  @override
  String get continueAsGuest => 'ゲストとして続ける';

  @override
  String get guestModeDescription => 'サインインせずに続けようとしています。デバイス間でデータを同期できません。';

  @override
  String get continues => '続ける';
}
