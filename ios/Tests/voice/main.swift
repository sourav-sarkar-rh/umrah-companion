// Headless test for the voice-command matcher. Pure Foundation:
//   cd ios && swiftc Sources/Voice/VoiceCommands.swift Tests/voice/main.swift -o /tmp/voicesim && /tmp/voicesim
import Foundation

var failures = 0
func expect(_ got: VoiceIntent, _ want: VoiceIntent, _ phrase: String) {
    let ok = got == want
    print((ok ? "  ok   " : "  FAIL ") + "\"\(phrase)\" → \(got.rawValue) (want \(want.rawValue))")
    if !ok { failures += 1 }
}
func m(_ s: String, _ code: String = "en") -> VoiceIntent { VoiceCommands.matchIntent(s, langCode: code) }

print("VoiceCommands matcher")

// English commands
expect(m("Start Tawaf"), .selectTawaf, "Start Tawaf")
expect(m("let's do the Sa'i"), .selectSai, "let's do the Sa'i")
expect(m("mark the kaaba"), .mark, "mark the kaaba")            // 'mark' wins; not 'kaaba'→tawaf
expect(m("mark this spot"), .mark, "mark this spot")
expect(m("start again"), .reset, "start again")                 // reset beats select/mark
expect(m("what's around me?"), .describe, "what's around me?")
expect(m("what do you see"), .describe, "what do you see")
expect(m("turn on walk guidance"), .toggleGuidance, "turn on walk guidance")
expect(m("mute the warnings"), .toggleMute, "mute the warnings")
expect(m("how many circuits left"), .count, "how many circuits left")
expect(m("what can I say"), .help, "what can I say")

// Not a command → unknown (caller routes to scene description)
expect(m("is my mother here"), .unknown, "is my mother here")
expect(m(""), .unknown, "(empty)")

// Priority: 'start again' must not be captured by selectTawaf/mark
expect(m("please start over"), .reset, "please start over")

// Arabic / Urdu (script) resolve; English still works under those locales
expect(m("طواف", "ar"), .selectTawaf, "طواف (ar)")
expect(m("ماذا حولي", "ar"), .describe, "ماذا حولي (ar)")
expect(m("سعی", "ur"), .selectSai, "سعی (ur)")
expect(m("Start Tawaf", "ar"), .selectTawaf, "Start Tawaf under ar locale")

print(failures == 0 ? "\nALL PASS" : "\n\(failures) FAILURE(S)")
exit(failures == 0 ? 0 : 1)
