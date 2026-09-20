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

_Status re-checked 2026-09-20 against the actual device-verify pass. Every core feature below
except the web portal was verified on iPhone 16 Pro across ~20 trials with friends and
co-workers. This list had been stale since 2026-07-05._

### Core demo (v0 — "works on my phone")
- ✅ **F1 Cloud scene-description proxy** — FastAPI, mock+Claude/Gemini/OpenAI, tested.
- ✅ **F2 Tawaf circuit counter** (`TawafTracker`) — verified by simulation (7 loops → 7 circuits).
- ✅ **F3 App shell & demo UI** — SwiftUI screen, circuit ring, buttons. Builds + renders on sim (overlay, status banner, language menu, action button verified by screenshot).
- ✅ **F4 ARKit session + center-mark raycast** — mark the table as center. Device-verified.
- ✅ **F5 On-device obstacle detection + LiDAR distance** — Vision human detector + depth. Device-verified.
- ✅ **F6 Voice I/O** — on-device STT (push-to-talk) + TTS narration. Device-verified.
- ✅ **F7 First build** — Xcode 26.6 (Swift 6.3.3, iOS 26.5 SDK); full app **compiles + runs on the iPhone 17 Pro / iOS 26.5 simulator** (Build Succeeded, signed). Device destination ("Sourav's iPhone") now eligible after `xcodebuild -downloadPlatform iOS`; `DEVELOPMENT_TEAM` set. Device build done — runs on iPhone 16 Pro.
- 🟡 **F8 On-device tuning** — indoor tuning done across ~20 trials. **Outdoor/sunlight tuning still
  to do** (time-of-flight depth degrades in direct sun), and obstacle ranking in dense crowds needs
  work — the depth field reads as one continuous surface rather than discrete obstacles.
- ✅ **F17 Tawaf circle-guidance (blind-usable)** — `TawafGuide` (pure, 9/9 headless tests) reports
  on-path / drifting-in / drifting-out / reversing + a signed steer + on-axis flag + radius error,
  learning the orbit radius from the first steps. `GuidanceAudio` synthesises a Soundscape-style
  panned beacon + on-axis confirmation tone + a separate radial-drift earcon (no audio assets).
  Terse egocentric spoken corrections. OFF by default, toggle in the top bar, auto-pauses while the
  mic listens. **DEVICE-VERIFIED on iPhone 16 Pro (2026-07-05): drift-out → "ease inward", drift-in
  toward the Kaaba → "ease outward" both fire correctly.** Beacon-tone tuning still to taste.
- ✅ **F19 Sa'i as a ritual mode** — Tawaf and Sa'i share one screen (a MODE switch, not a nav stack —
  blind-hostile navigation avoided). Idle screen selects the ritual; Sa'i marks Safa + Marwah (two AR
  pillars), wires the tested `SaiTracker`, announces each length + turn-around, ring shows lengths/7,
  linear beacon guidance toward the endpoint. **Device-verified.**
- ✅ **F20 Voice command layer** — one entry point (mic button · double-tap anywhere · VoiceOver
  magic-tap). `VoiceCommands` pure on-device intent matcher (fixed grammar, EN/AR/UR, 21/21 tests):
  select tawaf/sai, mark, reset, describe, guidance, mute, du'a, count, help. Non-commands fall
  through to the on-device scene answer. Spoken confirmations. **Device-verified.**
- ✅ **F21 Du'a guidance (optional)** — Off / Prompt / Recite, default OFF, top-bar button + voice.
  Non-prescriptive; **safety always interrupts a recitation**. Short authentic phrase (reciter audio
  to replace TTS in production). **Device-verified, including the safety interrupt.**
- ✅ **F9 Live cloud path** — proxy→Claude verified live (English + Arabic); phone→proxy leg verified on device. Requires the proxy running on the LAN (see `proxy/README.md`); with no key the proxy runs in mock mode.

### Polish (v0.1 — nicer demo)
- ✅ **F10 YOLO object detection** — YOLOv8n converted to Core ML (`ios/models/yolov8n.mlpackage`, 80 COCO classes, on-device), wired into `SceneVision` with Apple's Vision human detector as fallback; each detection ranged by the LiDAR depth map. Device-verified. Note: this is the stock COCO model, **not** a Hajj-specific dataset — crowd detection rides the COCO `person` class.
- ✅ **F15 Virtual Kaaba in AR** — black cube + gold kiswa band anchored at the marked center (`DemoTuning.kaabaSizeM`). Device-verified.
- ✅ **F16 LiDAR debug/"Terminator" view** — toggle shows the live scene-reconstruction mesh + feature points (`showSceneUnderstanding`). Device-verified.
- 🟡 **F11 Multi-language, ground-up** — runtime language switch (English/Arabic/Urdu) flips UI text,
  voice (TTS/STT locale), cloud replies, **right-to-left layout**, and Arabic-Indic numerals. Arabic
  strings written for demo — **still need native Arabic proofing**. `Localization/Localization.swift`.
- ✅ **F14 Branding & graphics** — app icon (Kaaba + voice rings, gold/teal) + `LaunchView` splash both render on sim (verified by screenshot). Native-proof Arabic on device.
- ⬜ **F12 Haptics & VoiceOver polish** — milestone haptics, full screen-reader pass.
- ⬜ **F13 Standalone proxy** — deploy proxy to a small cloud host so the phone needs no laptop.

### Later (real product — mostly out of demo scope) 🔮
Other disability modes · custom Mecca-landmark CV dataset · Android/ARCore ·
companion matching · Nusuk/Tawakkalna/Nafath integrations · emergency signal · in-Kingdom PDPL
hosting · sign-language video · Hajj-scale load. (See `docs/` for the full architecture, and
**`FUTURE.md`** for the researched post-demo roadmap across disabilities — crowd-crush warning,
heat-exertion guardian, scene narrator, deaf alerts, cognitive one-step mode — plus the blind-iOS
design reference behind F17/F20.)

## Non-goals for the demo
Accounts/login, backend persistence, multi-user, app-store distribution, real Mecca data.
