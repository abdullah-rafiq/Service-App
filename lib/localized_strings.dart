import 'app_locale.dart';

class L10n {
  static bool get _isUrdu => AppLocale.isUrdu();

  static String workerTodayOverviewTitle() =>
      _isUrdu ? 'آج کا خلاصہ' : "Today's overview";

  static String workerTodayOverviewSubtitle() => _isUrdu
      ? 'اپنی آنے والی درخواستوں اور کمائی کو منظم کریں۔'
      : 'Manage your incoming requests and track your earnings.';

  static String workerIncomingRequestsTitle() =>
      _isUrdu ? 'آنے والی درخواستیں' : 'Incoming requests';

  static String workerIncomingRequestsSubtitle() => _isUrdu
      ? 'ڈیمو جاب کی تفصیل دیکھنے کے لئے ٹیپ کریں۔ مستقبل میں یہاں حقیقی بکنگز نظر آئیں گی۔'
      : 'Tap to view a demo job detail. In the future this will show real-time bookings assigned to you.';

  static String workerMyJobsEarningsTitle() =>
      _isUrdu ? 'میری جابس اور کمائی' : 'My jobs & earnings';

  static String workerMyJobsEarningsSubtitle() => _isUrdu
      ? 'ڈیمو کمائی کا خلاصہ دیکھنے کے لئے ٹیپ کریں۔ بعد میں یہاں مکمل شدہ جابس اور ادائیگی کی ہسٹری آئے گی۔'
      : 'Tap to view a demo earnings summary. Later this will include completed jobs and payout history.';

  static String workerNavHome() => _isUrdu ? 'ہوم' : 'Home';
  static String workerNavJobs() => _isUrdu ? 'جابز' : 'Jobs';
  static String workerNavEarnings() => _isUrdu ? 'کمائی' : 'Earnings';
  static String workerNavMessages() => _isUrdu ? 'پیغامات' : 'Messages';
  static String workerNavProfile() => _isUrdu ? 'پروفائل' : 'Profile';

  // User bottom navigation
  static String userNavHome() => _isUrdu ? 'ہوم' : 'Home';
  static String userNavCategories() => _isUrdu ? 'کیٹیگریز' : 'Categories';
  static String userNavBookings() => _isUrdu ? 'بکنگز' : 'Bookings';
  static String userNavMessages() => _isUrdu ? 'پیغامات' : 'Messages';
  static String userNavProfile() => _isUrdu ? 'پروفائل' : 'Profile';

  // User home sections
  static String homeCategoriesTitle() =>
      _isUrdu ? 'کیٹیگریز' : 'Categories';

  static String homeFeaturedProvidersTitle() =>
      _isUrdu ? 'نمایاں فراہم کنندگان' : 'Featured Providers';

  static String homeUpcomingBookingsTitle() =>
      _isUrdu ? 'آنے والی بکنگز' : 'Upcoming Bookings';

  static String homeAllCategoriesTitle() =>
      _isUrdu ? 'تمام کیٹیگریز' : 'All Categories';

  static String settingsTitle() => _isUrdu ? 'ایپ سیٹنگز' : 'App settings';

  static String settingsNotificationsTitle() =>
      _isUrdu ? 'پش نوٹیفکیشنز' : 'Push notifications';

  static String settingsNotificationsSubtitle() => _isUrdu
      ? 'اپنی بکنگز اور آفرز کے بارے میں اپ ڈیٹس وصول کریں۔'
      : 'Receive updates about your bookings and offers.';

  static String settingsDarkModeTitle() =>
      _isUrdu ? 'ڈارک موڈ' : 'Dark mode';

  static String settingsDarkModeSubtitle() => _isUrdu
      ? 'ایپ کے لیے ڈارک تھیم استعمال کریں۔'
      : 'Use a dark theme for the application.';

  static String settingsLanguageTitle() => _isUrdu ? 'زبان' : 'Language';

  static String languageEnglish() => _isUrdu ? 'انگریزی' : 'English';

  static String languageUrdu() => _isUrdu ? 'اردو' : 'Urdu';

  // Admin bottom navigation
  static String adminNavAnalytics() =>
      _isUrdu ? 'تجزیات' : 'Analytics';

  static String adminNavWorkers() =>
      _isUrdu ? 'ورکرز' : 'Workers';

  static String adminNavNotifications() =>
      _isUrdu ? 'نوٹیفکیشنز' : 'Notifications';
}