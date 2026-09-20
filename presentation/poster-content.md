# KSCDR poster — drafted content and specs

**Event:** AI Hackathon for People with Disabilities · King Salman Center for Disability Research
· Riyadh, 11–13 October 2026 · hackathon.kscdr.org
**Deliverable:** one A0 portrait `.pptx`, `KSCDR_Hackathon_000_TeamName.pptx`, under 100 MB.
Submit to kscdr.hackathon@gmail.com. **Stated deadline 4 Sep 2026 — confirm it is still open.**

## Source files
- Guidelines: `poster-source/Poster_Guidelines.pdf` (Drive `1XTa4zzn632Syv8DxPOKsNdyEAD4tTFtR`)
- Template: `poster-source/Poster-Template.pptx` (Drive `1BX62Cc2bYxLRviV0e8qFV9jkIR7dx89Q`)
- Architecture diagram (Fig 3): https://docs.google.com/presentation/d/1LHPbC5u4W7tcsBO0nCZ6LEBPy1EHBsLvKao4TcsuEFk/edit

## Template geometry (measured from the XML, not guessed)
Slide 30275213 × 42803763 EMU = 84.1 × 118.9 cm. Background is a single 16556 × 23406 px PNG
(500 DPI) carrying the logo band and footer band — do not touch it.

| Box | x, y (cm) | w × h (cm) | Body area | Lines @24pt |
|---|---|---|---|---|
| Introduction and problem statement | 2.9, 31.7 | 38.0 × 21.8 | 34.5 × 16.2 | ~13 |
| Objectives and target users | 2.9, 55.1 | 38.0 × 21.8 | 34.5 × 16.2 | ~13 |
| Proposed solution | 2.9, 78.4 | 38.0 × 24.4 | 34.5 × 18.6 | ~15 |
| Methodology and system design | 43.2, 31.7 | 37.3 × 23.1 | 34.5 × 17.5 | ~14 |
| Results and evaluation | 43.2, 56.3 | 37.3 × 23.1 | 34.5 × 17.5 | ~14 |
| Discussion, impact and ethics | 43.2, 81.0 | 37.3 × 21.8 | 34.5 × 16.2 | ~13 |

Left and right columns are misaligned in the shipped template (left tops 31.7/55.1/78.4, right
31.7/56.3/81.0). Extend Introduction to 54.8 to match Methodology and fix the top row.

**Title box** is 27.7 cm wide with `spAutoFit`: at 112 pt Cambria Bold it holds ~13 chars/line and
two lines max before it hits the teal rule at y=23.2. Align it to the kicker above (x=23.6,
w=34.6) to gain room.

**Typography floor:** body 24 pt (never below 22), headings Cambria Bold 36 pt (do not change),
sub-labels Calibri Bold 26 pt, captions Calibri Italic 20 pt. **Any text inside a figure must be
≥20 pt** = 0.706 cm on the printed sheet.

## Brand
App icon `ios/Sources/Assets.xcassets/AppIcon.appiconset/icon_1024.png` — geometric Kaaba cube,
gold kiswa band, concentric rings reading as both Tawaf circuits and voice waves. Use this as the
logo; it is abstract, so it dodges the AI-generated-Kaaba accuracy problem entirely.
Palette from `ios/Sources/Views/`: gold `#D4AD54`, teal `#0F5452`, deep teal `#082B29`.
Template palette: `#0A3D45`, `#00A896`, `#00C7CB`, `#D7E4E3`, `#EAF5F3`.

## Title
**AI Umrah Companion** at 90 pt, one line, box widened to 34.6 cm.
Descriptor beneath at 44 pt: *Voice-guided Tawaf and Sa'i for pilgrims with visual impairment.*
Arabic name already shipped in the app (`Localization.swift:35`): **رفيق العُمرة**.
The title cannot carry the user population — "pilgrims with visual impairment" is 31 chars, two
full lines at 112 pt — hence the separate descriptor line.

---

# Box 1 — Introduction and problem statement

Stat row, Cambria Bold ~54 pt gold, labels Calibri 20 pt:

    30 million              43 million            ~90,000
    Umrah pilgrims a year   people worldwide      estimated pilgrims who
    targeted by 2030(1)     are blind(2)          are blind, each year(3)

Lead, Calibri Bold 26 pt:

    Tawaf requires seven counter-clockwise circuits of the Kaaba on foot,
    in one of the densest pedestrian crowds on earth.

