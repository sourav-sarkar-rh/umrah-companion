# AI Umrah Companion — START HERE

> **For a new chat:** the user says "umrah" (maybe + a feature or a next step).
> Reconstruct context from the **Context map** below, then follow the **Working process**.
> You do NOT need the user to re-explain the project — read these files first.

**What it is.** A native iOS app that guides pilgrims **with disabilities** through Umrah/Hajj
rituals. First slice (what we're building): the **blind / low-vision** experience for **Tawaf** —
voice guidance, live scene description, real obstacle warnings, and automatic counting of the
7 circuits. Voice-first, on-device-first; one optional cloud call for open-ended scene reasoning.

**Not a Redesign Health product.** It's a personal/venture build that happens to live in the
`redesign/` workspace. Don't wire it into RH infrastructure (no RH Linear, no RH Supabase, no
company hosting). Inspiration only from the RH projects' *conventions*.

**End goal for now (the definition of done):** it **runs on Sourav's iPhone (16 Pro)** and does the
table-as-Kaaba demo end-to-end. Everything is scoped to that.

## Context map — read these to get up to speed
1. **`README.md`** — one-paragraph what/why + repo layout.
2. **`PRODUCT.md`** — product vision, target users, the demo definition, and the **feature list
   with status** (F1…Fn). This is the source of truth for *what* we're building and *what's next*.
3. **`STATUS.md`** — the living "where we left off": done / in progress / next / blockers. **Update
   this at the end of every working session.**
4. **`ios/README.md`** — how to generate the Xcode project, sign, and run on the phone.
5. **`proxy/README.md`** — the cloud scene-description service (runs on the Mac).
6. **`docs/`** — the original architecture PDF + hackathon submission (the full long-term vision;
   most of it is deliberately out of scope for the demo).

## Working process (how we build a feature)
1. **Scope.** Pick the feature from `PRODUCT.md`. Push back if it's over-built for a home demo —
   the bar is "works on the phone in a living room", not "Hajj-scale production".
2. **Build.** Native SwiftUI + ARKit/Vision/Speech on-device; Python FastAPI for the one cloud
   call. Match the existing code's style. Keep pure logic (e.g. `TawafTracker`) free of UIKit/ARKit
   imports so it stays unit-testable without a device.
3. **Verify — this is our "Playwright" (see Testing below).** Run the logic sims + proxy tests.
   For AR/camera behavior that can't be automated, build to the phone and eyeball it.
4. **Wrap.** Update `PRODUCT.md` feature status + `STATUS.md`. Commit only when asked.

## Testing (what CAN be automated without a device)
The camera/LiDAR/ARKit paths need a real phone, but the **decision logic** is testable on the Mac
with no Xcode:
- **Ritual logic (Swift):** `cd ios && swiftc Sources/AR/TawafTracker.swift Tests/main.swift -o /tmp/tawafsim && /tmp/tawafsim`
  — drives the real `TawafTracker` with a simulated pilgrim walking loops; asserts it counts 7.
- **Cloud proxy (Python):** `cd proxy && uv run --with pytest --with httpx pytest -q`
  — mock-mode tests, always pass offline.
Keep new business logic behind this line so we can regression-test it here. Treat "I can't unit
test it, it needs the phone" as a signal to move logic OUT of the AR/UI layer.

## AI-assisted iOS workflow — verified 2026 best practice
The agent NEVER opens Xcode. It builds/tests headlessly and reads parsed output.
- **Build (sim):** `xcodebuild -project ios/UmrahCompanion.xcodeproj -scheme UmrahCompanion -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build | xcbeautify`
- **Test (sim):** `xcodebuild test -scheme UmrahCompanion -destination 'platform=iOS Simulator,name=iPhone 16 Pro' | xcbeautify`
- **See non-AR UI:** boot sim + `xcrun simctl io booted screenshot out.png`, or use the **XcodeBuildMCP** tools (build/run/test/screenshot as structured calls — see *Toolchain setup* below).
- **Diagnostics:** `xcode-build-server config -project ios/UmrahCompanion.xcodeproj -scheme UmrahCompanion` (generates buildServer.json → sourcekit-lsp project-wide errors). `swiftlint` for style.
- **Device build/run:** needs signing → the human. `-destination 'platform=iOS,id=<UDID>'`.

**Non-negotiable gotchas (these waste the most agent time):**
1. **ARKit is BLANK on the simulator** (`ARWorldTrackingConfiguration.isSupported == false`). A green sim build + a black AR screenshot does NOT mean AR works. Never conclude AR correctness from the simulator — only the physical iPhone 16 Pro can show it, judged by the human.
2. **Never hand-edit `.pbxproj`** — edit `ios/project.yml` and re-run `xcodegen generate`.
3. `swiftc`-single-file sims are a fast smoke check, NOT a substitute for `xcodebuild` (they miss import/access errors).
4. Device signing/provisioning, first-launch permission taps (camera/mic/speech/local-network), and judging AR spatial correctness are ALWAYS the human's job.

