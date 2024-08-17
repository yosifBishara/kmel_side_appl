List<String> weekDays = [
  'ראשון',
  ' ',
  'שלישי',
  'רביעי',
  'חמישי',
  'שישי',
  'שבת',
  'ראשון',
  ' ',
  'שלישי',
  'רביעי',
  'חמישי',
  'שישי',
  'שבת'
];

String emergencyExitMessage = "קמיל בשארה - הודעה חשובה!" + "\n"
    + "الزبون الكريم, سيتم اغلاق الصالون حتى نهاية اليوم لاسباب ضرورية." +
    "\n"
    + "للاسف, تم الغاء دورك ويجب عليك حجز دور جديد." + "\n"
    + "اذا وصلك تذكير للدور الملغي الرجاء تجاهلا." + "\n"
    + "المعذرة." + "\n" + "   ----------    " + "\n"
    + "לקוח יקר, הסלון ייסגר לסיבות דחופות היום מהשעה הנוכחית עד סוף היום." +
    "\n"
    + "לצערנו, התור שלך מבוטל והינך דרוש לקבוע תור מחדש." + "\n"
    + "נא להתעלם מכל תזכורת ששייכת לתור שבוטל." + "\n"
    "עמכם הסליחה.";

String partialExit = "קמיל בשארה - הודעה חשובה!" + "\n"
    + "الزبون الكريم, سيتم اغلاق الصالون خلال ساعة حجزك لاسباب ضرورية." + "\n"
    + "للاسف, تم الغاء دورك ويجب عليك حجز دور جديد." + "\n"
    + "اذا وصلك تذكير للدور الملغي الرجاء تجاهله." + "\n"
    + "المعذرة." + "\n" + "   ----------    " + "\n"
    + "לקוח יקר, הסלון ייסגר לסיבות דחופות היום בשעה שקבעת לתורך." + "\n"
    + "לצערנו, התור שלך מבוטל והינך דרוש לקבוע תור מחדש." + "\n"
    + "נא להתעלם מכל תזכורת ששייכת לתור שבוטל." + "\n"
    "עמכם הסליחה.";

// Firestore

class FireStoreArg {
  static const APPOINTMENTS_COLLECTION_ID = 'appointments';
  static const WORK_TIMES_COLLECTION_ID = 'work_times';
  static const USERS_COLLECTION_ID = 'users';
  static const APP_UPDATE_INFO_COLLECTION_ID = 'update_info';
  static const WORK_TIMES_DOC_ID_PREFIX = 'lessEquals-';
  static const WORK_TIMES_LIST_FIELD = 'times_list';
  static const UNAVAILABLE_TIMES_FIELD = 'unavailable_times';
  static const TIME_OFFSET_MIN_FIELD = 'time_offset_min';
  static const PHONE_NUM_FIELD = 'phone';
  static const NAME_FIELD = 'name';
  static const DAY_FIELD = 'day';
  static const DATE_FIELD = 'date';
  static const TIME_FIELD = 'time';
  static const NEXT_APPOINTMENT_FIELD = 'next_appointment';
  static const APP_UPDATE_CONTENT_DOC = 'updateContent';
  static const APP_UPDATE_CONTENT_FIELD = 'content';
  static const APP_UPDATE_ANDROID_FIELD = 'android';
  static const APP_UPDATE_IOS_FIELD = 'ios';
  static const APP_UPDATE_TITLE_FIELD = 'title';
  static const DAY_APPOINTMENTS_COLLECTION = 'day_appointments';
  static const TIME_ALREADY_TAKEN = 'time taken';
  static const APPOINTMENT_PASSED = 'appointment passed';


}

class UtilConst {
  static const EMPTY_STRING = '';
  static const DOT = '.';
  static const BACK_SLASH = '/';
  static const List<String> WEEK_DAYS = ['ראשון',' ','שלישי','רביעי','חמישי','שישי','שבת',
    'ראשון',' ','שלישי','רביעי','חמישי','שישי','שבת'];


}