Bullets, Calibri 24 pt:

    - Three demands at once — hold the circular path, count seven circuits,
      avoid collision in a moving crowd.
    - Only workaround: a sighted companion, arm in arm. Performing their own
      Tawaf. Not always available. Easily separated.(4)
    - Lose count, and fulfilment of the obligation is in doubt.
    - Existing aids do not transfer — a cane is unusable at this density,
      satellite positioning too imprecise, no app models ritual state.
    - Separated from the group, a pilgrim cannot be located and the family
      has no way to reach them.

Closing, Calibri Bold 26 pt deep teal:

    No tool today lets a pilgrim with visual impairment complete Tawaf
    independently.

**Deliberately no image here.** Introduction is not one of the three boxes where the guidelines
prefer a figure, it is one of the two smallest, and a decorative photograph of a person with a
white cane is "inspiration imagery" — the specific trope a disability research centre objects to.
Type carries the visual weight instead.

## Sources (verified 2026-09-05)
1. Vision 2030 Pilgrim Experience Program — 30 M Umrah pilgrims/yr from abroad by 2030, from a
   launch capacity of ~8 M. Actuals: 16.92 M (2024); 2025 reported as **both 18.03 M and 19.5 M**
   depending on counting method — pick one and cite it.
2. IAPB Vision Atlas: **43 M blind**, 295 M moderate-to-severe. Do **not** use WHO's 2.2 bn — that
   includes presbyopia and uncorrected refractive error, i.e. people who need reading glasses.
   Conflating the two is the classic poster error.
3. Author estimate, must be labelled: 0.5% global blindness prevalence × ~18 M Umrah pilgrims.
4. Sighted-companion practice is documented; the General Presidency for the Two Holy Mosques
   distributes canes and talking watches.

Optional Saudi figure — GASTAT *Persons with Disability Survey 2017*: 2.9% of the population have a
disability with extreme difficulty (Washington Group definitions), and among those reporting a
**single** difficulty, visual difficulty is the most common type at 46.02%. That 46% is a share of
the disabled population, **not** a population prevalence. Safe phrasing: *"Visual difficulty is the
most commonly reported single disability type in Saudi Arabia."*

---

# Box 2 — Objectives and target users

    Objectives                                        [ Calibri Bold 26 pt ]

    1. Complete Tawaf and Sa'i without a sighted guide.           [ BUILT ]
    2. Remove the counting burden — announce each circuit
       automatically.                                             [ BUILT ]
    3. Hold the circular path and warn of obstacles by audio
       alone.                                                     [ BUILT ]
    4. Re-orient a lost pilgrim by camera, using the Kaaba as a
       visual anchor, where satellite positioning fails.       [ PROPOSED ]
    5. Let the pilgrim share live status with family, raise an
       SOS, and request a trained companion — granted and
       revoked by the pilgrim.                                [ PROTOTYPE ]
    6. Run on a phone the pilgrim already owns. No new hardware.  [ BUILT ]

    Target users

    Primary — pilgrims with visual impairment, blind and low vision,
    performing Umrah or Hajj. Existing VoiceOver users. English, Arabic
    and Urdu. No literacy or braille requirement.

    Secondary — family members the pilgrim grants access to; trained
    companions and mutawifs; Haram assistance teams, on a pilgrim-
    initiated request only.

Status tags are text, never colour alone — the guidelines forbid conveying meaning by colour.
Objective 6 looks minor but is the differentiator against every smart-cane and wearable project
that will be in the same room.

---

# Box 3 — Proposed solution

    An iPhone the pilgrim already owns becomes a voice-first ritual guide.

    On the phone  [ BUILT ] — counts and announces each circuit, holds the
    circular path by spatial audio, warns of obstacles with LiDAR distance.
    One voice button.

    If lost  [ PROPOSED ] — camera-based re-orientation using the Kaaba as a
    visual anchor, plus spoken SOS.

    Family portal  [ PROTOTYPE ] — book a trained companion, and locate the
    pilgrim when they ask to be found. Granted and revoked by the pilgrim.

Figures, ~9.5 cm tall: phone mockup (6.3 cm wide) with callouts, portal map (12.7 cm, 4:3),
companion card as an inset. Captions Calibri Italic 20 pt:

    Fig 1. Interface mockup of the Tawaf guidance screen.
    Fig 2. Companion booking — prototype, simulated data.

Callouts at 20 pt with hairline leaders (the mockup carries no legible text of its own):

    Circuits counted and announced automatically — the pilgrim never holds the count
    Nearest obstacle with LiDAR distance, spoken before it appears
    Path guidance: on path / ease inward / ease outward
    One voice entry point — button, double-tap, or VoiceOver magic-tap

