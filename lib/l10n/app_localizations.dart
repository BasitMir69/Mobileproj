import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Campus Wave',
      'home': 'Home',
      'facilities': 'Facilities',
      'appointments': 'Appointments',
      'settings': 'Settings',
      'logout': 'Logout',
      'campusInfo': 'Campus Info',
      'aiChatbot': 'AI Chatbot',
      'campuses': 'Campuses',
      'upcomingEvents': 'Upcoming Events',
      'campusNews': 'Campus News',
      'viewAll': 'View All',
      'readMore': 'Read More',
      'myAppointments': 'My Appointments',
      'appearance': 'Appearance',
      'darkMode': 'Dark Mode',
      'language': 'Language',
      'notifications': 'Notifications',
      'sendFeedback': 'Send Feedback',
      'clearDemo': 'Clear Bookings',
      'loginSuccess': 'Login successful!',
      'loginFailed': 'Login failed',
      'email': 'Email',
      'password': 'Password',
      'login': 'Log In',
      'createAccount': 'Create Account',
      'exploreGuest': 'Explore as Guest',
      'welcome': 'Welcome to\nCampus Wave',
      'guide': 'Your guide to school campuses',
      'welcomeTo': 'Welcome to',
      'yourGuide': 'Your guide to school campuses',
      'campusAccess': 'Campus Access',
      'register': 'Register',
      'or': 'or',
      'exploreAsGuest': 'Explore as Guest',
      'limitedMode': 'Limited Mode',
      'fullName': 'Full name',
      'enterName': 'Enter a name',
      'enterValidEmail': 'Enter a valid email',
      'passwordTooShort': 'Password too short',
      'secureAccess': 'Secure Access',
      'back': 'Back',
      'signupSuccess': 'Signup successful!',
      'signupFailed': 'Signup failed',
      'lgsCampuses': 'LGS Campuses',
      'historyProfile': 'History & Profile',
      'keyFeatures': 'Key Features',
      'academicHighlights': 'Academic Highlights',
      'facilityHighlights': 'Facility Highlights',
      'photoCaptions': 'Photo Captions',
      'moreInfo': 'More Information',
      'moreAbout': 'More About',
      'close': 'Close',
      'professorsAppointments': 'Professors & Appointments',
      'viewGallery': 'View More Photos • Gallery',
      'openGalleryPlaceholder': 'Open gallery - replace with real photos',
      'findRightSchool': 'Find the right school',
      'browseCompareApply': 'Browse campuses, compare, and apply from anywhere',
      'startAdmission': 'Start Admission',
      'newAdmission': 'New Admission',
      'savedForms': 'Saved Forms',
      'offlineDrafts': 'Offline admission drafts',
      'noPublishedNews': 'No published news yet',
      'checkBackSoon': 'Check back soon',
      'yourAdmissions': 'Your Admissions',
      'noSavedForms': 'No saved forms yet',
      'startNewAdmission': 'Start a new admission form',
      'viewAllSavedForms': 'View all saved forms',
      'professors': 'Professors',
      'browseFaculty': 'Browse faculty directory',
      'exploreCampuses': 'Explore Campuses',
      'professorOverview': 'Professor Overview',
      'pendingApprovals': 'Pending Approvals',
      'manageAppointments': 'Manage Appointments',
      'reviewNow': 'Review now',
      'noAppointments': 'No appointments yet',
      'upcomingAppointments': 'Upcoming Appointments',
      'viewAllAppointments': 'View all appointments',
      'admissionStatus': 'Admission Status',
      'noAdmissionsYet': 'No admissions yet',
    },
    'ur': {
      'title': 'کیمپس ویو',
      'home': 'ہوم',
      'facilities': 'سہولیات',
      'appointments': 'ملاقاتیں',
      'settings': 'ترتیبات',
      'logout': 'لاگ آؤٹ',
      'campusInfo': 'کیمپس کی معلومات',
      'aiChatbot': 'اے آئی چیٹ بوٹ',
      'campuses': 'کیمپس',
      'upcomingEvents': 'آنے والے واقعات',
      'campusNews': 'کیمپس کی خبریں',
      'viewAll': 'سب دیکھیں',
      'readMore': 'مزید پڑھیں',
      'myAppointments': 'میری ملاقاتیں',
      'appearance': 'ظاہری شکل',
      'darkMode': 'ڈارک موڈ',
      'language': 'زبان',
      'notifications': 'اطلاعات',
      'sendFeedback': 'رائے بھیجیں',
      'clearDemo': 'بکنگز صاف کریں',
      'loginSuccess': 'لاگ ان کامیاب!',
      'loginFailed': 'لاگ ان ناکام',
      'email': 'ای میل',
      'password': 'پاس ورڈ',
      'login': 'لاگ ان کریں',
      'createAccount': 'اکاؤنٹ بنائیں',
      'exploreGuest': 'مہمان کے طور پر دیکھیں',
      'welcome': 'کیمپس ویو میں\nخوش آمدید',
      'guide': 'اسکول کیمپس کے لیے آپ کی رہنمائی',
      'welcomeTo': 'خوش آمدید',
      'yourGuide': 'اسکول کیمپس کے لیے آپ کی رہنمائی',
      'campusAccess': 'کیمپس تک رسائی',
      'register': 'رجسٹر کریں',
      'or': 'یا',
      'exploreAsGuest': 'مہمان کے طور پر دیکھیں',
      'limitedMode': 'محدود موڈ',
      'fullName': 'پورا نام',
      'enterName': 'نام درج کریں',
      'enterValidEmail': 'درست ای میل درج کریں',
      'passwordTooShort': 'پاس ورڈ بہت چھوٹا ہے',
      'secureAccess': 'محفوظ رسائی',
      'back': 'واپس',
      'signupSuccess': 'سائن اپ کامیاب!',
      'signupFailed': 'سائن اپ ناکام',
      'lgsCampuses': 'ایل جی ایس کیمپس',
      'historyProfile': 'تاریخ اور پروفائل',
      'keyFeatures': 'اہم خصوصیات',
      'academicHighlights': 'تعلیمی جھلکیاں',
      'facilityHighlights': 'سہولیات کی جھلکیاں',
      'photoCaptions': 'تصویر کے عنوانات',
      'moreInfo': 'مزید معلومات',
      'moreAbout': 'مزید کے بارے میں',
      'close': 'بند کریں',
      'professorsAppointments': 'پروفیسرز اور ملاقاتیں',
      'viewGallery': 'مزید تصاویر دیکھیں • گیلری',
      'openGalleryPlaceholder': 'گیلری کھولیں - اصلی تصاویر کے ساتھ تبدیل کریں',
      'findRightSchool': 'صحیح اسکول تلاش کریں',
      'browseCompareApply':
          'کیمپس دیکھیں، موازنہ کریں اور کہیں سے بھی درخواست دیں',
      'startAdmission': 'داخلہ شروع کریں',
      'newAdmission': 'نیا داخلہ',
      'savedForms': 'محفوظ شدہ فارم',
      'offlineDrafts': 'آف لائن داخلہ مسودے',
      'noPublishedNews': 'ابھی کوئی شائع شدہ خبر نہیں',
      'checkBackSoon': 'جلد دوبارہ چیک کریں',
      'yourAdmissions': 'آپ کے داخلے',
      'noSavedForms': 'ابھی کوئی محفوظ فارم نہیں',
      'startNewAdmission': 'نیا داخلہ فارم شروع کریں',
      'viewAllSavedForms': 'تمام محفوظ فارم دیکھیں',
      'professors': 'اساتذہ',
      'browseFaculty': 'فیکلٹی ڈائریکٹری دیکھیں',
      'exploreCampuses': 'کیمپس دریافت کریں',
      'professorOverview': 'پروفیسر کا جائزہ',
      'pendingApprovals': 'زیر التواء منظوری',
      'manageAppointments': 'ملاقاتیں منظم کریں',
      'reviewNow': 'ابھی جائزہ لیں',
      'noAppointments': 'ابھی کوئی ملاقات نہیں',
      'upcomingAppointments': 'آئندہ ملاقاتیں',
      'viewAllAppointments': 'تمام ملاقاتیں دیکھیں',
      'admissionStatus': 'داخلہ کی حالت',
      'noAdmissionsYet': 'ابھی کوئی داخلہ نہیں',
    },
  };

  String get title => _localizedValues[locale.languageCode]!['title']!;
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get facilities =>
      _localizedValues[locale.languageCode]!['facilities']!;
  String get appointments =>
      _localizedValues[locale.languageCode]!['appointments']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get campusInfo =>
      _localizedValues[locale.languageCode]!['campusInfo']!;
  String get aiChatbot => _localizedValues[locale.languageCode]!['aiChatbot']!;
  String get campuses => _localizedValues[locale.languageCode]!['campuses']!;
  String get upcomingEvents =>
      _localizedValues[locale.languageCode]!['upcomingEvents']!;
  String get campusNews =>
      _localizedValues[locale.languageCode]!['campusNews']!;
  String get viewAll => _localizedValues[locale.languageCode]!['viewAll']!;
  String get readMore => _localizedValues[locale.languageCode]!['readMore']!;
  String get myAppointments =>
      _localizedValues[locale.languageCode]!['myAppointments']!;
  String get appearance =>
      _localizedValues[locale.languageCode]!['appearance']!;
  String get darkMode => _localizedValues[locale.languageCode]!['darkMode']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get notifications =>
      _localizedValues[locale.languageCode]!['notifications']!;
  String get sendFeedback =>
      _localizedValues[locale.languageCode]!['sendFeedback']!;
  String get clearDemo => _localizedValues[locale.languageCode]!['clearDemo']!;
  String get loginSuccess =>
      _localizedValues[locale.languageCode]!['loginSuccess']!;
  String get loginFailed =>
      _localizedValues[locale.languageCode]!['loginFailed']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get createAccount =>
      _localizedValues[locale.languageCode]!['createAccount']!;
  String get exploreGuest =>
      _localizedValues[locale.languageCode]!['exploreGuest']!;
  String get welcome => _localizedValues[locale.languageCode]!['welcome']!;
  String get guide => _localizedValues[locale.languageCode]!['guide']!;
  String get welcomeTo => _localizedValues[locale.languageCode]!['welcomeTo']!;
  String get yourGuide => _localizedValues[locale.languageCode]!['yourGuide']!;
  String get campusAccess =>
      _localizedValues[locale.languageCode]!['campusAccess']!;
  String get register => _localizedValues[locale.languageCode]!['register']!;
  String get or => _localizedValues[locale.languageCode]!['or']!;
  String get exploreAsGuest =>
      _localizedValues[locale.languageCode]!['exploreAsGuest']!;
  String get limitedMode =>
      _localizedValues[locale.languageCode]!['limitedMode']!;
  String get fullName => _localizedValues[locale.languageCode]!['fullName']!;
  String get enterName => _localizedValues[locale.languageCode]!['enterName']!;
  String get enterValidEmail =>
      _localizedValues[locale.languageCode]!['enterValidEmail']!;
  String get passwordTooShort =>
      _localizedValues[locale.languageCode]!['passwordTooShort']!;
  String get secureAccess =>
      _localizedValues[locale.languageCode]!['secureAccess']!;
  String get back => _localizedValues[locale.languageCode]!['back']!;
  String get signupSuccess =>
      _localizedValues[locale.languageCode]!['signupSuccess']!;
  String get signupFailed =>
      _localizedValues[locale.languageCode]!['signupFailed']!;
  String get lgsCampuses =>
      _localizedValues[locale.languageCode]!['lgsCampuses']!;
  String get historyProfile =>
      _localizedValues[locale.languageCode]!['historyProfile']!;
  String get keyFeatures =>
      _localizedValues[locale.languageCode]!['keyFeatures']!;
  String get academicHighlights =>
      _localizedValues[locale.languageCode]!['academicHighlights']!;
  String get facilityHighlights =>
      _localizedValues[locale.languageCode]!['facilityHighlights']!;
  String get photoCaptions =>
      _localizedValues[locale.languageCode]!['photoCaptions']!;
  String get moreInfo => _localizedValues[locale.languageCode]!['moreInfo']!;
  String get moreAbout => _localizedValues[locale.languageCode]!['moreAbout']!;
  String get close => _localizedValues[locale.languageCode]!['close']!;
  String get professorsAppointments =>
      _localizedValues[locale.languageCode]!['professorsAppointments']!;
  String get viewGallery =>
      _localizedValues[locale.languageCode]!['viewGallery']!;
  String get openGalleryPlaceholder =>
      _localizedValues[locale.languageCode]!['openGalleryPlaceholder']!;
  String get findRightSchool =>
      _localizedValues[locale.languageCode]!['findRightSchool']!;
  String get browseCompareApply =>
      _localizedValues[locale.languageCode]!['browseCompareApply']!;
  String get startAdmission =>
      _localizedValues[locale.languageCode]!['startAdmission']!;
  String get newAdmission =>
      _localizedValues[locale.languageCode]!['newAdmission']!;
  String get savedForms =>
      _localizedValues[locale.languageCode]!['savedForms']!;
  String get offlineDrafts =>
      _localizedValues[locale.languageCode]!['offlineDrafts']!;
  String get noPublishedNews =>
      _localizedValues[locale.languageCode]!['noPublishedNews']!;
  String get checkBackSoon =>
      _localizedValues[locale.languageCode]!['checkBackSoon']!;
  String get yourAdmissions =>
      _localizedValues[locale.languageCode]!['yourAdmissions']!;
  String get noSavedForms =>
      _localizedValues[locale.languageCode]!['noSavedForms']!;
  String get startNewAdmission =>
      _localizedValues[locale.languageCode]!['startNewAdmission']!;
  String get viewAllSavedForms =>
      _localizedValues[locale.languageCode]!['viewAllSavedForms']!;
  String get professors =>
      _localizedValues[locale.languageCode]!['professors']!;
  String get browseFaculty =>
      _localizedValues[locale.languageCode]!['browseFaculty']!;
  String get exploreCampuses =>
      _localizedValues[locale.languageCode]!['exploreCampuses']!;
  String get professorOverview =>
      _localizedValues[locale.languageCode]!['professorOverview']!;
  String get pendingApprovals =>
      _localizedValues[locale.languageCode]!['pendingApprovals']!;
  String get manageAppointments =>
      _localizedValues[locale.languageCode]!['manageAppointments']!;
  String get reviewNow => _localizedValues[locale.languageCode]!['reviewNow']!;
  String get noAppointments =>
      _localizedValues[locale.languageCode]!['noAppointments']!;
  String get upcomingAppointments =>
      _localizedValues[locale.languageCode]!['upcomingAppointments']!;
  String get viewAllAppointments =>
      _localizedValues[locale.languageCode]!['viewAllAppointments']!;
  String get admissionStatus =>
      _localizedValues[locale.languageCode]!['admissionStatus']!;
  String get noAdmissionsYet =>
      _localizedValues[locale.languageCode]!['noAdmissionsYet']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ur'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
