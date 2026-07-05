# AI Umrah Companion — Future Roadmap & Design Research

> **Status: deferred / post-demo.** Nothing here is in the current build. The demo
> is the blind/low-vision Tawaf + Sa'i slice (see `PRODUCT.md`). This file captures
> the research done on 2026-07-05 for where the product goes *after* the demo:
> other disabilities, other iPhone-Pro capabilities, and the blind-iOS design
> patterns that should be reused when building any of it.
>
> Two parts:
> - **Part A — Future feature roadmap** (new use cases beyond blind-Tawaf).
> - **Part B — Blind/low-vision iOS design reference** (the patterns that already
>   informed F17 circle-guidance + F20 voice; reuse them for future modalities).

---

# Part A — Future feature roadmap (beyond blind-Tawaf)

## A1. iPhone 16 Pro / 17 Pro capabilities relevant to disabled pilgrims

Accurate, with model flags. The pilgrimage environment is dense, hot, loud, and
has congested cellular near the Haram — bias everything **on-device**.

**Depth / vision**
- **LiDAR scanner** (Pro-only, both models): time-of-flight depth to ~5 m; obstacle/
  curb detection, distance callouts, works in darkness. Already used in the demo;
  generalizes to any close-range mobility task.
- **Cameras:** 16 Pro = 48MP wide + 48MP ultra-wide (120°) + 12MP 5× tele. 17 Pro =
  all three 48MP, tele now **8× optical**. Long tele = reading distant signage/gate
  numbers; ultra-wide = wide crowd-scene framing.

**Compute / AI**
- **Neural Engine + on-device Apple Intelligence:** A18 Pro / A19 Pro (17 Pro: 16-core
  NE, 12GB RAM) run an on-device LLM + vision models — local object detection, scene
  captioning, short LLM reasoning with no network.
- **Visual Intelligence:** on-device camera understanding — reads/translates text,
  identifies objects, "what am I looking at." Invoked via **Camera Control** (16/17 Pro
  only) or Action Button.
- **Live Translation (iOS 26):** on-device text/voice translation — pilgrims come from
  190+ countries and rarely share a language.

**Buttons**
- **Camera Control** (16/17 Pro): pressure-sensitive; press-hold launches Visual
  Intelligence — a single physical "tell me what's around me" trigger.
- **Action Button** (15 Pro+): remappable hardware trigger — eyes-free panic/help or
  "orient me."

**Positioning**
- **U2 Ultra-Wideband** (16/17 Pro): Precision Finding, few-inches accuracy, ~60 m open
  air but **degrades sharply indoors / in dense crowds** (bodies + walls block it).
  Good for "find my group member / wheelchair" — do NOT over-promise range in the Mataf.

**Audio / haptics**
- **Spatial audio (AVAudioEngine):** directional virtual beacons (Soundscape technique;
  already used in F17).
- **Core Haptics (AHAP):** custom vibration patterns for eyes-free/ears-free cues.
- **Music Haptics** (iOS 18): renders audio as taps — repurposable for deaf pilgrims.
- **Sound Recognition** (accessibility): on-device detection of sirens/alarms/custom
  sounds → visual/haptic alert.

**Health / environment — note the gaps**
- **No ambient- or body-temperature sensor.** iPhone can't measure heat directly; only
  networked weather (→ computed wet-bulb/heat index) + the barometer. Heat features must
  use networked weather + exertion proxies (motion, pace, paired Apple Watch HR).

**Connectivity / SOS — hard constraint**
- **Emergency SOS via satellite and Messages via satellite are NOT available in Saudi
  Arabia.** Do NOT design any Mecca safety feature around satellite SOS. Fall back to
  cellular/Wi-Fi and local Saudi emergency channels.

**iOS accessibility APIs to build on**
- iOS 18: Music Haptics, Vehicle Motion Cues, Eye Tracking, Vocal Shortcuts, Listen for
  Atypical Speech, Personal Voice.
- iOS 26: **Accessibility Reader** (system-wide read-aloud), **Braille Access** + **Live
  Captions in braille** (deafblind), faster Personal Voice, Accessibility Nutrition Labels.

## A2. Existing app landscape (table-stakes vs novel)

- **Nusuk** (official Ministry of Hajj & Umrah platform): permits/booking, **smart maps
  and navigation inside the holy sites**, crowd-management tech, 130+ services, syncs with
  Tawakkalna. Generic wayfinding + permits are table-stakes — **do not rebuild them.**
