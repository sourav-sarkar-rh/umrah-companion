# AI Umrah Companion — Product & Feature Plan

## Vision
Let a pilgrim with a disability perform Umrah/Hajj **independently** — without total reliance on a
human companion — by turning an ordinary iPhone into a voice-first guide that sees, counts, warns,
and reassures, in the pilgrim's own language. "Integration, not invention": every needed technology
already exists in 2026; the work is combining them well for this specific, underserved user.

## Target users (modalities)
Blind / low-vision · mobility-impaired · deaf / hard-of-hearing · cognitive disabilities.
**Demo focuses on blind / low-vision** (the most voice-native, most self-contained story).

## The demo (definition of done, v0)
Runs on iPhone 16 Pro, in a living room, no Mecca required. **The table = the Kaaba.**
Point at the table → "Kaaba marked" → walk 7 counter-clockwise loops → the app counts each circuit
aloud, warns about people/obstacles by distance, and announces "Tawaf complete." Optional: press-to-
talk "what's around me?" → spoken scene description.

## Feature list & status
Legend: ✅ done · 🟡 in progress · ⬜ todo · 🔮 later (post-demo)

### Core demo (v0 — "works on my phone")
- ✅ **F1 Cloud scene-description proxy** — FastAPI, mock+Claude/Gemini/OpenAI, tested.
- ✅ **F2 Tawaf circuit counter** (`TawafTracker`) — verified by simulation (7 loops → 7 circuits).
- ✅ **F3 App shell & demo UI** — SwiftUI screen, circuit ring, buttons. Builds + renders on sim (overlay, status banner, language menu, action button verified by screenshot).
- 🟡 **F4 ARKit session + center-mark raycast** — mark the table as center (scaffolded).
- 🟡 **F5 On-device obstacle detection + LiDAR distance** — Vision human detector + depth (scaffolded).
- 🟡 **F6 Voice I/O** — on-device STT (push-to-talk) + TTS narration (scaffolded).
- 🟡 **F7 First build** — Xcode 26.6 (Swift 6.3.3, iOS 26.5 SDK); full app **compiles + runs on the iPhone 17 Pro / iOS 26.5 simulator** (Build Succeeded, signed). Device destination ("Sourav's iPhone") now eligible after `xcodebuild -downloadPlatform iOS`; `DEVELOPMENT_TEAM` set. Device build (real AR + first-launch permissions) still pending — that's the human's leg.
- ⬜ **F8 On-device tuning** — circuit threshold at table radius; obstacle cadence; tracking-loss UX.
- 🟡 **F17 Tawaf circle-guidance (blind-usable)** — `TawafGuide` (pure, 9/9 headless tests) reports
  on-path / drifting-in / drifting-out / reversing + a signed steer + on-axis flag + radius error,
  learning the orbit radius from the first steps. `GuidanceAudio` synthesises a Soundscape-style
  panned beacon + on-axis confirmation tone + a separate radial-drift earcon (no audio assets).
  Terse egocentric spoken corrections. OFF by default, toggle in the top bar, auto-pauses while the
  mic listens. **Logic verified headlessly; beacon + AR steering are device-verify (blindfold walk).**
- 🟡 **F9 Live cloud path** — Anthropic key in `proxy/.env`; proxy→Claude verified live (English + Arabic). Phone→proxy leg pending F7.

### Polish (v0.1 — nicer demo)
- 🟡 **F10 YOLO object detection** — YOLOv8n **converted to Core ML** (`ios/models/yolov8n.mlpackage`, 80 COCO classes, on-device). Not yet added to the project / wired into `SceneVision` + HUD — that's the next build (Batch B).
- 🟡 **F15 Virtual Kaaba in AR** — black cube + gold kiswa band anchored at the marked center (`DemoTuning.kaabaSizeM`). Compiles; device-verify pending.
- 🟡 **F16 LiDAR debug/"Terminator" view** — toggle shows the live scene-reconstruction mesh + feature points (`showSceneUnderstanding`). Compiles; device-verify pending.
- 🟡 **F11 Multi-language, ground-up** — runtime language switch (English/Arabic/Urdu) flips UI text,
  voice (TTS/STT locale), cloud replies, **right-to-left layout**, and Arabic-Indic numerals. Arabic
  strings written for demo (need native proofing). `Localization/Localization.swift`.
- ✅ **F14 Branding & graphics** — app icon (Kaaba + voice rings, gold/teal) + `LaunchView` splash both render on sim (verified by screenshot). Native-proof Arabic on device.
- ⬜ **F12 Haptics & VoiceOver polish** — milestone haptics, full screen-reader pass.
- ⬜ **F13 Standalone proxy** — deploy proxy to a small cloud host so the phone needs no laptop.

### Later (real product — mostly out of demo scope) 🔮
Sa'i ritual · other disability modes · custom Mecca-landmark CV dataset · Android/ARCore ·
companion matching · Nusuk/Tawakkalna/Nafath integrations · emergency signal · in-Kingdom PDPL
hosting · sign-language video · Hajj-scale load. (See `docs/` for the full architecture.)

## Non-goals for the demo
Accounts/login, backend persistence, multi-user, app-store distribution, real Mecca data.
