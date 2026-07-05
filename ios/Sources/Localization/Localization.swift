import Foundation
import SwiftUI

/// Ground-up multi-language support with a RUNTIME switch (a judge taps a language
/// and the whole app — UI text, layout direction, voice, and cloud replies — flips
/// live). Arabic is a first-class citizen, including right-to-left layout and
/// Arabic-Indic numerals.
///
/// NOTE: Arabic/Urdu strings are Modern Standard translations written for the demo;
/// have a native speaker proof them before anything user-facing ships.
enum Lang: String, CaseIterable, Identifiable {
    case en = "English"
    case ar = "Arabic"
    case ur = "Urdu"

    var id: String { rawValue }
    var nativeName: String {
        switch self { case .en: "English"; case .ar: "العربية"; case .ur: "اردو" }
    }
    var bcp47: String {
        switch self { case .en: "en-US"; case .ar: "ar-SA"; case .ur: "ur-PK" }
    }
    /// 2-letter code for the voice-command matcher.
    var code: String { String(bcp47.prefix(2)) }
    var isRTL: Bool { self == .ar || self == .ur }
    var layoutDirection: LayoutDirection { isRTL ? .rightToLeft : .leftToRight }
}

/// Localized strings + phrase builders for the current language.
struct L10n {
    let lang: Lang

    // App identity
    var appName: String {
        switch lang { case .en: "Umrah Companion"; case .ar: "رفيق العُمرة"; case .ur: "عمرہ ساتھی" }
    }
    var tagline: String {
        switch lang {
        case .en: "Your voice guide in the Haram"
        case .ar: "دليلك الصوتي في الحرم"
        case .ur: "حرم میں آپ کا صوتی رہنما"
        }
    }

    // Status + prompts
    var markPrompt: String {
        switch lang {
        case .en: "Point at the table, then tap to mark the Kaaba."
        case .ar: "وجّه الكاميرا نحو الطاولة ثم اضغط لتحديد الكعبة."
        case .ur: "کیمرہ میز کی طرف کریں، پھر کعبہ متعین کرنے کے لیے دبائیں۔"
        }
    }
    var holdTable: String {
        switch lang {
        case .en: "Hold the table in view…"
        case .ar: "أبقِ الطاولة ضمن الرؤية…"
        case .ur: "میز کو منظر میں رکھیں…"
        }
    }
    var beginWalking: String {
        switch lang {
        case .en: "Kaaba marked. Begin walking your circuits."
        case .ar: "تم تحديد الكعبة. ابدأ الطواف."
        case .ur: "کعبہ متعین ہو گیا۔ طواف شروع کریں۔"
        }
    }
    var tawafComplete: String {
        switch lang {
        case .en: "Tawaf complete."
        case .ar: "اكتمل الطواف."
        case .ur: "طواف مکمل ہو گیا۔"
        }
    }

    // Buttons
    var markButton: String {
        switch lang { case .en: "Mark the Kaaba"; case .ar: "تحديد الكعبة"; case .ur: "کعبہ متعین کریں" }
    }
    var markHereButton: String {
        switch lang { case .en: "Mark this spot"; case .ar: "تحديد هذا الموضع"; case .ur: "یہ جگہ متعین کریں" }
    }
    var askButton: String {
        switch lang { case .en: "Ask what's around me"; case .ar: "ماذا حولي؟"; case .ur: "میرے اردگرد کیا ہے؟" }
    }
    var listening: String {
        switch lang { case .en: "Listening…"; case .ar: "أستمع…"; case .ur: "سن رہا ہوں…" }
    }
    var startAgain: String {
        switch lang { case .en: "Start again"; case .ar: "ابدأ من جديد"; case .ur: "دوبارہ شروع کریں" }
    }
    var ofSevenCircuits: String {
        switch lang { case .en: "of 7 circuits"; case .ar: "من ٧ أشواط"; case .ur: "۷ چکروں میں سے" }
    }