## Backlog to raise AI leverage (ranked, from the 2026 research — see git/chat)
1. ✅ XcodeBuildMCP registered (this folder only — see *Toolchain setup*) · ✅ xcbeautify / xcode-build-server / swiftlint installed.
2. ⬜ Factor pure logic into a local SPM package `UmrahCore` (TawafTracker, Localization, models) so it
   runs under `swift test` + gets sourcekit-lsp for free; app target depends on it via XcodeGen.
3. ⬜ Extend protocol boundaries (`PositionSource`, `ObstacleSource`) so obstacle/voice logic is
   fake-injectable and headless-testable — not just TawafTracker.
4. ⬜ swift-snapshot-testing for non-AR UI (RTL, Arabic-Indic numerals, language menu, launch) — CI record mode = never.
5. ⬜ Thin GitHub Actions (`macos-26`, no signing): `swift test` + `pytest` + snapshots on push.
6. ⬜ Record one ARKit position/depth fixture during a device session → replay headlessly forever.
7. Inject/InjectionIII + SwiftUI Previews = for SOURAV's device-tuning (F8), not the agent.

## Toolchain setup (verified 2026-08-28)

**XcodeBuildMCP is scoped to THIS FOLDER, not user scope.** It is registered in
`.mcp.json` in this directory (checked in). Consequences:

- **Start sessions from here** — `cd ~/redesign/build/umrah-companion && claude`. Started from
  `redesign/` root (the RH workspace) the MCP is NOT loaded; Claude Code only reads `.mcp.json`
  from the directory it launches in. Claude Code prompts once per machine to approve the server.
- **Why folder-scoped:** user scope would add the server's tools to every Redesign Health session,
  where MCP-registry truncation is already a live problem. This is a personal build — it must not
  cost RH sessions anything.
- **Install:** Homebrew, `brew tap getsentry/xcodebuildmcp && brew trust getsentry/xcodebuildmcp &&
  brew install xcodebuildmcp` → `/opt/homebrew/bin/xcodebuildmcp` (v2.7.0). `npm install -g` does
  NOT work on this Mac — npm's prefix is `/usr/local`, root-owned. `brew trust` is required; the tap
  is Sentry's own (github.com/getsentry/XcodeBuildMCP).
- **v2 renamed the entrypoint:** the server is `xcodebuildmcp mcp`. A bare `npx -y xcodebuildmcp`
  (the v1 form, still in old notes) silently fails to start. `.mcp.json` pins the absolute binary
  path, so there is no npx cold start and no network dependency at launch.
- **The MCP is optional.** v2 also installs a full CLI on PATH (`xcodebuildmcp tools` lists ~100
  commands, e.g. `xcodebuildmcp simulator build --scheme UmrahCompanion`). That works from ANY
  directory via plain Bash, so a session at `redesign/` root can still build, test, boot sims and
  screenshot — it just lacks the structured tool calls. The MCP server itself exposes ~24 tools.
- **Verify it's alive** without launching a session:
  `xcodebuildmcp --version` and `xcodebuildmcp tools | head`.

**Environment as of 2026-08-28:** Xcode 26.6 (build 17F113), active at
`/Applications/Xcode.app/Contents/Developer`. `xcodegen`, `xcbeautify`, `swiftlint`,
`xcode-build-server` all present at `/opt/homebrew/bin`. `UmrahCompanion.xcodeproj` exists with the
single scheme `UmrahCompanion`.

## Guardrails (project-specific)
- **On-device first.** Never stream video to the cloud. Only structured observations + at most ONE
  still frame, and only when the user explicitly asks. This is the privacy contract.
- **Graceful offline.** Every cloud path has an on-device fallback; the demo must work with no key
  and flaky wifi (proxy `mock` mode; on-device TTS/STT).
- **No login, no accounts, no companion-matching for the demo.** Straight into the ritual.
- **Keys stay off the phone.** LLM key lives in `proxy/.env` only. The phone talks to the proxy.

## Stack (decided)
Native **SwiftUI + ARKit + Vision + Speech** (NOT Flutter — right for the eventual cross-platform
product, pure overhead for a single-device demo). Thin **Python FastAPI** proxy (`uv`). Cloud LLM =
**Anthropic Claude** (multimodal); Gemini/OpenAI also supported by the proxy. Device: iPhone 16 Pro
(LiDAR + Apple Intelligence). Project generated from `ios/project.yml` via **XcodeGen**.
