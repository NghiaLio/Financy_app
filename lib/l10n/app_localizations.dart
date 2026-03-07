import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_vi.dart';

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
    Locale('en', 'GB'),
    Locale('en', 'US'),
    Locale('fr'),
    Locale('ja'),
    Locale('ru'),
    Locale('vi'),
  ];

  /// Màn hình hiển thị danh sách giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Sổ giao dịch'**
  String get transactionBook;

  /// Mục quản lý ví cá nhân
  ///
  /// In vi, this message translates to:
  /// **'Ví tiền'**
  String get wallet;

  /// Mục thống kê thu chi
  ///
  /// In vi, this message translates to:
  /// **'Thống kê'**
  String get statistics;

  /// Màn hình cài đặt hệ thống
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settings;

  /// No description provided for @hello.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào'**
  String get hello;

  /// No description provided for @monday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ hai'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ ba'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ tư'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ năm'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ sáu'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ bảy'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In vi, this message translates to:
  /// **'Chủ nhật'**
  String get sunday;

  /// No description provided for @myWallet.
  ///
  /// In vi, this message translates to:
  /// **'Ví của tôi'**
  String get myWallet;

  /// No description provided for @jan.
  ///
  /// In vi, this message translates to:
  /// **'Tháng 1'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In vi, this message translates to:
  /// **'Tháng 2'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In vi, this message translates to:
  /// **'Tháng 3'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In vi, this message translates to:
  /// **'Tháng 4'**
  String get apr;

  /// No description provided for @may.
  ///
  /// In vi, this message translates to:
  /// **'Tháng 5'**
  String get may;

  /// No description provided for @jun.
  ///
  /// In vi, this message translates to:
  /// **'Tháng 6'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In vi, this message translates to:
  /// **'Tháng 7'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In vi, this message translates to:
  /// **'Tháng 8'**
  String get aug;

  /// No description provided for @sep.
  ///
  /// In vi, this message translates to:
  /// **'Tháng 9'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In vi, this message translates to:
  /// **'Tháng 10'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In vi, this message translates to:
  /// **'Tháng 11'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In vi, this message translates to:
  /// **'Tháng 12'**
  String get dec;

  /// No description provided for @income.
  ///
  /// In vi, this message translates to:
  /// **'Thu thập'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu'**
  String get expense;

  /// No description provided for @myAccount.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản của tôi'**
  String get myAccount;

  /// No description provided for @selectGroup.
  ///
  /// In vi, this message translates to:
  /// **'Chọn nhóm giao dịch'**
  String get selectGroup;

  /// No description provided for @transactionName.
  ///
  /// In vi, this message translates to:
  /// **'Tên giao dịch'**
  String get transactionName;

  /// No description provided for @transactionAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền giao dịch'**
  String get transactionAmount;

  /// No description provided for @addFriend.
  ///
  /// In vi, this message translates to:
  /// **'Thêm bạn'**
  String get addFriend;

  /// No description provided for @dueDate.
  ///
  /// In vi, this message translates to:
  /// **'Đến hạn'**
  String get dueDate;

  /// No description provided for @note.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get note;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @category.
  ///
  /// In vi, this message translates to:
  /// **'Thể loại'**
  String get category;

  /// No description provided for @month.
  ///
  /// In vi, this message translates to:
  /// **'Tháng'**
  String get month;

  /// No description provided for @year.
  ///
  /// In vi, this message translates to:
  /// **'Năm'**
  String get year;

  /// No description provided for @week.
  ///
  /// In vi, this message translates to:
  /// **'Tuần'**
  String get week;

  /// No description provided for @statisticsBy.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê chi tiêu theo'**
  String get statisticsBy;

  /// No description provided for @linkBank.
  ///
  /// In vi, this message translates to:
  /// **'Liên kết ngân hàng'**
  String get linkBank;

  /// No description provided for @linkBankDialogTitle.
  ///
  /// In vi, this message translates to:
  /// **'Liên kết ngân hàng'**
  String get linkBankDialogTitle;

  /// No description provided for @linkBankDialogContent.
  ///
  /// In vi, this message translates to:
  /// **'Chức năng này sẽ được phát triển sau.'**
  String get linkBankDialogContent;

  /// No description provided for @close.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get close;

  /// No description provided for @compareExpenseTypes.
  ///
  /// In vi, this message translates to:
  /// **'So sánh các loại chi tiêu'**
  String get compareExpenseTypes;

  /// No description provided for @compareIncomeTypes.
  ///
  /// In vi, this message translates to:
  /// **'So sánh các loại thu nhập'**
  String get compareIncomeTypes;

  /// No description provided for @selectPeriod.
  ///
  /// In vi, this message translates to:
  /// **'Chọn kỳ'**
  String get selectPeriod;

  /// No description provided for @monthly.
  ///
  /// In vi, this message translates to:
  /// **'Hàng tháng'**
  String get monthly;

  /// No description provided for @weekly.
  ///
  /// In vi, this message translates to:
  /// **'Hàng tuần'**
  String get weekly;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @manageCategory.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý thể loại'**
  String get manageCategory;

  /// No description provided for @systemTheme.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện hệ thống'**
  String get systemTheme;

  /// No description provided for @userManagement.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý người dùng'**
  String get userManagement;

  /// No description provided for @account.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get account;

  /// No description provided for @notification.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get notification;

  /// No description provided for @chooseLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngôn ngữ'**
  String get chooseLanguage;

  /// No description provided for @themeSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt giao diện'**
  String get themeSettings;

  /// No description provided for @theme.
  ///
  /// In vi, this message translates to:
  /// **'Chủ đề'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In vi, this message translates to:
  /// **'Hệ thống'**
  String get system;

  /// No description provided for @primaryColor.
  ///
  /// In vi, this message translates to:
  /// **'Màu chủ đạo'**
  String get primaryColor;

  /// No description provided for @fontFamily.
  ///
  /// In vi, this message translates to:
  /// **'Phông chữ'**
  String get fontFamily;

  /// No description provided for @fontSize.
  ///
  /// In vi, this message translates to:
  /// **'Kích thước chữ'**
  String get fontSize;

  /// No description provided for @effect.
  ///
  /// In vi, this message translates to:
  /// **'Hiệu ứng'**
  String get effect;

  /// No description provided for @saveSettings.
  ///
  /// In vi, this message translates to:
  /// **'Lưu cài đặt'**
  String get saveSettings;

  /// No description provided for @previewNote.
  ///
  /// In vi, this message translates to:
  /// **'Đây là giao diện xem trước với các cài đặt hiện tại'**
  String get previewNote;

  /// No description provided for @languageChanged.
  ///
  /// In vi, this message translates to:
  /// **'Thay đổi ngôn ngữ thành công'**
  String get languageChanged;

  /// No description provided for @settingsSaved.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt đã được lưu thành công'**
  String get settingsSaved;

  /// No description provided for @sign_in_to_access.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập để truy cập trải nghiệm cá nhân của bạn'**
  String get sign_in_to_access;

  /// No description provided for @continue_with_google.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục với Google'**
  String get continue_with_google;

  /// No description provided for @or.
  ///
  /// In vi, this message translates to:
  /// **'hoặc'**
  String get or;

  /// No description provided for @continue_without_account.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục mà không dùng tài khoản'**
  String get continue_without_account;

  /// No description provided for @agree_terms.
  ///
  /// In vi, this message translates to:
  /// **'Bằng cách tiếp tục, bạn đồng ý với Điều khoản dịch vụ của chúng tôi'**
  String get agree_terms;

  /// No description provided for @moneySources.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn tiền'**
  String get moneySources;

  /// No description provided for @totalMoney.
  ///
  /// In vi, this message translates to:
  /// **'Tổng tiền'**
  String get totalMoney;

  /// No description provided for @sourcesAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Có {count} nguồn tiền'**
  String sourcesAvailable(Object count);

  /// No description provided for @cash.
  ///
  /// In vi, this message translates to:
  /// **'Tiền mặt'**
  String get cash;

  /// No description provided for @physicalCash.
  ///
  /// In vi, this message translates to:
  /// **'Tiền mặt vật lý'**
  String get physicalCash;

  /// No description provided for @digitalWallet.
  ///
  /// In vi, this message translates to:
  /// **'Ví điện tử'**
  String get digitalWallet;

  /// No description provided for @bankingAccount.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản ngân hàng'**
  String get bankingAccount;

  /// No description provided for @addMoneySource.
  ///
  /// In vi, this message translates to:
  /// **'Thêm nguồn tiền'**
  String get addMoneySource;

  /// No description provided for @sourceName.
  ///
  /// In vi, this message translates to:
  /// **'Tên nguồn tiền'**
  String get sourceName;

  /// No description provided for @initialBalance.
  ///
  /// In vi, this message translates to:
  /// **'Số dư ban đầu'**
  String get initialBalance;

  /// No description provided for @descriptionOptional.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả (tuỳ chọn)'**
  String get descriptionOptional;

  /// No description provided for @iconLabel.
  ///
  /// In vi, this message translates to:
  /// **'Biểu tượng:'**
  String get iconLabel;

  /// No description provided for @colorLabel.
  ///
  /// In vi, this message translates to:
  /// **'Màu sắc:'**
  String get colorLabel;

  /// No description provided for @add.
  ///
  /// In vi, this message translates to:
  /// **'Thêm giao dịch'**
  String get add;

  /// No description provided for @customSource.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn tuỳ chỉnh'**
  String get customSource;

  /// No description provided for @addRemoveMoney.
  ///
  /// In vi, this message translates to:
  /// **'Thêm/Xoá tiền'**
  String get addRemoveMoney;

  /// No description provided for @useMinusForRemove.
  ///
  /// In vi, this message translates to:
  /// **'Dùng dấu - để xoá tiền'**
  String get useMinusForRemove;

  /// No description provided for @update.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật'**
  String get update;

  /// No description provided for @editSource.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa nguồn'**
  String get editSource;

  /// No description provided for @description.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả'**
  String get description;

  /// No description provided for @deleteSource.
  ///
  /// In vi, this message translates to:
  /// **'Xoá nguồn'**
  String get deleteSource;

  /// No description provided for @deleteSourceConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xoá \"{name}\"?'**
  String deleteSourceConfirm(Object name);

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xoá'**
  String get delete;

  /// No description provided for @chooseIcon.
  ///
  /// In vi, this message translates to:
  /// **'Chọn biểu tượng'**
  String get chooseIcon;

  /// No description provided for @chooseColor.
  ///
  /// In vi, this message translates to:
  /// **'Chọn màu sắc'**
  String get chooseColor;

  /// No description provided for @edit.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa'**
  String get edit;

  /// No description provided for @typeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Loại nguồn tiền'**
  String get typeLabel;

  /// No description provided for @typeCash.
  ///
  /// In vi, this message translates to:
  /// **'Tiền mặt'**
  String get typeCash;

  /// No description provided for @typeEwallet.
  ///
  /// In vi, this message translates to:
  /// **'Ví điện tử'**
  String get typeEwallet;

  /// No description provided for @typeBanking.
  ///
  /// In vi, this message translates to:
  /// **'Ngân hàng'**
  String get typeBanking;

  /// No description provided for @typeOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get typeOther;

  /// No description provided for @currencyLabel.
  ///
  /// In vi, this message translates to:
  /// **'Loại tiền tệ'**
  String get currencyLabel;

  /// No description provided for @currencyVnd.
  ///
  /// In vi, this message translates to:
  /// **'VND'**
  String get currencyVnd;

  /// No description provided for @currencyUsd.
  ///
  /// In vi, this message translates to:
  /// **'USD'**
  String get currencyUsd;

  /// No description provided for @accountDetail.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết tài khoản'**
  String get accountDetail;

  /// No description provided for @active.
  ///
  /// In vi, this message translates to:
  /// **'Đang hoạt động'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In vi, this message translates to:
  /// **'Ngừng hoạt động'**
  String get inactive;

  /// No description provided for @personalInformation.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin cá nhân'**
  String get personalInformation;

  /// No description provided for @contactInformation.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin liên hệ'**
  String get contactInformation;

  /// No description provided for @fullName.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In vi, this message translates to:
  /// **'Nhập họ và tên'**
  String get enterFullName;

  /// No description provided for @dateOfBirth.
  ///
  /// In vi, this message translates to:
  /// **'Ngày sinh'**
  String get dateOfBirth;

  /// No description provided for @day.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get day;

  /// No description provided for @pleaseEnterName.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterValidNumbers.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập số hợp lệ cho ngày, tháng, năm'**
  String get pleaseEnterValidNumbers;

  /// No description provided for @pleaseEnterValidDate.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập ngày hợp lệ'**
  String get pleaseEnterValidDate;

  /// No description provided for @loginToAccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập để truy cập trải nghiệm cá nhân của bạn'**
  String get loginToAccess;

  /// No description provided for @continueAgreement.
  ///
  /// In vi, this message translates to:
  /// **'Bằng cách tiếp tục, bạn đồng ý với Điều khoản dịch vụ của chúng tôi'**
  String get continueAgreement;

  /// No description provided for @savedInfoMessage.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu: {name}, sinh ngày {day}/{month}/{year}'**
  String savedInfoMessage(Object day, Object month, Object name, Object year);

  /// No description provided for @success.
  ///
  /// In vi, this message translates to:
  /// **'Thành công'**
  String get success;

  /// No description provided for @error.
  ///
  /// In vi, this message translates to:
  /// **'Thất bại'**
  String get error;

  /// No description provided for @email.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @pleaseFillRequiredFields.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng điền đầy đủ thông tin bắt buộc'**
  String get pleaseFillRequiredFields;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In vi, this message translates to:
  /// **'Định dạng email không hợp lệ'**
  String get invalidEmailFormat;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật hồ sơ thành công!'**
  String get profileUpdateSuccess;

  /// No description provided for @imagePickerFeatureComingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Chức năng chọn ảnh sẽ được thêm vào sau'**
  String get imagePickerFeatureComingSoon;

  /// No description provided for @savings.
  ///
  /// In vi, this message translates to:
  /// **'Tiết kiệm'**
  String get savings;

  /// No description provided for @creditCard.
  ///
  /// In vi, this message translates to:
  /// **'Thẻ tín dụng'**
  String get creditCard;

  /// No description provided for @dining.
  ///
  /// In vi, this message translates to:
  /// **'Ăn uống'**
  String get dining;

  /// No description provided for @travel.
  ///
  /// In vi, this message translates to:
  /// **'Du lịch'**
  String get travel;

  /// No description provided for @salary.
  ///
  /// In vi, this message translates to:
  /// **'Lương'**
  String get salary;

  /// No description provided for @medical.
  ///
  /// In vi, this message translates to:
  /// **'Y tế'**
  String get medical;

  /// No description provided for @transport.
  ///
  /// In vi, this message translates to:
  /// **'Di chuyển'**
  String get transport;

  /// No description provided for @waterBill.
  ///
  /// In vi, this message translates to:
  /// **'Tiền nước'**
  String get waterBill;

  /// No description provided for @noTransactions.
  ///
  /// In vi, this message translates to:
  /// **'Không có giao dịch nào.'**
  String get noTransactions;

  /// No description provided for @done.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tất'**
  String get done;

  /// No description provided for @restore.
  ///
  /// In vi, this message translates to:
  /// **'Khôi phục'**
  String get restore;

  /// No description provided for @restoreDefault.
  ///
  /// In vi, this message translates to:
  /// **'Khôi phục mặc định'**
  String get restoreDefault;

  /// No description provided for @restoreDefaultConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có muốn khôi phục tất cả danh mục về mặc định không? Điều này sẽ xóa tất cả danh mục tùy chỉnh.'**
  String get restoreDefaultConfirm;

  /// No description provided for @titleNotification.
  ///
  /// In vi, this message translates to:
  /// **'Kiếm soát chi tiêu'**
  String get titleNotification;

  /// No description provided for @bodyNotification.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay bạn đã chi tiêu bao nhiêu?'**
  String get bodyNotification;

  /// No description provided for @notificationSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt Thông báo'**
  String get notificationSettings;

  /// No description provided for @generalNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo tổng quát'**
  String get generalNotifications;

  /// No description provided for @enableNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Bật thông báo'**
  String get enableNotifications;

  /// No description provided for @enableNotificationsDesc.
  ///
  /// In vi, this message translates to:
  /// **'Nhận tất cả thông báo từ ứng dụng'**
  String get enableNotificationsDesc;

  /// No description provided for @notificationSound.
  ///
  /// In vi, this message translates to:
  /// **'Âm thanh thông báo'**
  String get notificationSound;

  /// No description provided for @reminders.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nhở'**
  String get reminders;

  /// No description provided for @dailyReminder.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nhở hàng ngày'**
  String get dailyReminder;

  /// No description provided for @dailyReminderDesc.
  ///
  /// In vi, this message translates to:
  /// **'Nhận thông báo nhắc nhở mỗi ngày'**
  String get dailyReminderDesc;

  /// No description provided for @reminderTime.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian nhắc nhở'**
  String get reminderTime;

  /// No description provided for @weeklyReport.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo tuần'**
  String get weeklyReport;

  /// No description provided for @weeklyReportDesc.
  ///
  /// In vi, this message translates to:
  /// **'Nhận báo cáo tổng kết hàng tuần'**
  String get weeklyReportDesc;

  /// No description provided for @testNotification.
  ///
  /// In vi, this message translates to:
  /// **'Gửi thông báo thử nghiệm'**
  String get testNotification;

  /// No description provided for @testNotificationSent.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi thông báo thử nghiệm!'**
  String get testNotificationSent;

  /// No description provided for @reminderTimeFormat.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian nhắc nhở: {time}'**
  String reminderTimeFormat(Object time);

  /// Text for all categories filter option
  ///
  /// In vi, this message translates to:
  /// **'Tất cả danh mục'**
  String get allCategories;

  /// Title for daily expenses chart
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu hàng ngày'**
  String get dailyExpenses;

  /// Title for weekly expenses chart
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu hàng tuần'**
  String get weeklyExpenses;

  /// Title for monthly expenses chart
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu hàng tháng'**
  String get monthlyExpenses;

  /// Title for yearly expenses chart
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu hàng năm'**
  String get yearlyExpenses;

  /// Title for daily income chart
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập hàng ngày'**
  String get dailyIncome;

  /// Title for weekly income chart
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập hàng tuần'**
  String get weeklyIncome;

  /// Title for monthly income chart
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập hàng tháng'**
  String get monthlyIncome;

  /// Title for yearly income chart
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập hàng năm'**
  String get yearlyIncome;

  /// Text for today
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get today;

  /// Text for yesterday
  ///
  /// In vi, this message translates to:
  /// **'Hôm qua'**
  String get yesterday;

  /// Daily view option
  ///
  /// In vi, this message translates to:
  /// **'Xem hàng ngày'**
  String get dailyView;

  /// Weekly view option
  ///
  /// In vi, this message translates to:
  /// **'Xem hàng tuần'**
  String get weeklyView;

  /// Monthly view option
  ///
  /// In vi, this message translates to:
  /// **'Xem hàng tháng'**
  String get monthlyView;

  /// Yearly view option
  ///
  /// In vi, this message translates to:
  /// **'Xem hàng năm'**
  String get yearlyView;

  /// Text when no data is available
  ///
  /// In vi, this message translates to:
  /// **'Không có dữ liệu'**
  String get noData;

  /// Text when no data is available for legend
  ///
  /// In vi, this message translates to:
  /// **'Không có dữ liệu'**
  String get noDataAvailable;

  /// Title for view selector dialog
  ///
  /// In vi, this message translates to:
  /// **'Chọn chế độ xem'**
  String get selectView;

  /// Title for category selector dialog
  ///
  /// In vi, this message translates to:
  /// **'Chọn danh mục'**
  String get selectCategory;

  /// Title for year selector dialog
  ///
  /// In vi, this message translates to:
  /// **'Chọn năm'**
  String get selectYear;

  /// Title for month selector dialog
  ///
  /// In vi, this message translates to:
  /// **'Chọn tháng'**
  String get selectMonth;

  /// Title for week selector dialog
  ///
  /// In vi, this message translates to:
  /// **'Chọn tuần'**
  String get selectWeek;

  /// Text indicating user can scroll to see more data
  ///
  /// In vi, this message translates to:
  /// **'Cuộn để xem thêm'**
  String get scrollToSeeMore;

  /// No description provided for @iconHome.
  ///
  /// In vi, this message translates to:
  /// **'Nhà'**
  String get iconHome;

  /// No description provided for @iconShoppingCart.
  ///
  /// In vi, this message translates to:
  /// **'Mua sắm'**
  String get iconShoppingCart;

  /// No description provided for @iconFastfood.
  ///
  /// In vi, this message translates to:
  /// **'Ăn uống'**
  String get iconFastfood;

  /// No description provided for @iconPets.
  ///
  /// In vi, this message translates to:
  /// **'Thú cưng'**
  String get iconPets;

  /// No description provided for @iconWork.
  ///
  /// In vi, this message translates to:
  /// **'Công việc'**
  String get iconWork;

  /// No description provided for @iconMusicNote.
  ///
  /// In vi, this message translates to:
  /// **'Âm nhạc'**
  String get iconMusicNote;

  /// No description provided for @iconMovie.
  ///
  /// In vi, this message translates to:
  /// **'Giải trí'**
  String get iconMovie;

  /// No description provided for @iconSportsSoccer.
  ///
  /// In vi, this message translates to:
  /// **'Thể thao'**
  String get iconSportsSoccer;

  /// No description provided for @iconFlight.
  ///
  /// In vi, this message translates to:
  /// **'Du lịch'**
  String get iconFlight;

  /// No description provided for @iconSchool.
  ///
  /// In vi, this message translates to:
  /// **'Giáo dục'**
  String get iconSchool;

  /// No description provided for @iconLocalCafe.
  ///
  /// In vi, this message translates to:
  /// **'Cà phê'**
  String get iconLocalCafe;

  /// No description provided for @iconFitnessCenter.
  ///
  /// In vi, this message translates to:
  /// **'Thể dục'**
  String get iconFitnessCenter;

  /// No description provided for @iconDirectionsCar.
  ///
  /// In vi, this message translates to:
  /// **'Giao thông'**
  String get iconDirectionsCar;

  /// No description provided for @iconBeachAccess.
  ///
  /// In vi, this message translates to:
  /// **'Giải trí'**
  String get iconBeachAccess;

  /// No description provided for @iconCameraAlt.
  ///
  /// In vi, this message translates to:
  /// **'Chụp ảnh'**
  String get iconCameraAlt;

  /// No description provided for @iconBrush.
  ///
  /// In vi, this message translates to:
  /// **'Nghệ thuật'**
  String get iconBrush;

  /// No description provided for @iconNature.
  ///
  /// In vi, this message translates to:
  /// **'Thiên nhiên'**
  String get iconNature;

  /// No description provided for @iconHealing.
  ///
  /// In vi, this message translates to:
  /// **'Sức khỏe'**
  String get iconHealing;

  /// No description provided for @iconCake.
  ///
  /// In vi, this message translates to:
  /// **'Lễ kỷ niệm'**
  String get iconCake;

  /// No description provided for @iconFavorite.
  ///
  /// In vi, this message translates to:
  /// **'Yêu thích'**
  String get iconFavorite;

  /// No description provided for @iconWbSunny.
  ///
  /// In vi, this message translates to:
  /// **'Thời tiết'**
  String get iconWbSunny;

  /// No description provided for @iconNightlightRound.
  ///
  /// In vi, this message translates to:
  /// **'Đêm'**
  String get iconNightlightRound;

  /// No description provided for @iconLocalFlorist.
  ///
  /// In vi, this message translates to:
  /// **'Hoa'**
  String get iconLocalFlorist;

  /// No description provided for @iconLightbulb.
  ///
  /// In vi, this message translates to:
  /// **'Tiện ích'**
  String get iconLightbulb;

  /// No description provided for @iconBook.
  ///
  /// In vi, this message translates to:
  /// **'Sách'**
  String get iconBook;

  /// No description provided for @iconLuggage.
  ///
  /// In vi, this message translates to:
  /// **'Du lịch'**
  String get iconLuggage;

  /// No description provided for @iconEvent.
  ///
  /// In vi, this message translates to:
  /// **'Sự kiện'**
  String get iconEvent;

  /// No description provided for @iconPayment.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán'**
  String get iconPayment;

  /// No description provided for @iconCreditCard.
  ///
  /// In vi, this message translates to:
  /// **'Thẻ tín dụng'**
  String get iconCreditCard;

  /// No description provided for @iconAccessTime.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian'**
  String get iconAccessTime;

  /// No description provided for @iconPeople.
  ///
  /// In vi, this message translates to:
  /// **'Xã hội'**
  String get iconPeople;

  /// No description provided for @iconPublic.
  ///
  /// In vi, this message translates to:
  /// **'Công cộng'**
  String get iconPublic;

  /// No description provided for @iconSecurity.
  ///
  /// In vi, this message translates to:
  /// **'Bảo mật'**
  String get iconSecurity;

  /// No description provided for @iconWineBar.
  ///
  /// In vi, this message translates to:
  /// **'Đồ uống'**
  String get iconWineBar;

  /// No description provided for @iconLocalBar.
  ///
  /// In vi, this message translates to:
  /// **'Quán bar'**
  String get iconLocalBar;

  /// No description provided for @iconRestaurant.
  ///
  /// In vi, this message translates to:
  /// **'Nhà hàng'**
  String get iconRestaurant;

  /// No description provided for @iconLocalGroceryStore.
  ///
  /// In vi, this message translates to:
  /// **'Tạp hóa'**
  String get iconLocalGroceryStore;

  /// No description provided for @iconBabyChangingStation.
  ///
  /// In vi, this message translates to:
  /// **'Em bé'**
  String get iconBabyChangingStation;

  /// No description provided for @iconBugReport.
  ///
  /// In vi, this message translates to:
  /// **'Bảo trì'**
  String get iconBugReport;

  /// No description provided for @iconBuild.
  ///
  /// In vi, this message translates to:
  /// **'Công cụ'**
  String get iconBuild;

  /// No description provided for @iconAttachMoney.
  ///
  /// In vi, this message translates to:
  /// **'Tiền'**
  String get iconAttachMoney;

  /// No description provided for @iconCardGiftcard.
  ///
  /// In vi, this message translates to:
  /// **'Quà tặng'**
  String get iconCardGiftcard;

  /// No description provided for @iconTrendingUp.
  ///
  /// In vi, this message translates to:
  /// **'Đầu tư'**
  String get iconTrendingUp;

  /// No description provided for @iconStorefront.
  ///
  /// In vi, this message translates to:
  /// **'Kinh doanh'**
  String get iconStorefront;

  /// No description provided for @iconHouse.
  ///
  /// In vi, this message translates to:
  /// **'Bất động sản'**
  String get iconHouse;

  /// No description provided for @iconSavings.
  ///
  /// In vi, this message translates to:
  /// **'Tiết kiệm'**
  String get iconSavings;

  /// No description provided for @iconRedeem.
  ///
  /// In vi, this message translates to:
  /// **'Thưởng'**
  String get iconRedeem;

  /// No description provided for @iconRefresh.
  ///
  /// In vi, this message translates to:
  /// **'Làm mới'**
  String get iconRefresh;

  /// No description provided for @iconSchoolIncome.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập giáo dục'**
  String get iconSchoolIncome;

  /// No description provided for @iconMonetizationOn.
  ///
  /// In vi, this message translates to:
  /// **'Kiếm tiền'**
  String get iconMonetizationOn;

  /// No description provided for @iconCurrencyBitcoin.
  ///
  /// In vi, this message translates to:
  /// **'Tiền điện tử'**
  String get iconCurrencyBitcoin;

  /// No description provided for @iconWorkOutline.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập công việc'**
  String get iconWorkOutline;

  /// No description provided for @iconMoreHoriz.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get iconMoreHoriz;

  /// No description provided for @weekOf.
  ///
  /// In vi, this message translates to:
  /// **'theo tuần'**
  String get weekOf;

  /// No description provided for @dataSync.
  ///
  /// In vi, this message translates to:
  /// **'Đồng bộ dữ liệu'**
  String get dataSync;

  /// No description provided for @lastSync.
  ///
  /// In vi, this message translates to:
  /// **'Lần đồng bộ cuối'**
  String get lastSync;

  /// No description provided for @syncingData.
  ///
  /// In vi, this message translates to:
  /// **'Đang đồng bộ dữ liệu...'**
  String get syncingData;

  /// No description provided for @readyToSync.
  ///
  /// In vi, this message translates to:
  /// **'Sẵn sàng đồng bộ dữ liệu của bạn'**
  String get readyToSync;

  /// No description provided for @uploadData.
  ///
  /// In vi, this message translates to:
  /// **'Tải lên'**
  String get uploadData;

  /// No description provided for @downloadData.
  ///
  /// In vi, this message translates to:
  /// **'Tải xuống'**
  String get downloadData;

  /// No description provided for @logout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logout;

  /// No description provided for @loggedOut.
  ///
  /// In vi, this message translates to:
  /// **'Đã đăng xuất'**
  String get loggedOut;

  /// No description provided for @syncRequiresGoogleLogin.
  ///
  /// In vi, this message translates to:
  /// **'Đồng bộ yêu cầu đăng nhập Google'**
  String get syncRequiresGoogleLogin;

  /// No description provided for @signInRequired.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu đăng nhập'**
  String get signInRequired;

  /// No description provided for @signInToManageProfile.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập với Google để quản lý hồ sơ và đồng bộ dữ liệu trên các thiết bị.'**
  String get signInToManageProfile;

  /// No description provided for @signIn.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get signIn;

  /// No description provided for @continueAsGuest.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục với tư cách khách'**
  String get continueAsGuest;

  /// No description provided for @guestModeDescription.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có thể sử dụng ứng dụng mà không cần đăng nhập. Đăng nhập sau để đồng bộ dữ liệu trên các thiết bị.'**
  String get guestModeDescription;

  /// No description provided for @continues.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get continues;
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
      <String>['en', 'fr', 'ja', 'ru', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'GB':
            return AppLocalizationsEnGb();
          case 'US':
            return AppLocalizationsEnUs();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ru':
      return AppLocalizationsRu();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