    // Spoken lines
    var beginTawafSpoken: String {
        switch lang {
        case .en: "Kaaba marked. You may begin your Tawaf. Walk slowly, counter-clockwise."
        case .ar: "تم تحديد الكعبة. يمكنك بدء الطواف. سِر ببطء عكس عقارب الساعة."
        case .ur: "کعبہ متعین ہو گیا۔ آپ طواف شروع کر سکتے ہیں۔ آہستہ، گھڑی کی مخالف سمت میں چلیں۔"
        }
    }
    var tawafFinishedSpoken: String {
        switch lang {
        case .en: "Your seventh circuit is complete. Your Tawaf is finished. May it be accepted."
        case .ar: "اكتمل شوطك السابع. تمّ طوافك، تقبّل الله."
        case .ur: "آپ کا ساتواں چکر مکمل ہو گیا۔ آپ کا طواف مکمل ہوا۔ اللہ قبول فرمائے۔"
        }
    }
    var networkFallback: String {
        switch lang {
        case .en: "I cannot reach the network right now. The path ahead looks clear."
        case .ar: "لا يمكنني الاتصال بالشبكة الآن. يبدو الطريق أمامك خاليًا."
        case .ur: "ابھی نیٹ ورک دستیاب نہیں۔ آگے کا راستہ صاف لگتا ہے۔"
        }
    }

    // MARK: Du'a (optional — never prescriptive; safety always interrupts it)
    /// Prompt mode: a gentle, non-prescriptive cue. Du'a during Tawaf is free/
    /// personal — we invite, we don't dictate.
    var duaPrompt: String {
        switch lang {
        case .en: "You may make your du'a now."
        case .ar: "يمكنك الدعاء الآن."
        case .ur: "آپ اب دعا کر سکتے ہیں۔"
        }
    }
    /// Recite mode: the short, authentic phrase said facing the Black Stone at the
    /// start of each circuit. Kept short on purpose (a long recitation must never
    /// block a safety warning). For production, replace TTS with reciter audio.
    var duaRecite: String {
        switch lang {
        case .en: "Bismillah, Allahu Akbar."
        case .ar: "بسم الله، الله أكبر."
        case .ur: "بسم اللہ، اللہ اکبر۔"
        }
    }
    func duaModeName(_ mode: Int) -> String {
        switch (lang, mode) {
        case (.en, 0): "Du'a off";    case (.en, 1): "Du'a: prompt";  case (.en, _): "Du'a: recite"
        case (.ar, 0): "الدعاء متوقف"; case (.ar, 1): "الدعاء: تذكير"; case (.ar, _): "الدعاء: تلاوة"
        case (.ur, 0): "دعا بند";     case (.ur, 1): "دعا: یاد دہانی"; case (.ur, _): "دعا: تلاوت"
        }
    }

    // MARK: Voice commands (spoken confirmations + help)
    var guidanceOnConfirm: String {
        switch lang { case .en: "Walk guidance on."; case .ar: "تم تشغيل إرشاد المشي."; case .ur: "چلنے کی رہنمائی آن۔" }
    }
    var guidanceOffConfirm: String {
        switch lang { case .en: "Walk guidance off."; case .ar: "تم إيقاف إرشاد المشي."; case .ur: "چلنے کی رہنمائی بند۔" }
    }
    var muteConfirm: String {
        switch lang { case .en: "Warnings muted."; case .ar: "تم كتم التحذيرات."; case .ur: "انتباہات خاموش۔" }
    }
    var unmuteConfirm: String {
        switch lang { case .en: "Warnings on."; case .ar: "تم تشغيل التحذيرات."; case .ur: "انتباہات آن۔" }
    }
    var notNowSpoken: String {
        switch lang { case .en: "Not available right now."; case .ar: "غير متاح الآن."; case .ur: "ابھی دستیاب نہیں۔" }
    }
    var helpSpoken: String {
        switch lang {
        case .en: "You can say: Tawaf, Sa'i, mark, start again, what's around me, walk guidance, or mute."
        case .ar: "يمكنك أن تقول: طواف، سعي، حدد، من جديد، ماذا حولي، إرشاد المشي، أو اكتم."
        case .ur: "آپ کہہ سکتے ہیں: طواف، سعی، متعین، دوبارہ، میرے اردگرد کیا ہے، رہنمائی، یا خاموش۔"
        }
    }
    /// Spoken "where am I" for the count command; `n == 0` before any unit completes.
    func progressSpoken(_ n: Int, tawaf: Bool) -> String {
        let unit: String
        switch (lang, tawaf) {
        case (.en, true): unit = "circuit";  case (.en, false): unit = "length"
        case (.ar, true): unit = "شوط";      case (.ar, false): unit = "شوط"
        case (.ur, true): unit = "چکر";      case (.ur, false): unit = "چکر"
        }
        let done = min(n, 7)
        switch lang {
        case .en: return done == 0 ? "You haven't started counting yet." : "You are on \(unit) \(num(done + (done < 7 ? 1 : 0))) of seven."
        case .ar: return done == 0 ? "لم يبدأ العد بعد." : "أنت في ال\(unit) \(num(done + (done < 7 ? 1 : 0))) من سبعة."
        case .ur: return done == 0 ? "ابھی گنتی شروع نہیں ہوئی۔" : "آپ ساتویں میں سے \(num(done + (done < 7 ? 1 : 0)))واں \(unit) کر رہے ہیں۔"
        }
    }