- **Tawakkalna:** identity/health/safety compliance layer.
- **Western blind-nav apps:** Microsoft Soundscape (3D audio beacons; open-sourced),
  BlindSquare, Lazarillo, Seeing AI (OCR/scene), Aira (live human agents), Google Lookout.
  **None are ritual-aware**, none handle Mataf/Sa'i geometry, none are Arabic-liturgy or
  crowd-crush aware.

**White space (our defensible novelty):** ritual-aware, disability-first guidance —
counting circuits, orienting to the Kaaba / Safa–Marwah, crowd-density safety.

**Safety context motivating crowd/heat features:** 2015 Mina crush ≈ 2,400 deaths;
densities above **6–7 persons/m²** trigger involuntary crowd waves; 2024 Hajj ≈ 1,300 heat
deaths at >50 °C. Crowd-density and heat-exertion warnings are the highest-value safety
additions.

## A3. Prioritized feature table

| # | Feature | Disability served | iPhone capability | Feasibility (solo) | Demo-able at home? | Novelty |
|---|---------|-------------------|-------------------|--------------------|--------------------|---------|
| 1 | **Crowd-density crush warning** — camera vision estimates people/m²; haptic+voice "too dense, move right / stop" | All (esp. blind, mobility, elderly) | Ultra-wide + NE person-detection + Core Haptics | Medium | Yes (crowd photos/video, busy street) | High — no app does this |
| 2 | **Sa'i ritual counter + orientation** | Blind, cognitive, elderly | ARKit + LiDAR + spatial audio | Easy (reuses Tawaf code) | Partial (hallway walk) | High | ✅ **now shipped as F19** |
| 3 | **Point-and-ask scene narrator** — Camera Control → Visual Intelligence describes/reads signs, gate numbers, translates | Blind, cognitive, non-Arabic | Camera Control + Visual Intelligence + tele | Easy (OS feature) | Yes | Medium |
| 4 | **Deaf announcement + alarm alert** — Sound Recognition → screen flash + haptic + live caption | Deaf / HoH | Sound Recognition + Live Captions + Haptics | Medium | Yes (play alarms) | High for pilgrimage |
| 5 | **Live two-way translation** — pilgrim ↔ Arabic staff, hands-free | Cognitive, non-Arabic, deaf (text) | Live Translation (iOS 26), on-device | Easy | Yes | Medium |
| 6 | **Heat-exertion guardian** — networked wet-bulb + motion/pace (+Watch HR) → "rest, hydrate, shade" | Elderly/frail, all | Weather API + CoreMotion + HealthKit (NOT onboard temp) | Medium | Yes (simulate) | High — targets #1 fatal risk |
| 7 | **Find-my-companion / group** — UWB Precision Finding to a paired iPhone/AirTag | Blind, cognitive, elderly | U2 UWB + spatial audio | Medium | Yes (two devices) | Medium; degrades in crowds |
| 8 | **Wheelchair route + ramp/obstacle scout** — LiDAR flags steps/curbs/gaps, routes to lifts | Mobility / wheelchair | LiDAR + ARKit | Medium | Partial | High |
| 9 | **Simplified one-step ritual mode** — big-button, one instruction/screen, Personal Voice | Cognitive/intellectual, elderly | Assistive Access-style UI + Personal Voice + Accessibility Reader | Easy | Yes | High |
| 10 | **Haptic-only guidance track** — distinct AHAP patterns for turn/stop/lap for deafblind | Deafblind | Core Haptics + Braille Access (iOS 26) | Medium | Yes | Very high — unserved |

## A4. Top 5 recommendations

