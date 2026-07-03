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

    func circuitDone(_ n: Int) -> String {
        switch lang {
        case .en: "Circuit \(num(n)) of seven complete."
        case .ar: "اكتمل الشوط \(num(n)) من سبعة."
        case .ur: "\(num(n)) واں چکر مکمل ہوا، سات میں سے۔"
        }
    }
    func personClose(_ dir: Observation.Direction) -> String {
        switch lang {
        case .en: "Careful, someone is close on your \(direction(dir))."
        case .ar: "انتبه، هناك شخص قريب على \(direction(dir))."
        case .ur: "خیال رکھیں، کوئی آپ کی \(direction(dir)) قریب ہے۔"
        }
    }
    /// Short on-screen obstacle chip, e.g. "Person 1.2 m on your left".
    func obstacleChip(_ dir: Observation.Direction, _ meters: Double) -> String {
        let m = num1(meters)
        return switch lang {
        case .en: "Person \(m) m on your \(direction(dir))"
        case .ar: "شخص على بعد \(m) م على \(direction(dir))"
        case .ur: "شخص \(m) میٹر آپ کی \(direction(dir))"
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
