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
- 🟡 **F7 First build** — Xcode 26.3 installed; full app **compiles + runs on iOS 17 Pro simulator** (one fix: `return switch` in `obstacleChip`). Device build (signing + real AR) still pending — that's the human's leg.
- ⬜ **F8 On-device tuning** — circuit threshold at table radius; obstacle cadence; tracking-loss UX.
- 🟡 **F9 Live cloud path** — Anthropic key in `proxy/.env`; proxy→Claude verified live (English + Arabic). Phone→proxy leg pending F7.

### Polish (v0.1 — nicer demo)
- ⬜ **F10 YOLO object detection** — convert YOLOv8n → Core ML for richer labels beyond "person".
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