**Guidance vocabulary must be radial, not turn-by-turn.** The generated mockup came back with
"Turn left" and "Go straight"; the real `TawafGuide` speaks *on path / ease inward / ease outward*.
Tawaf is an orbit — street-navigation language contradicts the Methodology box.

**Figure legibility.** At 6.3 cm wide, only one element on a phone screenshot can clear 20 pt.
`DemoView.swift:167` sets the ring number at 68 pt → ~21 pt on the poster; the status banner
(`.headline`) lands at ~5 pt. Screenshots supply authenticity, poster callouts supply meaning.
Browser captures need `deviceScaleFactor: 3` to reach 3000 px for a 12.7 cm figure.

---

# Box 4 — Methodology and system design

Diagram: `presentation/` Google Slides deck (link at top). Three columns SENSE → DECIDE → SPEAK
inside an ON-DEVICE panel, with a dashed NETWORK tier beneath. The separation is the argument:
everything safety-critical is local, everything networked is optional.

    Design rule — everything safety-critical runs on the device. Every cloud
    path has an on-device fallback.

    Models — ARKit world tracking for pose; LiDAR sceneDepth at 256 × 192 for
    range; YOLOv8n (COCO, 80 classes) converted to Core ML for detection. Voice
    commands use a fixed grammar, not a language model: deterministic, offline,
    no latency.

    Privacy — video never leaves the phone. At most one still frame, and only
    when the pilgrim asks.

    Fig 3. System architecture. Safety-critical processing is on-device;
    the network tier is optional.

Two lines are load-bearing. *"Fixed grammar, not a language model"* pre-empts the obvious judge
question — a nine-word offline vocabulary beats a network round-trip while someone walks in a
crowd. *"YOLOv8n (COCO)"* is the honest answer on data: there is no custom Hajj dataset, crowd
detection rides the COCO `person` class. Stating it here makes it a clean limitation for Box 6
rather than something to get caught on.

---

# Box 5 — Results and evaluation  (FINAL — also slide 2 of the deck)

Built as **slide 2** of the architecture deck for copy-paste. Slide band is 720 × 364 pt =
aspect 1.98, matching the box content area (34.5 × 17.4 cm) — paste at 34.5 cm wide and the
height lands correctly.

    Method                                            [ Calibri Bold 26 pt ]

    The Kaaba was simulated as an ARKit world anchor placed on a physical
    object, and testers walked a 2 m proxy course indoors. Approximately 20
    trials across friends and co-workers on iPhone 16 Pro, plus 44 headless
    assertions across four ritual-logic simulations. Obstacle detection runs
    YOLOv8n (80 COCO classes) converted to Core ML, with Apple's Vision human
    detector as fallback; each detection is ranged by the LiDAR depth map.

    Verified on device                                [ Calibri Bold 26 pt ]

      Tawaf circuit counting                      ✓
      Circle guidance — drift inward / outward    ✓
      Obstacle detection + LiDAR range            ✓
      Voice command layer — EN / AR / UR          ✓
      Sa'i mode and guidance                      ✓
      Du'a with safety interrupt                  ✓

      Web portal · caregiver matching · SOS  —  pilot pending: needs a larger
      cohort and resources                        [ dashed row, grey ]

    Still to run: a pilot with pilgrims who have visual impairment.

**Decisions.** No metrics table and no accuracy percentages — n≈20 will not support a percentage
that survives scrutiny, and a feature × status matrix *is* the table the guidelines ask for, so
the checklist item is still met. "Pilot pending" rather than "not built" for the portal: it frames
the gap as the next stage of the same programme, with a legitimate reason (cohort and resources)
for a hackathon team to stop there. Sourav cut a "all testers were sighted" caveat; the closing
line still states no pilgrim with visual impairment has used it, which is the part a panel will
ask about.