1. **Crowd-density crush warning (#1).** Highest real-world value (Mina-crush toll) and a
   visceral investor demo — point at any crowd photo, watch it escalate to a haptic "move"
   alert. No competitor does it.
2. **Sa'i ritual counter (#2).** ✅ Already shipped (F19) — reused the Tawaf engine, doubled
   ritual coverage. Proves "a platform, not a one-off."
3. **Point-and-ask scene narrator via Camera Control (#3).** Leans on the 16/17 Pro's
   flagship button + on-device Visual Intelligence; low-effort/high-polish; demos instantly
   indoors; serves blind, cognitive, and language-barrier pilgrims at once.
4. **Heat-exertion guardian (#6).** Targets the deadliest recent failure mode (heat);
   reframes the app from "navigation" to "keeps you alive." Be honest it uses networked
   weather + motion, not an onboard thermometer.
5. **Simplified one-step ritual mode with Personal Voice (#9).** Opens an underserved
   modality (cognitive/intellectual, elderly); easy build; a family member's Personal Voice
   guiding them is an emotionally powerful demo moment.

## A5. Critical caveats

- **Satellite SOS does not work in Saudi Arabia.** Any emergency feature must use
  cellular/Wi-Fi + local Saudi emergency channels.
- **Crowd-density and heat warnings are advisory, not authoritative.** Never let a phone
  estimate override official guidance or create false confidence. Frame as "consider
  moving"; defer to on-site marshals.
- **UWB Precision Finding degrades badly in dense crowds/indoors** — the exact Mataf
  conditions. Scope "find my group" to short range / line-of-sight.
- **Religious accuracy is non-negotiable.** Circuit counting, start/stop lines (Black Stone
  corner, Safa/Marwah), ritual sequencing must be validated by a qualified scholar — an
  off-by-one lap or wrong orientation invalidates the rite. Use a human-verified rules
  layer, not LLM free-generation, for anything liturgical.
- **On-device is the right default.** Cellular near the Haram is congested; heat throttles
  radios. Keep detection/guidance on-device; treat network as optional.
- **Don't rebuild Nusuk.** Permits, booking, site maps are owned by the official platform.
  Position as a disability-first companion layer, ideally interoperable with Nusuk.

## A6. Sources (Part A)

iPhone 16 Pro (Wikipedia) · iPhone 17 Pro specs (Apple) · Visual Intelligence (Apple
Support) · U2/Precision Finding (9to5Mac) · Satellite country list (MacRumors) · iOS 26
accessibility (AppleVis) · iOS 18 accessibility (Gadget Hacks) · Nusuk (Saudipedia) · 2015
Mina stampede (Wikipedia) · 2024 Hajj heat deaths (The Conversation) · Core Haptics (Apple
Developer).

---

# Part B — Blind/low-vision iOS design reference

> These patterns already informed **F17 circle-guidance** and **F20 voice control**. Reuse
> them when building any future modality (esp. #3, #9, #10 above). Numeric constants
> (exact Hz / tolerance angles / dB) were not available from the primary sources — set and
> tune them in field/simulator testing; the mappings and dead-band principles below are
> what transfer.

## B1. Non-visual directional guidance

**The Soundscape beacon (reference design, copy it):**
- A **world-locked rhythmic beacon** (a steady tick), rendered in 3D/stereo so it **pans
  left/right by your heading relative to it**.
- **Proximity is NOT loudness** — beacon volume is constant; distance comes from occasional
  spoken updates. Loudness-as-distance is ambiguous and fatiguing.
- When **facing the beacon**, a distinct **steady confirmation tone** layers over the tick.
  That "you're pointed right" tone is the single most important cue — the user sweeps their
  heading until it locks, then walks. *(F17 implements exactly this.)*

**Sonification parameters the literature supports:**
- **Pitch reads more accurately than tempo/duration** — use pitch, not beat-spacing, for
  fine correction.
- **Signed pitch for bearing error** (keyboard convention: low = rotate left, high = rotate
  right, mid = on course).
- **Pan = coarse direction; pitch = fine correction.** Combine them.
- **On-course dead-band** (~±10–15°) triggers the confirmation tone, so the user isn't
  chasing micro-corrections.

**Verbosity — turn it DOWN.** Blind travelers navigate **egocentrically** (body-relative).
- Egocentric phrasing only ("bear slightly left", "turn around") — never "head north."
- Non-speech audio is the **primary continuous channel**; **speech is for discrete events**
  (milestone, lap counted, off-path recovery, arrival). Continuous TTS is the first thing
  users disable. Provide a callouts on/off toggle. *(F17/F20 follow this.)*

**(a) Circular Tawaf — two independent errors, sonified separately** *(= F17's design):*
1. **Tangential** (which way to walk): a beacon a few metres ahead along the CCW tangent;
   walking backward swings it behind you and drops the confirmation tone → wrong-way is
   instantly audible.
2. **Radial** (keep the orbit): a **separate timbre/channel**, pitch up when too close to
   the Kaaba / down when too far out, silent inside the band. Different spatialization +
   different timbre keeps the two cues perceptually distinct.
   Lap counting = discrete speech + haptic.

**(b) Linear Sa'i — heading-hold** *(= F19's linear beacon):* single panned beacon at the
endpoint you're walking to; lateral drift = pan shift + rising pitch; at each end, speech +
haptic ("Marwah reached, turn around, trip 4 of 7"), then flip the beacon.

## B2. Haptics (Core Haptics — single Taptic Engine)

**Hard constraint: no left/right haptic.** Haptics carry **discrete state**, not continuous
direction (keep direction in audio). Two orthogonal params: **intensity** + **sharpness**;
**transient** (tap) vs **continuous** (modulate via `CHHapticParameterCurve`).

| State | Haptic |
|---|---|
| On path | Silence, or a very light tick every few seconds |
| Drifting off | Continuous low buzz rising in intensity+sharpness with drift |
| Turn now (Sa'i endpoint) | 2–3 sharp transients |
| Milestone (lap/length) | `UINotificationFeedbackGenerator.success` |
| Arrived / complete | Longer celebratory continuous pattern |
| Error / lost tracking | `.warning`/`.error` + speech |

Keep the vocabulary to ~5–6 learnable patterns. **Caution:** Core Haptics can contend with
an active record session — test haptics while mic + audio guidance are live.

## B3. Voice control + audio-session strategy

**Wake mechanism (layered):** (1) on-device **wake word** (Porcupine/keyword-spotting;
must be local) as the hands-free ideal; (2) **double-tap-anywhere / large full-screen
push-to-talk** as the reliable noisy-crowd fallback and the discoverable-without-sight
option. Avoid always-on cloud streaming. *(F20 ships the double-tap + VoiceOver magic-tap;
wake word is a future add.)*

**Intent set: tiny + fixed** (far more robust than open NLU on-device, and multilingual via
a per-language keyword grammar). *(= F20's `VoiceCommands`.)*

**Earcons:** listening-start ping, processing sound, success/confirm, distinct
not-understood error. Voice has no visual click — give it audio signifiers.

**The AVAudioSession contention problem (the real hard part).** Three consumers must
coexist: beacon playback, TTS, and the mic. The session is a **process-wide singleton**.
- Run **`.playAndRecord`** the whole time so playback never stops to open the mic; options
  **`.mixWithOthers`** (+`.duckOthers` to dip the beacon under TTS), `.defaultToSpeaker`/
  `.allowBluetooth` (blind users often use bone-conduction / one-ear Bluetooth — support it).
- Use **`.default` mode** (unprocessed input) for recognition; enable
  **`setPrefersEchoCancelledInput(true)` (iOS 18+)** so the beacon/TTS doesn't feed back
  into the recognizer. On older iOS, duck the beacon during active listening.
- **Do NOT tear down/rebuild the session per command** — configure once, keep alive; just
  start/stop the recognition request + mic tap.
- **Handle interruption notifications** (calls, Siri): pause on `.began`, re-activate on
  `.ended`.
  > **Note vs current build:** F17/F20 take the simpler, safer route for a solo demo — the
  > beacon *stops* (releases the session) while the mic listens and resumes after. The
  > `.playAndRecord` + echo-cancellation approach above is the upgrade path if we ever want
  > the beacon to keep playing *during* listening.

## B4. VoiceOver / HIG do's & don'ts

- **One primary context per ritual; mode-switch, not a navigation stack.** Deep nav is
  hostile to blind users (re-orient, hunt for focus every push). Same principle as Apple's
  **Assistive Access** (distill to 1–2 features, big controls, **no hidden gestures / timed
  interactions**). *(= why F19 is a mode, not a screen.)*
- **Whole active screen = one large gesture target** (double-tap anywhere). *(= F20.)*
- Honor **44×44 pt** minimum hit targets; here, go full-width / full-screen.
- Every control: clear **`accessibilityLabel`**, an **`accessibilityHint`** for the action,
  correct **trait**. Mark live status with **`.updatesFrequently`**.
- **State changes via `UIAccessibility.post`:** `.announcement` for transient spoken events
  (don't move focus); `.layoutChanged` when part of the screen changes; `.screenChanged`
  when switching ritual mode. Critical announcements may be dropped mid-utterance — re-post
  or use `UIAccessibilityPriority` (iOS 17+).
- **Test every flow with VoiceOver ON and the screen off** — start → guide → count → finish
  must be fully non-visual.
- Respect the user's system speech rate; make guidance verbosity independently dialable.
- Don't rely on color/contrast for anything load-bearing; **mirror critical info across
  speech + earcon + haptic**.

## B5. Sources (Part B)

Microsoft Soundscape (AFB AccessWorld, Microsoft Accessibility Blog, microsoft/soundscape
GitHub) · Sonification mapping (ACM TAP 3528171; UZH parameter-mapping; arXiv 1506.07272) ·
Blind pedestrian verbosity/egocentric framing (Cairn; AFB) · Core Haptics (Lofelt; Hacking
with Swift; arXiv 2412.19105; Medium haptics-vs-AVAudioSession) · AVAudioSession
(Picovoice iOS speech; Apple Developer docs) · Wake word / earcons (Picovoice; NN/g audio
signifiers; Fable) · VoiceOver/HIG (Apple HIG Accessibility & VoiceOver; UIAccessibility
docs; Exyte) · Assistive Access (WWDC23/25; Apple support).
