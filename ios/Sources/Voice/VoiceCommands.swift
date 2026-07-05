import Foundation

/// On-device voice-command matching. A small FIXED grammar (not open NLU) — this
/// is what on-device speech recognition resolves reliably and offline, per the
/// voice-UX research. Anything that doesn't match a command is treated as an
/// open "what's around me?" scene question by the caller.
///
/// Pure Foundation (keyed by a 2-letter language code, no SwiftUI/Lang dependency)
/// so it runs under the headless sim:
///   cd ios && swiftc Sources/Voice/VoiceCommands.swift Tests/voice/main.swift -o /tmp/voicesim && /tmp/voicesim
enum VoiceIntent: String, Equatable {
    case selectTawaf, selectSai, mark, reset, describe, toggleGuidance, toggleMute, dua, count, help, unknown
}

enum VoiceCommands {

    /// Ordered by priority — first intent with a matching keyword wins. More
    /// specific / higher-stakes intents come first (reset before select, etc.).
    private static let english: [(VoiceIntent, [String])] = [
        (.reset,          ["start again", "start over", "restart", "reset", "begin again", "do it again"]),
        (.selectSai,      ["sa'i", "saee", "saai", "safa and marwah", "between safa", "the sai"]),
        (.selectTawaf,    ["tawaf", "tawaaf", "circle the kaaba", "start the circle"]),
        (.toggleGuidance, ["walk guidance", "guide me", "guidance", "help me walk", "turn on guide", "turn off guide"]),
        (.toggleMute,     ["unmute", "mute", "be quiet", "silence", "stop warnings", "quiet"]),
        (.dua,            ["dua", "du'a", "supplication", "recite", "prayer words"]),
        (.count,          ["how many", "which circuit", "which lap", "how far", "laps left", "circuits left", "where am i in", "count"]),
        (.describe,       ["around me", "what's around", "what is around", "describe", "in front of me", "what do you see", "what is in front", "surroundings", "the scene"]),
        (.mark,           ["mark", "over here", "this spot", "set the center", "set center", "place it", "this place"]),
        (.help,           ["what can i say", "what can you do", "commands", "help"]),
    ]
    private static let arabic: [(VoiceIntent, [String])] = [
        (.reset,          ["من جديد", "أعد", "ابدأ من جديد", "إعادة"]),
        (.selectSai,      ["سعي", "السعي", "الصفا والمروة"]),
        (.selectTawaf,    ["طواف", "الطواف"]),
        (.toggleGuidance, ["إرشاد", "دلني", "أرشدني", "رشدني"]),
        (.toggleMute,     ["اكتم", "صمت", "أوقف التحذير", "اسكت"]),
        (.dua,            ["دعاء", "الدعاء", "ذكر"]),
        (.count,          ["كم شوط", "كم بقي", "أي شوط", "أين أنا"]),
        (.describe,       ["ماذا حولي", "حولي", "صف", "أمامي", "ماذا ترى"]),
        (.mark,           ["حدد", "هنا", "علّم", "هذا الموضع"]),
        (.help,           ["مساعدة", "ماذا أقول", "الأوامر"]),
    ]
    private static let urdu: [(VoiceIntent, [String])] = [
        (.reset,          ["دوبارہ", "نئے سرے", "ری سیٹ"]),
        (.selectSai,      ["سعی", "صفا اور مروہ"]),
        (.selectTawaf,    ["طواف"]),
        (.toggleGuidance, ["رہنمائی", "میری رہنمائی", "چلنے میں مدد"]),
        (.toggleMute,     ["خاموش", "بند کرو", "انتباہ بند"]),
        (.dua,            ["دعا", "دعائیں", "ذکر"]),
        (.count,          ["کتنے", "کونسا چکر", "کہاں ہوں", "کتنا باقی"]),
        (.describe,       ["اردگرد", "میرے اردگرد", "بیان", "سامنے", "کیا دیکھتے"]),
        (.mark,           ["متعین", "یہاں", "نشان", "یہ جگہ"]),
        (.help,           ["مدد", "کیا کہوں", "کمانڈ"]),
    ]

    /// Map a transcription to an intent. Always also checks English keywords so a
    /// mixed-language utterance still works. Returns `.unknown` for anything that
    /// isn't a command (the caller then treats it as a scene question).
    static func matchIntent(_ raw: String, langCode: String) -> VoiceIntent {
        let text = raw.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return .unknown }
        let tables: [[(VoiceIntent, [String])]]
        switch langCode {
        case "ar": tables = [arabic, english]
        case "ur": tables = [urdu, english]
        default:   tables = [english]
        }
        for table in tables {
            for (intent, keys) in table where keys.contains(where: { text.contains($0) }) {
                return intent
            }
        }
        return .unknown
    }
}