    // MARK: Ritual selection + Sa'i
    var chooseRitual: String {
        switch lang {
        case .en: "Choose your ritual: Tawaf or Sa'i."
        case .ar: "اختر النسك: طواف أو سعي."
        case .ur: "اپنی عبادت منتخب کریں: طواف یا سعی۔"
        }
    }
    var tawafName: String {
        switch lang { case .en: "Tawaf"; case .ar: "طواف"; case .ur: "طواف" }
    }
    var saiName: String {
        switch lang { case .en: "Sa'i"; case .ar: "سعي"; case .ur: "سعی" }
    }
    var holdSteady: String {
        switch lang {
        case .en: "Hold steady…"
        case .ar: "ثبّت الكاميرا…"
        case .ur: "کیمرہ کو مستحکم رکھیں…"
        }
    }
    var markSafaPrompt: String {
        switch lang {
        case .en: "Point at the start, Safa, then tap to mark it."
        case .ar: "وجّه الكاميرا نحو الصفا ثم اضغط لتحديده."
        case .ur: "صفا کی طرف کیمرہ کریں، پھر متعین کرنے کے لیے دبائیں۔"
        }
    }
    var markMarwahPrompt: String {
        switch lang {
        case .en: "Now point at the far end, Marwah, and tap."
        case .ar: "الآن وجّه الكاميرا نحو المروة واضغط."
        case .ur: "اب دوسرے سرے مروہ کی طرف کیمرہ کریں اور دبائیں۔"
        }
    }
    var beginSaiSpoken: String {
        switch lang {
        case .en: "Both ends marked. Begin your Sa'i. Walk toward Marwah."
        case .ar: "تم تحديد الطرفين. ابدأ السعي. اتجه نحو المروة."
        case .ur: "دونوں سرے متعین ہو گئے۔ سعی شروع کریں۔ مروہ کی طرف چلیں۔"
        }
    }
    var saiComplete: String {
        switch lang { case .en: "Sa'i complete."; case .ar: "اكتمل السعي."; case .ur: "سعی مکمل ہو گئی۔" }
    }
    var saiFinishedSpoken: String {
        switch lang {
        case .en: "Your seventh length is complete. Your Sa'i is finished. May it be accepted."
        case .ar: "اكتمل شوطك السابع. تمّ سعيك، تقبّل الله."
        case .ur: "آپ کا ساتواں چکر مکمل ہوا۔ آپ کی سعی مکمل ہوئی۔ اللہ قبول فرمائے۔"
        }
    }
    var ofSevenLengths: String {
        switch lang { case .en: "of 7 lengths"; case .ar: "من ٧ أشواط"; case .ur: "۷ چکروں میں سے" }
    }
    private func endName(_ e: SaiTracker.End) -> String {
        switch (lang, e) {
        case (.en, .safa): "Safa";  case (.en, .marwah): "Marwah"
        case (.ar, .safa): "الصفا"; case (.ar, .marwah): "المروة"
        case (.ur, .safa): "صفا";   case (.ur, .marwah): "مروہ"
        }
    }
    func headToward(_ e: SaiTracker.End, l: L10n) -> String {
        switch lang {
        case .en: "Head toward \(endName(e))."
        case .ar: "اتجه نحو \(endName(e))."
        case .ur: "\(endName(e)) کی طرف چلیں۔"
        }
    }
    func lengthDone(_ n: Int, headTo target: SaiTracker.End?, l: L10n) -> String {
        let turn: String
        switch lang {
        case .en: turn = target != nil ? " Turn around, head toward \(endName(target!))." : ""
        case .ar: turn = target != nil ? " استدر واتجه نحو \(endName(target!))." : ""
        case .ur: turn = target != nil ? " مڑ جائیں، \(endName(target!)) کی طرف چلیں۔" : ""
        }
        switch lang {
        case .en: return "Length \(num(n)) of seven complete.\(turn)"
        case .ar: return "اكتمل الشوط \(num(n)) من سبعة.\(turn)"
        case .ur: return "\(num(n)) واں چکر مکمل ہوا، سات میں سے۔\(turn)"
        }
    }

