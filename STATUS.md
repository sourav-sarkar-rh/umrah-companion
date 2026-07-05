# STATUS — where we left off

_Update this at the end of every session. Newest at top._

## 2026-07-04 (session 5 — Batch A verified on device; Batch B: YOLO wired + voice bug fixed)
**Device-verified (Sourav, on iPhone 16 Pro / iOS 26.5):** Kaaba cube + gold band renders on the table; LiDAR debug mesh overlay works; circuit counting + circuit voice work; screen stays awake.

**Bug found on device + fixed — the "Listening" wedge**
- Symptom: tapping the mic showed "Listening…" forever, and afterwards ALL voice (incl. circuit announcements) went dead.
- Root cause: push-to-talk had no stop path — `startListening` only ended on `isFinal` (often never fires), so it stayed listening with the audio session stuck in `.record` + the mic engine running, which blocked TTS.
- Fix (`SpeechService`): mic is now **tap-to-start / tap-to-stop** (`finishListening()` sends what was heard); **8 s safety auto-stop**; `stopListening` **restores the `.playback` session** so TTS resumes; if `audioEngine.start()` throws it tears down instead of hanging; recognition callback hops to `@MainActor`. VM `askAboutScene()` toggles; obstacle warnings suppressed while listening.

**Batch B — on-device object detection (YOLO + LiDAR), F10**
- `yolov8n.mlpackage` added to `project.yml` sources → `xcodegen generate` → Xcode compiles it to `yolov8n.mlmodelc` in the bundle (verified present) + auto-generates `yolov8n.swift`.
- `SceneVision` now runs **`VNCoreMLRequest` (80 COCO classes: person, chair, bottle, backpack, bench, suitcase, laptop…)**, confidence ≥ 0.35, `.scaleFill`; reuses the LiDAR depth-sampling for per-object distance; falls back to the Apple human-detector if the model is ever missing. **Was people-only before this session.**
- Spoken warnings generalized: `L10n.obstacleNear(label, dir, meters)` ("Careful, a chair is close, 1.2 meters on your left"); `obstacleName()` localizes `person`, uses the English term for other classes (per-language object vocab = later polish).
- Visual "what I see" readout added to `DemoView` (`detectionReadout`) — top 3 nearest objects with LiDAR distance, under the status banner. `nearestObstacle` chip now shows the object label.
- **NOT done / deferred:** positioned AR bounding boxes over the camera (needs `displayTransform` coordinate mapping + on-device alignment tuning — skipped to avoid shipping a misaligned HUD; the readout list covers the "it sees objects + ranges them" story reliably). The "ask what's around me" cloud answer still needs the Mac proxy running (`proxyURL` set to LAN IP).
- All compiles green on `iPhone 17 Pro,OS=26.5`; object detection + HUD accuracy are device-verify (ARKit blank on sim).

**Mute + fully-on-device scene description (session 5b)**
- **Mute toggle** (`warningsMuted`, speaker.slash button in top bar): silences the *automatic* obstacle warnings only — the on-screen readout + ritual announcements + on-demand answers still work. Addresses "warnings are annoying but useful."
- **"What's around me?" is now 100% on-device** — no proxy, no key, works offline. `answer()` builds the spoken description from the YOLO+LiDAR observations we already have via `L10n.sceneDescription()` ("Around you: chair 1.2 m ahead, someone 2.0 m right"). Chose this over embedding the Anthropic key on-device because it (a) respects the project's keep-keys-off-phone guardrail, (b) removes the Mac-server-on-same-wifi fragility, (c) is instant/offline. `ProxyClient` left in place (unused) for a future online "richer answer" mode. The cloud path is no longer needed for the demo.

---

## 2026-07-04 (session 4 — Batch A: Kaaba cube + LiDAR debug view + voice/idle fixes; YOLO model converted)
**Done (all compile green on `iPhone 17 Pro,OS=26.5`; AR content is device-verify-only)**
- **#5 Virtual Kaaba cube** — on center-mark raycast, `CompanionViewModel.placeKaaba(at:)` anchors a RealityKit `AnchorEntity` at the hit point: black `SimpleMaterial` box (`DemoTuning.kaabaSizeM` = 0.4 m, rests on the surface) + a gold metallic kiswa band around the upper third. Cleared on `restart()`. You now walk around a *visible* mini-Kaaba.
- **#4 "Terminator" LiDAR debug view** — `attach()` now enables `config.sceneReconstruction = .mesh` (LiDAR, guarded by `supportsSceneReconstruction`). New `toggleDebug()` flips `arView.debugOptions = [.showSceneUnderstanding, .showFeaturePoints, .showWorldOrigin]`. Toggle button (cube.transparent icon) added to the DemoView top bar. Shows the live room mesh for the "how it sees" demo moment; mesh also enables occlusion of the Kaaba cube by real furniture.
- **#3 Voice fix (hardened; NEEDS device retest)** — TTS path looked structurally fine, so the suspect is **RealityKit ARView seizing the shared audio session for spatial audio**. Fix: claim `.playback`/`.spokenAudio`/`.duckOthers` at `SpeechService.init`, **re-assert it right before every utterance**, and add a fallback voice so an edge locale can't go silent. Can't verify TTS headlessly — on device confirm you hear the "begin Tawaf" line on center-mark, and check hardware volume.
- **Screen stays on** — `UIApplication.shared.isIdleTimerDisabled = true` in `DemoView.onAppear` (reset onDisappear) so the phone never auto-locks mid-Tawaf.
- **YOLOv8n → Core ML converted** (headless, `models/convert` via `uv --with ultralytics --with coremltools`, `nms=True`, imgsz 640) → `ios/models/yolov8n.mlpackage` (12.2 MB, 80 COCO classes). **NOT yet added to the Xcode project / wired** — that's Batch B.

