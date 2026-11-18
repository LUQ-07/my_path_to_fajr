import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Lightweight tri-lingual strings (ar default, en, fr).
class AppStrings {
  final String code;
  const AppStrings(this.code);

  static AppStrings of(BuildContext c) =>
      Localizations.of<AppStrings>(c, AppStrings) ?? const AppStrings('ar');
  static const delegate = _Delegate();
  static const supported = [Locale('ar'), Locale('en'), Locale('fr')];

  String t(String key, [Map<String, String> p = const {}]) {
    var s = _m[key]?[code] ?? _m[key]?['en'] ?? key;
    p.forEach((k, v) => s = s.replaceAll('{$k}', v));
    return s;
  }

  List<String> get weekdays => switch (code) {
        'en' => ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
        'fr' => ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'],
        _ => ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'],
      };

  static const _m = <String, Map<String, String>>{
    'appTitle': {'ar': 'طريقي للفجر', 'en': 'My Path to Fajr', 'fr': 'Mon Chemin vers le Fajr'},
    'menu': {'ar': 'القائمة', 'en': 'Menu', 'fr': 'Menu'},
    'home': {'ar': 'الرئيسية', 'en': 'Home', 'fr': 'Accueil'},
    'settings': {'ar': 'الإعدادات', 'en': 'Settings', 'fr': 'Paramètres'},
    'notifications': {'ar': 'الإشعارات', 'en': 'Notifications', 'fr': 'Notifications'},
    'about': {'ar': 'حول', 'en': 'About', 'fr': 'À propos'},
    'updates': {'ar': 'التحديثات', 'en': 'Updates', 'fr': 'Mises à jour'},
    'alarm': {'ar': 'المنبه', 'en': 'Alarm', 'fr': 'Alarme'},
    'dayN': {'ar': 'اليوم {n}', 'en': 'Day {n}', 'fr': 'Jour {n}'},
    'addQuote': {'ar': 'إضافة عبارة تشجيعية', 'en': 'Add motivational quote', 'fr': 'Ajouter une citation motivante'},
    'myNote': {'ar': 'ملاحظتي لهذا اليوم', 'en': 'My note for today', 'fr': 'Ma note du jour'},
    'completed': {'ar': 'هل تم إنجازه؟', 'en': 'Completed?', 'fr': 'Accompli ?'},
    'yes': {'ar': 'نعم', 'en': 'Yes', 'fr': 'Oui'},
    'no': {'ar': 'لا', 'en': 'No', 'fr': 'Non'},
    'streak': {'ar': 'سلسلة الأيام: {n}', 'en': 'Streak: {n} days', 'fr': 'Série : {n} jours'},
    'appStyle': {'ar': 'مظهر التطبيق', 'en': 'App Style', 'fr': 'Apparence'},
    'languages': {'ar': 'اللغات', 'en': 'Languages', 'fr': 'Langues'},
    'alarmSound': {'ar': 'نغمة المنبه', 'en': 'Alarm Sound', 'fr': 'Sonnerie'},
    'fajrNotifs': {'ar': 'تنبيهات صلاة الفجر', 'en': 'Fajr Notifications', 'fr': 'Notifications Fajr'},
    'enableReminders': {'ar': 'تفعيل الإشعارات والتذكيرات', 'en': 'Enable Notifications & Reminders', 'fr': 'Activer notifications et rappels'},
    'reminders': {'ar': 'إشعار', 'en': 'Reminders', 'fr': 'Rappels'},
    'remindersDesc': {'ar': 'إشعار تذكيري لإيقاظك لصلاة الفجر', 'en': 'Reminder notifications to wake you for Fajr prayer', 'fr': 'Notifications pour vous réveiller pour la prière du Fajr'},
    'customMsg': {'ar': 'تخصيص عبارة التذكير', 'en': 'Customize reminder message', 'fr': 'Personnaliser le message de rappel'},
    'defaultMsg': {'ar': 'حان وقت الصلاة، استيقظ يا عبد الله، الصلاة خير من النوم', 'en': 'It\'s prayer time, wake up Abdullah, prayer is better than sleep', 'fr': 'C\'est l\'heure de la prière, réveille-toi Abdallah, la prière est meilleure que le sommeil'},
    'notifTime': {'ar': 'وقت الإشعارات', 'en': 'Notification Time', 'fr': 'Heure des notifications'},
    'setAlertTimes': {'ar': 'أوقات التنبيه المخصصة', 'en': 'Custom Alert Times', 'fr': 'Heures d\'alerte personnalisées'},
    'addNewTime': {'ar': '+ إضافة وقت جديد', 'en': '+ Add New Time', 'fr': '+ Ajouter une heure'},
    'noTimes': {'ar': 'لم تُضف أوقاتًا بعد', 'en': 'No times added yet', 'fr': 'Aucune heure ajoutée'},
    'queued': {'ar': 'تنبيهات مجدولة حاليًا: {n}', 'en': 'Currently scheduled: {n}', 'fr': 'Actuellement planifiées : {n}'},
    'alarmTitle': {'ar': 'منبه صلاة الفجر', 'en': 'Fajr Alarm', 'fr': 'Alarme Fajr'},
    'alarmTone': {'ar': 'نغمة التنبيه', 'en': 'Alarm Tone', 'fr': 'Sonnerie'},
    'addAlarm': {'ar': '+ إضافة منبه جديد', 'en': '+ Add New Alarm', 'fr': '+ Ajouter une alarme'},
    'save': {'ar': 'حفظ', 'en': 'Save', 'fr': 'Enregistrer'},
    'cancel': {'ar': 'إلغاء', 'en': 'Cancel', 'fr': 'Annuler'},
    'pickQuote': {'ar': 'أو اختر من العبارات الجاهزة', 'en': 'Or pick a built-in quote', 'fr': 'Ou choisissez une citation intégrée'},
    'writeQuote': {'ar': 'اكتب عبارتك', 'en': 'Write your quote', 'fr': 'Écrivez votre citation'},
    'noteHint': {'ar': 'اكتب ملاحظتك...', 'en': 'Write your note...', 'fr': 'Écrivez votre note...'},
    'aboutTitle': {'ar': 'حول التطبيق', 'en': 'About the app', 'fr': 'À propos'},
    'aboutBody': {
      'ar': 'طريقي للفجر تطبيق يعينك على الاستيقاظ لصلاة الفجر ومتابعة التزامك اليومي وتجديد همّتك.\n\nنُشر بنية الصدقة الجارية، فنسألكم الدعاء.\n\nالخصوصية: التطبيق يعمل بالكامل دون إنترنت، لا تتبّع ولا جمع للبيانات الشخصية ولا بيع لها، وكل ما تكتبه مُشفّر على جهازك.',
      'en': 'My Path to Fajr helps you wake up for Fajr, track your daily consistency and stay motivated.\n\nPublished with the intention of Sadaqah Jariyah (ongoing charity); please keep us in your du\'a.\n\nPrivacy: 100% offline-first, zero tracking, no personal data collected or sold. Everything you write is encrypted on your device.',
      'fr': 'Mon Chemin vers le Fajr vous aide à vous réveiller pour le Fajr, suivre votre régularité et rester motivé.\n\nPublié avec l\'intention d\'une Sadaqa Jariya (aumône continue) ; pensez à nous dans vos invocations.\n\nConfidentialité : 100 % hors ligne, aucun suivi, aucune donnée personnelle collectée ni vendue. Tout ce que vous écrivez est chiffré sur votre appareil.'
    },
    'version': {'ar': 'الإصدار', 'en': 'Version', 'fr': 'Version'},
    'changelog': {
      'ar': '• الإصدار الأول\n• متابعة يومية للفجر وسلسلة الأيام\n• منبهات متعددة\n• تنبيهات تحفيزية\n• تخزين مشفّر\n• ثلاث لغات',
      'en': '• First release\n• Daily Fajr tracker and streak\n• Multiple alarms\n• Motivational reminders\n• Encrypted storage\n• Three languages',
      'fr': '• Première version\n• Suivi quotidien du Fajr et série\n• Alarmes multiples\n• Rappels motivants\n• Stockage chiffré\n• Trois langues'
    },
    'permTitle': {'ar': 'نحتاج إذنك', 'en': 'We need your permission', 'fr': 'Autorisation requise'},
    'permBody': {
      'ar': 'لنُوقظك في وقت الفجر نحتاج إذن الإشعارات والمنبهات الدقيقة. لا نطلب إلا الحد الأدنى، ولا نجمع أي بيانات.',
      'en': 'To wake you at Fajr time we need notification and exact-alarm permissions. We request only the minimum and collect no data.',
      'fr': 'Pour vous réveiller à l\'heure du Fajr, nous avons besoin des autorisations de notifications et d\'alarmes exactes. Minimum requis, aucune donnée collectée.'
    },
    'allow': {'ar': 'متابعة', 'en': 'Continue', 'fr': 'Continuer'},
    'notNow': {'ar': 'لاحقًا', 'en': 'Not now', 'fr': 'Plus tard'},
    'stop': {'ar': 'إيقاف', 'en': 'Stop', 'fr': 'Arrêter'},
    'ringing': {'ar': 'حان وقت الفجر', 'en': 'It\'s time for Fajr', 'fr': 'C\'est l\'heure du Fajr'},
    'tone_makkah_adhan': {'ar': 'أذان مكة', 'en': 'Makkah Adhan', 'fr': 'Adhan de La Mecque'},
    'tone_fajr_adhan': {'ar': 'أذان الفجر (الافتراضي)', 'en': 'Fajr Adhan (Default)', 'fr': 'Adhan du Fajr (par défaut)'},
    'tone_madinah_adhan': {'ar': 'أذان المدينة', 'en': 'Madinah Adhan', 'fr': 'Adhan de Médine'},
    'notifTitle': {'ar': 'طريقي للفجر 🌙', 'en': 'My Path to Fajr 🌙', 'fr': 'Mon Chemin vers le Fajr 🌙'},
    'error': {'ar': 'حدث خطأ، حاول مرة أخرى', 'en': 'Something went wrong, please try again', 'fr': 'Une erreur est survenue, réessayez'},
    'addTone': {'ar': 'إضافة نغمة من الهاتف', 'en': 'Add tone from phone', 'fr': 'Ajouter une sonnerie du téléphone'},
    'deleteTone': {'ar': 'حذف النغمة', 'en': 'Delete tone', 'fr': 'Supprimer la sonnerie'},
    'toneTooBig': {'ar': 'الملف كبير (الحد 15 ميغا)', 'en': 'File too large (max 15 MB)', 'fr': 'Fichier trop volumineux (15 Mo max)'},
    'monthly': {'ar': 'الحصة الشهرية', 'en': 'Monthly session', 'fr': 'Séance du mois'},
    'pickImage': {'ar': 'اختيار صورة', 'en': 'Choose image', 'fr': 'Choisir une image'},
    'changeImage': {'ar': 'تغيير الصورة', 'en': 'Change image', 'fr': 'Changer l\'image'},
    'deleteImage': {'ar': 'حذف الصورة', 'en': 'Remove image', 'fr': 'Supprimer l\'image'},
    'noImage': {'ar': 'لم تختر صورة بعد. اضغط لاختيار صورة من هاتفك.', 'en': 'No image yet. Tap to choose one from your phone.', 'fr': 'Aucune image. Appuyez pour en choisir une.'},
    'zoomHint': {'ar': 'يمكنك التكبير والتصغير بإصبعين', 'en': 'Pinch to zoom', 'fr': 'Pincez pour zoomer'},
    'more': {'ar': 'المزيد', 'en': 'More', 'fr': 'Plus'},
    'volume': {'ar': 'مستوى الصوت', 'en': 'Volume', 'fr': 'Volume'},
    'preview': {'ar': 'تجربة الصوت', 'en': 'Play preview', 'fr': 'Écouter'},
    'deleteDay': {'ar': 'حذف هذا اليوم', 'en': 'Delete this day', 'fr': 'Supprimer ce jour'},
    'deleteDayMsg': {'ar': 'سيتم حذف اليوم {n} وملاحظاته، وإعادة ترقيم الأيام التي بعده.', 'en': 'Day {n} and its notes will be deleted and the following days renumbered.', 'fr': 'Le jour {n} et ses notes seront supprimés et les jours suivants renumérotés.'},
    'delete': {'ar': 'حذف', 'en': 'Delete', 'fr': 'Supprimer'},
    'startOver': {'ar': 'البدء من جديد', 'en': 'Start over', 'fr': 'Recommencer'},
    'startOverMsg': {'ar': 'سيتم حذف كل الأيام وملاحظاتها والبدء من اليوم الأول. المنبهات والإعدادات تبقى كما هي.', 'en': 'All days and their notes will be deleted and you will start again from day 1. Alarms and settings stay as they are.', 'fr': 'Tous les jours et leurs notes seront supprimés et vous repartirez du jour 1. Les alarmes et réglages sont conservés.'},
    'light': {'ar': 'فاتح', 'en': 'Light', 'fr': 'Clair'},
    'dark': {'ar': 'داكن', 'en': 'Dark', 'fr': 'Sombre'},
  };
}

class _Delegate extends LocalizationsDelegate<AppStrings> {
  const _Delegate();
  @override
  bool isSupported(Locale l) => ['ar', 'en', 'fr'].contains(l.languageCode);
  @override
  Future<AppStrings> load(Locale l) => SynchronousFuture(AppStrings(l.languageCode));
  @override
  bool shouldReload(_Delegate old) => false;
}