**Verified numbers, re-run 2026-09-05:** 44/44 Swift assertions — TawafTracker 6, SaiTracker 8,
TawafGuide 9, VoiceCommands 21. (`STATUS.md`'s "9/9 · 21/21" only counted two of the four sims.)
Proxy: 4/4 in mock mode.

**Proxy test-isolation defect (open).** `test_app.py` claims to cover mock mode "no key needed"
but never *forces* it — it assumes no key is present. With a live `ANTHROPIC_API_KEY` in
`proxy/.env` the app calls Claude for real and 2–3 tests fail non-deterministically against fixed
mock strings. `ANTHROPIC_API_KEY= uv run --with pytest --with httpx pytest -q` → 4 passed. Needs a
fixture that pins mock mode.

---

# Box 6 — Discussion, impact and ethics  (FINAL — also slide 3 of the deck)

    ■ Limitations and tuning                          [ Calibri Bold ~25 pt ]
    •  Sunlight affects time-of-flight depth; outdoor tuning still to be done.
    •  In a dense crowd the depth field reads as continuous, not discrete;
       obstacle ranking needs tuning.
    •  ARKit anchoring is a demonstration scaffold, not the production design.
       Positioning over a 100 m+ circuit, seven times, needs further
       experimentation.

    ■ Next                                            [ gold marker ]
    •  Position from Mecca's own infrastructure rather than on-device odometry
       — Nusuk card gates, the SDAIA / stc Nusk bracelet, the Grand Mosque
       geographic-coding system.
    •  Move output to bone-conduction smart glasses: hands free, ear canal open.
    •  Large-scale trial with pilgrims who are blind, alongside the General
       Presidency's existing accessibility services.

    ■ Impact
    No new hardware. Extends to other rituals, sites and disabilities.

    ■ Ethics
    Video never leaves the phone. Sharing is off by default, pilgrim-granted and
    revocable. Safety interrupts everything. The app assists the ritual; it does
    not rule on its validity.

**SIZING — this box must grow.** Slide-3 content band is 720 × 379 pt, aspect 1.90, against the
box's 2.14. Pasted at 34.5 cm wide it is **18.2 cm tall** but the body area is only 16.1 cm.
Extend the Discussion box from h=21.8 to **h≈23.5 cm** (bottom moves 102.8 → 104.5); the footer
band starts at 106.8, so there is clearance. Resizing boxes is explicitly permitted.

**Tone.** Limitations are framed as tuning and experimentation still to do, not as failures — Sourav's call, and it reads better without losing the substance. Real bullets (`createParagraphBullets`) are used rather than typed • characters, so wrapped lines hang correctly instead of running back to the margin.

**References strip did not fit on the slide** — place it separately in the gap between the box
bottom and the footer band.

## Research behind the "Next" section (2026-09-05)

Mecca already runs a national-scale identity and positioning layer. The production design should
integrate with it, not reinvent dead-reckoning on the phone — which is the project's own
"integration, not invention" framing applied to positioning.

- **Nusuk Card** — mandatory smart ID for every registered pilgrim (Ministry of Hajj and Umrah).
  2025 added sensor gates and intelligent scanners that track movement in real time for crowd-flow
  control; the 2026 digital card works without internet.
- **Nusk smart bracelet** — launched by **SDAIA** with the Guests of God Service Program and
  **stc**. GPS + IoT, monitors pulse, blood oxygen and temperature, and automatically signals
  medical staff in a danger state. This is already an emergency-location channel — our SOS should
  ride it rather than duplicate it.
- **Grand Mosque smart navigation and geographic-coding system** — deployed for pilgrim flow.
  The **Al-Maqsad** app (Makkah Valley Company) holds Haram geographic data; interactive maps carry
  live congestion levels and surface through **Nusuk**. This is the anchor network that replaces
  ARKit odometry.
- **Existing accessibility delivery channel** — the General Presidency already distributes white
  canes, Braille and pen-reader Qur'ans, provides sign-language interpreters, dedicated routes and
  designated prayer areas. A pilot has a partner and a distribution route; this is not greenfield.
- **Wearables** — edge-AI smart glasses with bone-conduction audio now ship at ~33 g (Envision;
  Ray-Ban Meta under $300). **Bone conduction is the specific reason**, not the form factor: it
  leaves the ear canal open, and in a dense crowd ambient sound is a safety input, not noise.

Sources: Ministry of Hajj and Umrah / Nusuk; SDAIA + stc Nusk bracelet announcement; Gulf News on
the Grand Mosque smart navigation launch; Arab News and the General Presidency on services for
pilgrims with disabilities.

---

## Language rules — apply to every box
Person-first throughout: "pilgrims with visual impairment", never "the blind" or "blind pilgrims".
**Never use "track" or "monitor"** — write "locate the pilgrim when they ask to be found" or
"journey status". A dashboard described as tracking a disabled adult reads as surveillance in the
one room where that is guaranteed to be noticed. Keep the authority/emergency angle
pilgrim-initiated. Also: "LiDAR" not "Lidar", sentence case, no justified text.