**Next — device-verify Batch A (human, one pass), then I build Batch B**
- Wireless install now possible: pair once over USB (Xcode → Devices → "Connect via network"), then installs go over WiFi (same network as Mac). Build still runs on the Mac; 7-day free-provisioning expiry still applies.
- Verify on phone: (1) mark center → black Kaaba cube with gold band appears on the table; (2) hear "begin Tawaf" (voice fix); (3) walk circles → counts + speaks each circuit; (4) tap the cube-icon top-right → live LiDAR wireframe mesh overlays the room; (5) screen doesn't auto-lock.
- **Batch B (after A verifies):** add `yolov8n.mlpackage` to `project.yml` → `xcodegen generate`; swap `SceneVision` human-detector for a `VNCoreMLRequest` YOLO path (reuse `distanceMeters` for LiDAR ranging); add a bounding-box + "label · Xm" HUD overlay view; extend spoken guidance to nearest object in the forward path. (F10 + F1/F2 obstacle story.)

---

## 2026-07-03 (session 3 — Xcode 26.6 upgrade, toolchain re-green)
**Done**
- **Upgraded Xcode 26.3 → 26.6** (Swift 6.3.3, iOS 26.5 SDK). Upgrade left the iOS platform component uninstalled → all builds failed with `Supported platforms … is empty` / `iOS 26.5 is not installed`. **Not a code regression** — Swift compiled clean throughout.
- Fixed by `xcodebuild -downloadPlatform iOS`. This installed **iOS 26.5 device support → "Sourav's iPhone" is now an eligible destination again** (device leg unblocked) and the 26.5 sim runtime.
- **Gotcha discovered:** `actool` (asset-catalog step) needs a sim runtime matching the SDK **even for device builds** — so a missing 26.5 sim runtime blocks *both* sim and device builds, not just sim.
- **Don't `killall -9 CoreSimulatorService`** to force runtime registration — it unmounts the in-flight disk image and corrupts it (`cannot find code object on disk`). Had to delete the broken runtime + re-download. The download registers the runtime on its own; no service kick needed.
- **Full app builds green under 26.6** for `iPhone 17 Pro,OS=26.5` (Build Succeeded, signed .app). Re-verified rendering by screenshot: F3 shell (English menu, orange tracking dot + "Point at the table…" banner, gold "Mark the Kaaba"), F14 app icon (in the Speech Recognition permission tile), F6 permission prompt all render; AR correctly blank on sim.
- Build recipe (updated sim + OS): `xcodebuild -project UmrahCompanion.xcodeproj -scheme UmrahCompanion -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' -derivedDataPath /tmp/umrah-dd build | xcbeautify`.

- **Tawaf demo confirmed working on the physical iPhone** (Sourav: pointed at the table, walked circles, it counted). F4 (center raycast), F5/F8 live on real hardware.
- **Sa'i (Safa↔Marwah) logic scaffolded:** new `Sources/AR/SaiTracker.swift` (pure, headless — projects position onto the Safa→Marwah line, counts a length on arrival at the opposite end with hysteresis; 7 lengths, ends at Marwah). Headless test `Tests/sai/main.swift` (own dir so it's `main.swift`) — **8/8 pass** incl. cap-at-7, one-way, jitter, 450m Mas'a scale, 80%-overshoot. Run: `cd ios && swiftc Sources/AR/SaiTracker.swift Tests/sai/main.swift -o /tmp/saisim && /tmp/saisim`. **NOT yet wired into the app UI** — needs a ritual-mode switch, two-anchor marking in the AR view, and localized voice strings (next session).

**AI-workflow note (Xcode 26.6 adds in-IDE Claude Agent via Agent Client Protocol)**
- Two-driver split: **Claude Code CLI + XcodeBuildMCP = headless engineer (primary)** for cross-cutting Swift+proxy+git work; **Xcode's in-IDE Claude Agent = co-pilot at the phone** for Sourav's device-tuning leg (F8) with live previews + device attached. Set up via Xcode → Settings → Intelligence → Anthropic (Claude sign-in preferred over API key). `STATUS.md` is the shared handoff.

**Next (unchanged — device leg, human)**
- Device destination now eligible + `DEVELOPMENT_TEAM` already set (`7F8WQJP8H6`). Set `proxyURL` to Mac LAN IP, start proxy, build/run to iPhone 16 Pro, grant permissions, do the table-as-Kaaba walk → tune F8. `-allowProvisioningUpdates` is in the device build recipe.

---

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