    // MARK: Tawaf circle-guidance (spoken — terse + egocentric per blind-nav research)
    /// Spoken heading nudge. `left` = bear left, else bear right.
    func bearCue(left: Bool) -> String {
        switch (lang, left) {
        case (.en, true):  return "Bear a little left."
        case (.en, false): return "Bear a little right."
        case (.ar, true):  return "مِل قليلًا إلى اليسار."
        case (.ar, false): return "مِل قليلًا إلى اليمين."
        case (.ur, true):  return "تھوڑا بائیں مڑیں۔"
        case (.ur, false): return "تھوڑا دائیں مڑیں۔"
        }
    }
    var driftInSpoken: String {
        switch lang {
        case .en: "You're drifting toward the Kaaba. Ease outward."
        case .ar: "أنت تقترب من الكعبة. ابتعد قليلًا."
        case .ur: "آپ کعبہ کی طرف بڑھ رہے ہیں۔ ذرا باہر ہو جائیں۔"
        }
    }
    var driftOutSpoken: String {
        switch lang {
        case .en: "You're drifting too far out. Ease inward."
        case .ar: "أنت تبتعد كثيرًا. اقترب قليلًا."
        case .ur: "آپ بہت باہر جا رہے ہیں۔ ذرا اندر آ جائیں۔"
        }
    }
    var reversingSpoken: String {
        switch lang {
        case .en: "Wrong way. Turn around and keep the Kaaba on your left."
        case .ar: "الاتجاه خاطئ. استدر واجعل الكعبة على يسارك."
        case .ur: "غلط سمت۔ مڑ جائیں اور کعبہ کو اپنی بائیں طرف رکھیں۔"
        }
    }
    var backOnPathSpoken: String {
        switch lang {
        case .en: "Good. You're back on the path."
        case .ar: "جيد. عدت إلى المسار."
        case .ur: "اچھا۔ آپ دوبارہ راستے پر ہیں۔"
        }
    }
    /// Compact on-screen guidance line (for the sighted demo-runner / low-vision).
    func guidanceLabel(_ state: TawafGuide.State, steerLeft: Bool) -> String {
        switch (lang, state) {
        case (_, .onPath):     return lang == .en ? "On the path" : (lang == .ar ? "على المسار" : "راستے پر")
        case (_, .acquiring):  return lang == .en ? "Finding your orbit…" : (lang == .ar ? "جارٍ تحديد المسار…" : "مدار تلاش ہو رہا ہے…")
        case (_, .driftingIn): return lang == .en ? "Too close — ease out" : (lang == .ar ? "قريب جدًا — ابتعد" : "بہت قریب — باہر ہوں")
        case (_, .driftingOut):return lang == .en ? "Too far — ease in" : (lang == .ar ? "بعيد جدًا — اقترب" : "بہت دور — اندر آئیں")
        case (_, .reversing):  return lang == .en ? "Wrong way" : (lang == .ar ? "اتجاه خاطئ" : "غلط سمت")
        }
    }
    var guideOnLabel: String {
        switch lang { case .en: "Turn on walk guidance"; case .ar: "تشغيل إرشاد المشي"; case .ur: "چلنے کی رہنمائی آن کریں" }
    }
    var guideOffLabel: String {
        switch lang { case .en: "Turn off walk guidance"; case .ar: "إيقاف إرشاد المشي"; case .ur: "چلنے کی رہنمائی بند کریں" }
    }

