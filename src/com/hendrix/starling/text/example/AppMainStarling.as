package com.hendrix.starling.text.example
{   
  import com.hendrix.starling.text.bidiTextField.BidiBitmapFont;
  import com.hendrix.starling.text.bidiTextField.BidiTextField;
  
  import starling.display.Quad;
  import starling.display.Sprite;
  import starling.events.Event;
  import starling.textures.Texture;
  import starling.utils.HAlign;
  import starling.utils.VAlign;
  
  public class AppMainStarling extends Sprite
  {
    
    [Embed(source="assets/fonts/bf/arr.fnt", mimeType="application/octet-stream")]
    public static const FontXml:Class;
    
    [Embed(source = "assets/fonts/bf/arr_0.png")]
    public static const FontTexture:Class;
    
    private var _tfBidi: BidiTextField;
    
    public function AppMainStarling()
    {
      super();
      
      addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);      
    }
    
    protected function addedToStageHandler(event: Event): void
    {
      removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
      
      var quad:     Quad    = new Quad(1,1, 0xffffff);
      
      var text:String       = 'אני בעלת מספר טלפון ********** כותבת לכם לאחר שביליתי בסניף נתניה 3 שעות בהמתנה לקבלת שירות אך את השירות לא קיבלתי.היום 12.11.13 בסביבות שעה 14.00 הגעתי לפלאפון בסניף נתניה למטרת תיקון מכשיר בלקברי שברשותי. קיבלתי מספר מפקידה שהוא A144. לאחר המתנה כחצי שעה שמעתי מהאנשים רבים הממתינים שם כמוני שמספרים A לא מתקדמים כבר זמן רב ושמזמנים רק את האנשים שהגיעו לסניף למטרת רכישת מכשירים חדשים. חייבת לציין שלפני מספר חודשים בביקור הקודם שלי בסניף הייתה אותה הבעיה עם המספרים (אנשים שהגיעו למרת תיקון לא הוזמנו זמן רב עד שלקוחות הממתינים התחילו להתלונן). לאחר המתנה של שעה הכעס של הלקוחות הלך וגבר. נשמעו תלונות מלקוחות שהזמינו תור מראש וגם מאלה שהגיעו בלי תור מוזמן (כמוני). המספרים שהוזמנו היו B וC והמשיכו להתעלם ממספרים A. רק לאחר איומים לעזוב את החברה או לפנות לתקשורת הפקידה בכניסה אמרה שהיא תבקש להתחיל להזמין את המספרים A. כך התקבלתי לשירות תיקונים לאחר המתנה של שעה וחצי. אך לא ידעתי מה עוד מצפה לי...הסברתי לבחור שקיבל אותי על שתי תקלות במכשיר והבלקברי שלי נלקח לבדיקה על ידי טכנאי. כעבור חצי שעה נמסר לי שהמכשיר ישלח למעבדה ככרגע לא יכולים לפתור את הבעיה ואני אקבל בלקברי חילופי. ביקשתי מהבחור לשלוח את בלקברי שלי לאחר תיקון עם שליח (השירות עולה 50 שח). ואז הופיעה בעיה החדשה: המכשיר יהיה מוכן בעוד שבוע, השליח לא מודיע מראש על הגעתו ואני צריכה להמתין לו ביום שני הבא בין שעות 9.00 בבוקר עד 5 בערב בבית. לא עזרו לי הסברים שאני עובדת ולא יכולה להפסיד יום עבודה (לא מספיק שהפסדתי 3 שעות בהמתנה בסניף), שאני עובדת בשני מקומות ולא יכולה כרגע לדעת באיזו שעה אני אהיה בבית בעוד שבוע. נאלצתי להסכים עם הדבר ההזוי - המתנה של יום שלם לשליח פלאפון.... ועוד תוך כדי עמידה ליד הדלפק של הפקיד, אני מנסה להפעיל את הבלקברי החילופי ומגלה שהוא לא פועל! אני מראה את זה לפקיד ומקבלת תשובה: "זה בלקברי חילופי, הוא ישן ולא חדש ולכן הכפתורים שלו לא פועלים". רגע! אז... אני צריכה לצאת מפה בלי מכשיר שלי למשך שבוע ימים ועם מכשיר חילופי שלא עובד? והבחור עונה לי: "רוצה מכשיר עובד - תקני מכשיר חדש." פה נשאלת השאלה:האם חברת פלאפון נותנת שירות אך ורק ללקוחות שכרגע מכניסים להם סכום במזומן (כמו רכישת מכשיר חדש)?האם חברת פלאפון לא מעוניינת בשימור לקוחות ותיקים? אני בחברת פלאפון כבר 17 שנה והיום החלטתי שעוזבת אותם ועוברת לאחד המתחרים שיש בשוק. אפשר לשמור על אותו מספר הטלפון, חברות מתחרות מציעים מחירים אטרקטיביים ללקוחות חדשים... אני עוזבת ומעבירה לחברה אחרת את כל ה 4 המספרים שעל שמי (טלפונים של בני משפחתי). את הפוסט הזה יראו חברים שלי וישתפו אותו ויראו אותו חברים שלהם.... פרסומת מעולה לחברת פלאפון ושירותיה.(פורסם בדף של פלאפון)';
      
      var texture:  Texture = Texture.fromBitmap(new FontTexture(), false);
      var xml:      XML     = XML(new FontXml());
      
      BidiTextField.registerBitmapFont(new BidiBitmapFont(texture,xml), "ArialBD");
      
      _tfBidi               = new BidiTextField(1,1,"","ArialBD");
      _tfBidi.fontSize      = 20;
      _tfBidi.isTrancted    = true;
      _tfBidi.bidiLevel     = 1;
      _tfBidi.color         = 0x00;
      _tfBidi.hAlign        = HAlign.RIGHT;
      _tfBidi.vAlign        = VAlign.TOP;
      
      
      _tfBidi.text          = text;
      
      addChild(quad);
      addChild(_tfBidi);
      
      _tfBidi.width         = stage.stageWidth;
      _tfBidi.height        = 200;
      
      quad.width            = stage.stageWidth;
      quad.height           = 200;
    }
    
  }
  
}