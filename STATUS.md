# STATUS — where we left off

_Update this at the end of every session. Newest at top._

## 2026-07-03 (session 2 — Xcode installed, first build)
**Done**
- **Xcode 26.3 installed** and made active (`sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`). F7 unblocked.
- `xcodegen generate` → clean `.xcodeproj`. **Full app builds for the iOS 17 Pro simulator** (Xcode 26 ships the 17-series sims, not 16 Pro — sim target is compile-only, the physical device stays iPhone 16 Pro).
- **One compile error fixed:** `L10n.obstacleChip` had a `let m = …` before its `switch`, so the switch was no longer an implicit-return expression → added `return switch`. (The other two phrase builders were fine — switch was their sole statement.) The scaffolded F3–F6/F11/F14 code otherwise compiled as written.
- **Rendering verified on sim by screenshot:** F3 app shell (language menu, status banner + tracking dot, gold "Mark the Kaaba" button), F14 launch splash (teal gradient, gold voice-rings around the Kaaba+kiswa, serif title + gold tagline) and app icon (in the permission tile), F11 English strings. AR view is correctly blank on sim (gotcha #1).
- Build recipe that works: `xcodebuild -project UmrahCompanion.xcodeproj -scheme UmrahCompanion -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath /tmp/umrah-dd build | xcbeautify`.

**Not yet verified (needs device / human)**
- Arabic RTL layout + Arabic-Indic numerals — logic is wired, but eyeball on device with a native speaker (strings still need proofing).
- Everything AR: center-mark raycast (F4), obstacle depth (F5), voice loop on real mic (F6), Tawaf counting while walking (F8). Sim can't show any of it.

**Next (device leg — human)**
1. Set `DEVELOPMENT_TEAM` in `ios/project.yml` (your personal Apple ID team) → `xcodegen generate`.
2. Set `UmrahCompanionApp.proxyURL` to your Mac's LAN IP (`ipconfig getifaddr en0`), start proxy: `cd proxy && uv run uvicorn app:app --host 0.0.0.0 --port 8077`.
3. Build to the iPhone 16 Pro (`-destination 'platform=iOS,id=<UDID>'` or via Xcode Run), grant camera/mic/speech/local-network on first launch.
4. Do the table-as-Kaaba walk → tune F8 (circuit threshold at table radius, obstacle cadence).

---

## 2026-07-03 (session 1)
**Done**
- Repo set up: `proxy/` (FastAPI), `ios/` (SwiftUI scaffold), `docs/` (source PDFs), START-HERE docs.
- F1 proxy built + tested (4 pytest pass, mock mode). Runs: `cd proxy && uv run uvicorn app:app --host 0.0.0.0 --port 8077`.
- F2 `TawafTracker` circuit logic built + verified by simulation (6/6 checks pass, no Xcode needed).
- F9 live cloud path verified: real Claude (claude-sonnet-5) scene descriptions in English + Arabic via the proxy. Anthropic key is in `proxy/.env`; proxy now auto-loads it (python-dotenv). Phone leg still pending F7.
- F11 multi-language built ground-up: `Localization/Localization.swift` (EN/AR/UR), runtime language menu, RTL layout, Arabic-Indic numerals; VM + DemoView localized. Arabic strings need native proofing.
- F14 branding: app icon generated (`ios/scripts/make_icon.py` → Assets.xcassets, Kaaba + gold voice rings on teal) + Arabic `LaunchView` splash. Rendering to verify on device.
- F3–F6 scaffolded in Swift (UI, ARKit center-mark, Vision+LiDAR obstacles, voice I/O) — **written without a compiler, not yet built.**
- Google Slides overview deck (in Google Drive): https://docs.google.com/presentation/d/1PfbCi794jCizl6U01zO4wsR1gcpFjBL6GTIhFylkiCM/edit

**Blocker**
- **Xcode.app not installed** (only Command Line Tools). Required for F7 (first device build). User installing from App Store.

**Next (in order)**
1. F7 — once Xcode is in: `brew install xcodegen && cd ios && xcodegen generate && open UmrahCompanion.xcodeproj`; set signing team; set `proxyURL` to Mac's LAN IP; build to iPhone; fix compile errors.
2. F8 — tune circuit threshold + obstacle cadence live on the phone.
3. F9 — add `ANTHROPIC_API_KEY` to `proxy/.env`; verify "what's around me?" cloud path.
4. Decide F13 (deploy proxy to cloud) if the demo must run without the laptop.

**Open questions for Sourav**
- Exact iPhone model (16 Pro vs Pro Max) — confirmation only, no code impact.
- Whether the demo must be laptop-free (→ do F13) or Mac-on-same-wifi is fine.