    func circuitDone(_ n: Int) -> String {
        switch lang {
        case .en: "Circuit \(num(n)) of seven complete."
        case .ar: "اكتمل الشوط \(num(n)) من سبعة."
        case .ur: "\(num(n)) واں چکر مکمل ہوا، سات میں سے۔"
        }
    }
    /// Spoken obstacle warning for any detected object, e.g. "Careful, a chair is
    /// close, 1.2 meters on your left."
    func obstacleNear(_ label: String, _ dir: Observation.Direction, _ meters: Double) -> String {
        let m = num1(meters)
        let name = obstacleName(label)
        switch lang {
        case .en: return "Careful, \(name) is close, \(m) meters on your \(direction(dir))."
        case .ar: return "انتبه، \(name) قريب، على بعد \(m) متر على \(direction(dir))."
        case .ur: return "خیال رکھیں، \(name) قریب ہے، \(m) میٹر آپ کی \(direction(dir)) طرف۔"
        }
    }
    /// Short on-screen obstacle chip, e.g. "Chair · 1.2 m · left".
    func obstacleChip(_ label: String, _ dir: Observation.Direction, _ meters: Double) -> String {
        let m = num1(meters)
        return "\(obstacleName(label)) · \(m) m · \(direction(dir))"
    }

    /// A speakable name for a detected object. `person` gets a localized word;
    /// other COCO labels use the English term (fine for a prototype — proper
    /// per-language object vocab is a later polish item).
    func obstacleName(_ label: String) -> String {
        if label == "person" {
            switch lang { case .en: return "someone"; case .ar: return "شخص"; case .ur: return "کوئی" }
        }
        return label.replacingOccurrences(of: "_", with: " ")
    }

    /// On-device "what's around me?" description, built from the objects the phone
    /// already detected (label + LiDAR distance + direction). No cloud, no key.
    func sceneDescription(_ obs: [Observation]) -> String {
        let items = obs.compactMap { o -> String? in
            guard let d = o.distanceM else { return nil }
            return "\(obstacleName(o.label)) \(num1(d)) m \(direction(o.direction))"
        }
        if items.isEmpty {
            switch lang {
            case .en: return "The path ahead looks clear."
            case .ar: return "يبدو الطريق أمامك خاليًا."
            case .ur: return "آگے کا راستہ صاف لگتا ہے۔"
            }
        }
        let list = items.joined(separator: lang == .en ? ", " : "، ")
        switch lang {
        case .en: return "Around you: \(list)."
        case .ar: return "حولك: \(list)."
        case .ur: return "آپ کے اردگرد: \(list)۔"
        }
    }

    func direction(_ d: Observation.Direction) -> String {
        switch (lang, d) {
        case (.en, .left): "left";  case (.en, .ahead): "ahead"; case (.en, .right): "right"
        case (.ar, .left): "يسارك"; case (.ar, .ahead): "أمامك"; case (.ar, .right): "يمينك"
        case (.ur, .left): "بائیں"; case (.ur, .ahead): "سامنے"; case (.ur, .right): "دائیں"
        }
    }

    // Numerals: Arabic-Indic for Arabic, Western otherwise (Urdu uses Western here for clarity).
    func num(_ n: Int) -> String { lang == .ar ? toArabicIndic(String(n)) : String(n) }
    func num1(_ x: Double) -> String {
        let s = String(format: "%.1f", x)
        return lang == .ar ? toArabicIndic(s) : s
    }
    private func toArabicIndic(_ s: String) -> String {
        let map: [Character: Character] = ["0":"٠","1":"١","2":"٢","3":"٣","4":"٤",
                                           "5":"٥","6":"٦","7":"٧","8":"٨","9":"٩","." : "٫"]
        return String(s.map { map[$0] ?? $0 })
    }
}
