# KSCDR Final Submission deck — slide-by-slide content

**Template:** `KSCDR-Hackathon-Final-Submission18_9.pdf` (14 slides, 16:9, 960 × 540 pt),
issued 18 Sep 2026. Event: AI Hackathon for People with Disabilities · King Salman Center for
Disability Research (KSCDR) · Riyadh, 11–13 October 2026 · hackathon.kscdr.org.

**This supersedes nothing** — `poster-content.md` is still the A0 poster. This deck is a
separate deliverable with a different shape: the poster is six boxes of ~150 words, this is
11 sections and it pushes hard on feasibility, sustainability and safety, which the poster
never asked for.

**The 4 September deadline question is moot** — this template was issued 18 September, so
submissions are open.

Anything in `[[ double brackets ]]` is yours to fill; I have not invented it.

---

## Slide 2 — Submission details

Taken from the submitted poster `KSCDR_Hackathon_134_SSA.pdf` — keep the deck identical to it.

    PROJECT NUMBER   KSCDR_Hackathon_134
    PROJECT NAME     Rafiq al-Umrah  ·  رفيق العُمرة
    TEAM NAME        SSA
    TRACK            Hajj & Umrah Services (Comprehensive Experience)
    CATEGORY         Individuals

⚠️ **The project name changed.** The poster went out as **Rafiq al-Umrah**, not "AI Umrah
Companion". The deck must match the poster — judges hold both. I have used Rafiq al-Umrah
throughout. If you want the English descriptor visible, put it under the name as a subtitle:
*Voice-guided Tawaf and Sa'i for pilgrims with visual impairment.*

⚠️ **Affiliation was left blank on the poster.** This template does not ask for it on slide 2,
but slide 3 asks for each member's affiliation. Decide now whether you are entering as
Redesign Health or as a private individual — the category says Individuals, so a personal
entry with affiliations listed as background is the consistent reading. Worth making sure
Abdullah is comfortable with however you state his.

---

## Slide 3 — Section 1 · Team and project snapshot

**One-line pitch** (20 words exactly)

    We help pilgrims with visual impairment complete Tawaf and Sa'i independently, by turning
    their own iPhone into a voice guide.

**Track**

    Hajj & Umrah Services (Comprehensive Experience). The product does one thing: it guides a
    pilgrim through the physical performance of Tawaf and Sa'i inside the Grand Mosque. It is
    not a general navigation app pointed at Makkah — the ritual logic (seven counter-clockwise
    circuits, the Black Stone start line, the Safa–Marwah course) is the software.

**Category**

    Individuals

**Current stage**

    Working prototype. Device-verified on iPhone 16 Pro across approximately 20 trials.
    Not yet piloted with pilgrims who have visual impairment.

**Team — 2 to 5 members**

    1  Sourav Sarkar — Technical lead · software and machine learning · [[ confirm how you
       want this stated: AI Venture Builder, Redesign Health (Riyadh); previously CTO of a
       dental-AI company; MS machine learning, Columbia; BTech computer science, IIT
       Kharagpur. Trim to one line — the template gives you one. ]]

    2  Abdullah Alhaidar — [[ role on the team · discipline · relevant experience or
       affiliation — I don't have this, you fill it ]]

Two members clears the 2-to-5 requirement. Give Abdullah a substantive role line, not a
filler one: a two-person team where only one member has a described contribution reads worse
than a solo entry.

---

## Slide 4 — Section 2 · Impact · The problem

**Problem statement** (one paragraph)

    Saudi Arabia expects to host 30 million Umrah pilgrims a year by 2030.¹ Roughly 43 million
    people worldwide are blind,² and visual difficulty is the most commonly reported single
    disability type in Saudi Arabia itself.³ For a pilgrim who is blind, Tawaf — seven
    counter-clockwise circuits of the Kaaba on foot — asks for three things at once in one of
    the densest pedestrian crowds on earth: hold a circular path, keep an accurate count, and
    avoid collision. The only workaround available today is a sighted companion, arm in arm,
    who is performing their own Tawaf, is not always available, and is easily separated in the
    crowd. Nothing else transfers: a white cane is unusable at that density, satellite
    positioning is too imprecise under the Mataf canopy and among moving bodies, and no
    existing app models ritual state at all. The cost is not convenience. Lose count and
    fulfilment of the obligation is in doubt; get separated and the pilgrim cannot be located
    and the family has no way to reach them. A once-in-a-lifetime act of worship becomes
    something a person has to be led through rather than perform.

**Citations strip** (the template asks for one)

    1. Pilgrim Experience Program, Saudi Vision 2030 — target of 30 million Umrah pilgrims
       annually by 2030.
    2. IAPB Vision Atlas, 2024 — 43 million people blind worldwide.
    3. GASTAT, Persons with Disability Survey, 2017 — among people reporting a single
       difficulty, visual difficulty is the most common type.

⚠️ **Do not swap in WHO's "2.2 billion with vision impairment."** That figure includes
presbyopia and uncorrected refractive error — people who need reading glasses. Using it in
front of a disability research centre is the classic own-goal. Equally, the GASTAT 46.02%
figure is a share of people reporting a *single* difficulty, not a population prevalence —
the phrasing above is the safe form of it.

---

## Slide 5 — Section 3 · Impact · Who we serve

**Primary user**

    Disability & context
    An adult who is blind or has low vision, an existing VoiceOver user, performing Umrah —
    often once in a lifetime, often travelling in a group, frequently not an Arabic speaker.
    No literacy or braille requirement is assumed.

    A day today
    They reach the Mataf holding a companion's arm. The companion counts the circuits aloud
    while performing their own Tawaf. In the crush the two are pushed apart; the pilgrim
    stops, cannot re-orient, and waits to be found. If the count was interrupted, they either
    repeat circuits or carry doubt about whether the obligation was fulfilled.

    What success feels like
    [[ One sentence in a real user's own words. Do not write this from imagination —
    a fabricated quote is the one thing a disability research centre will catch. Options:
    (a) quote a real conversation if you have had one, attributed by role not name;
    (b) replace the heading with "What success looks like" and write it in our voice:
    "Completing all seven circuits, in the count, without holding anyone's arm." ]]

**Needs** (ranked)

    1. Know which circuit I am on, without holding the count myself.
    2. Stay on the circular path when I cannot see the Kaaba.
    3. Know what is in front of me, early enough to avoid it.
    4. Be understood in my own language, hands free, without a screen.
    5. Be findable by my family if I am separated — on my terms.

**Barriers**

    Sensory — no visual reference for orientation; ambient noise near the Mataf is extreme.
    Physical — crowd density makes a white cane unusable and blocks any wide gesture.
    Environmental — satellite positioning is unreliable under the canopy; the visible scene is
    moving people, not fixed landmarks.
    Linguistic — signage and staff instruction are Arabic-first; most pilgrims are not.
    Financial — assistive hardware is expensive and not owned before the trip.

**Alternatives**

    A sighted companion — the default. Performing their own ritual, easily separated, not
    always available, and it makes the act dependent on another person.
    White cane — distributed at the Haram, but unusable at Mataf density.
    Mainstream blind-navigation apps — built for streets and fixed landmarks. They model
    routes, not rituals: none counts a circuit or knows what Tawaf is.
    Assistance wheelchairs and porter services — solve mobility, not orientation or counting,
    and remove independence entirely.

---

## Slide 6 — Section 4 · Innovation · Our solution

**What it is and what it does**

    An iPhone the pilgrim already owns becomes a voice-first ritual guide. The pilgrim presses
    one button — or double-taps anywhere, or uses the VoiceOver magic tap — and walks. The
    phone counts each circuit and announces it, keeps them on the circular path with spatial
    audio, and speaks a warning when something is in the way. They complete Tawaf in their own
    count, in their own language, without holding anyone's arm.

**Core capabilities**

    1  Ritual counting and announcement                        [ BUILT · device-verified ]
       Counts each of the seven Tawaf circuits from the phone's own motion and announces it
       aloud. Sa'i runs as a second mode on the same engine.
       → Answers need 1: the pilgrim never holds the count.

    2  Path guidance and obstacle warning by audio alone        [ BUILT · device-verified ]
       Learns the orbit radius and speaks corrections — on path / ease inward / ease outward
       — over a panned audio beacon. LiDAR ranges the nearest obstacle and it is spoken
       before it is reached.
       → Answers needs 2 and 3.

    3  Hands-free voice control in English, Arabic and Urdu     [ BUILT · device-verified ]
       A fixed command grammar running entirely on the device. Anything that is not a command
       falls through to a scene question. No screen use at any point.
       → Answers need 4.

    +  Family link — journey status, pilgrim-raised SOS, and booking a trained companion.
       Granted and revoked by the pilgrim.                      [[ PROPOSED — see note ]]

⚠️ **Status of the family portal.** As of the 5 Sep session the Lovable portal was not built.
Label it `[ PROPOSED ]` unless it now exists, in which case `[ PROTOTYPE ]`. Tag every claim
on every slide `[ BUILT ] / [ PROTOTYPE ] / [ PROPOSED ]` — tags as text, never colour alone.

**Product image** — the Tawaf guidance screen with callouts. Callout text ≥ 20 pt, and add
alt text to the image (the deck itself gets read for accessibility at this event).

    Circuits counted and announced automatically — the pilgrim never holds the count
    Nearest obstacle with LiDAR distance, spoken before it is reached
    Path guidance: on path / ease inward / ease outward
    One voice entry point — button, double-tap, or VoiceOver magic tap

⚠️ Never label a callout "turn left" or "go straight." Tawaf is an orbit; the real engine
speaks radially. Street-navigation vocabulary contradicts the next slide.

---

## Slide 7 — Section 5 · Innovation · How it works

Replace the generic five-box flow. The argument is the **on-device / network split** — put a
box or panel around steps 1–4 labelled ON DEVICE, and the optional tier below it.

    STEP 1 · INPUT
    ARKit world tracking for position and heading · LiDAR sceneDepth at 256 × 192 for range ·
    microphone for commands. No external hardware.

    STEP 2 · AI CORE
    Ritual state machine — idle → marking → Tawaf | Sa'i → complete — derives circuit count
    from the pose track. YOLOv8n (80 COCO classes) converted to Core ML detects obstacles,
    with Apple's Vision human detector as fallback. Voice uses a fixed command grammar, not a
    language model: deterministic, offline, no round-trip latency.

    STEP 3 · PROCESSING
    100% on device. English, Arabic and Urdu commands, Arabic UI right-to-left. One optional
    cloud call for scene description, and only when the pilgrim asks — at most a single still
    frame, never video. Every cloud path has an on-device fallback.

    STEP 4 · OUTPUT
    Speech and a panned spatial-audio beacon. Circuit announcements, path corrections,
    ranged obstacle warnings. Safety warnings interrupt everything, including du'a recitation.

    STEP 5 · USER
    One entry point — button, double-tap anywhere, or VoiceOver magic tap. The pilgrim can
    stop, reset mid-ritual, or switch modes by voice. Guidance is advisory: it never overrides
    on-site marshals and it does not rule on the validity of the rite.

    Design rule — everything safety-critical runs on the device. The network is optional.

Two lines here are load-bearing. *"Fixed grammar, not a language model"* pre-empts the obvious
judge question: a nine-word offline vocabulary beats a network round-trip while someone is
walking in a crowd. *"YOLOv8n (COCO)"* is the honest answer on data — there is no custom Hajj
dataset, crowd detection rides the COCO `person` class. Say it here and it is a clean
limitation on slide 13 instead of something you get caught on.

Use the existing architecture diagram if it fits the 16:9 frame:
https://docs.google.com/presentation/d/1LHPbC5u4W7tcsBO0nCZ6LEBPy1EHBsLvKao4TcsuEFk/edit

---

## Slide 8 — Section 6 · Innovation · What makes it different

Alternative A = **a sighted companion** (the actual status quo). Alternative B = **mainstream
blind-navigation apps and smart canes**. Don't name specific competitor products — the
category is the honest comparison and naming invites a correction you don't need.

    Comparison point         | Our solution                  | A · Sighted companion        | B · Blind-navigation apps & smart canes
    -------------------------|-------------------------------|------------------------------|----------------------------------------
    Approach                 | Models the ritual itself —    | Another person counts,        | Models streets and fixed landmarks.
                             | counts circuits, holds the    | steers and describes, while   | No concept of a circuit, a ritual
                             | orbit, ranges obstacles.      | performing their own Tawaf.   | state or the Mataf.
    Accessibility for        | Voice-only, no screen, no     | Total dependence on one       | Screen- or cane-led; cane unusable
    the user                 | literacy or braille needed,   | person; independence is the   | at Mataf density; most are
                             | VoiceOver-native.             | thing given up.               | English-first.
    Arabic & local context   | Commands and speech in        | Depends entirely on who the   | Built for Western cities; no Haram
                             | Arabic, English and Urdu;     | companion is.                 | data, no Arabic ritual vocabulary.
                             | Arabic UI right-to-left;      |                              |
                             | ritual logic is the product.  |                              |
    Cost to the user         | Zero. Runs on the phone they  | The companion's own ritual    | Dedicated hardware costs hundreds
                             | already own. No hardware.     | time, or a paid escort.       | to thousands of riyals, bought
                             |                               |                              | before travelling.
    Availability in KSA      | App Store distribution;       | Available only if someone     | Not localised, not present in the
                             | works offline inside the      | comes with you.               | Haram, no institutional route.
                             | Haram.                        |                              |

**Our three claims**

    1  No tool today lets a pilgrim with visual impairment complete Tawaf independently.
       This one counts the circuits, holds the circular path and warns of obstacles by audio
       alone — so the ritual is performed, not chaperoned.

    2  The technical choice that makes it possible is refusing the cloud. Pose, depth,
       detection and command recognition all run on the device, so guidance survives the
       congested network and the heat throttling that make a cloud-dependent design fail
       in exactly the place it is needed.

    3  The evidence: six capabilities verified on a physical device across approximately
       20 trials, backed by 44 automated assertions across four ritual-logic simulations.
       Working software on a phone anyone already owns — not a concept.

---

## Slide 9 — Section 7 · Prototype · Prototype and demo

    DEMO VIDEO       [[ URL ]]
    CODE REPOSITORY  [[ URL ]]
    LIVE BUILD / APK [[ URL — note: this is an iOS app, so TestFlight, not an APK.
                        Write "TestFlight — iOS (no Android build)" rather than leaving
                        it blank; a blank field reads as a missing deliverable. ]]
    MATURITY         TRL 4  [[ your call — reasoning below ]]

**On the TRL number.** TRL 4 is component/system validation in a laboratory environment; TRL 5
is validation in a *relevant* environment; TRL 6 is a system demonstration in one. The build
is a fully integrated system, which argues upward, but it has been validated on an indoor
proxy course, not in the Mataf, and not with a single pilgrim who has visual impairment, which
argues down hard. **TRL 4 is the defensible claim and TRL 5 is the ceiling.** Claiming 6 in a
room that will ask "who tested it?" costs more than the extra number is worth.

**On the video.** The template asks for captions and Arabic subtitles and *a real user
operating it, not a mock-up*. You have neither a pilot nor an Arabic subtitle track yet —
both are cheap to fix and both are explicitly scored. If no pilgrim with visual impairment
films it, say so on screen in one line rather than letting the judges notice.

Check every link from an incognito window before submitting.

---

## Slide 10 — Section 8 · Feasibility · RESULTS

The template leaves this slide as one empty box. Fill it as a method note plus a status matrix
— the matrix *is* the table they are looking for.

**Method**

    The Kaaba was simulated as an ARKit world anchor placed on a physical object, and testers
    walked a 2 m proxy course indoors. Approximately 20 trials across friends and co-workers
    on iPhone 16 Pro, plus 44 automated assertions across four ritual-logic simulations.
    Obstacle detection runs YOLOv8n (80 COCO classes) converted to Core ML with Apple's Vision
    human detector as fallback; each detection is ranged by the LiDAR depth map.

**Verified on device**

    Tawaf circuit counting                              ✓  verified
    Circle guidance — drift inward / outward            ✓  verified
    Obstacle detection + LiDAR range                    ✓  verified
    Voice command layer — English / Arabic / Urdu       ✓  verified
    Sa'i mode and guidance                              ✓  verified
    Du'a with safety interrupt                          ✓  verified
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Family link · companion booking · SOS               pilot pending — needs a larger
                                                        cohort and resources

**Automated test coverage**

    44 / 44 assertions across four ritual-logic simulations
    (Tawaf tracker 6 · Sa'i tracker 8 · path guidance 9 · voice commands 21)

**Still to run**

    A pilot with pilgrims who have visual impairment. No pilgrim with visual impairment
    has yet used the app.

⚠️ **No accuracy percentages.** n ≈ 20 will not support a percentage that survives a judge
asking how it was measured. A feature × status matrix says more and cannot be attacked.
Equally, do not present a spec-derived figure as a measurement — if you want LiDAR range or
latency numbers on the slide, they go in a separate column labelled *expected from
specification*, never merged with the verified column.

---

## Slide 11 — Section 9 · Impact · Expected impact

Everything here is forward-looking. Label the row "Year 1 targets" so nothing reads as a
result. Numbers below are proposals sized to a first pilot — adjust, but keep them small
enough to be believable.

    OUTPUT · what we deliver
    A free iOS app in Arabic, English and Urdu, distributed through the General Presidency's
    existing accessibility desk at the Grand Mosque. Year-1 target: [[ 300 ]] pilgrims
    onboarded, [[ 1,000 ]] guided rituals completed.

    OUTCOME · what changes for the user
    A pilgrim who is blind performs Tawaf in their own count, without holding a companion's
    arm. Target: [[ 70% ]] of pilot participants complete all seven circuits with the app
    alone, against a baseline of zero — there is no tool today that makes it possible.

    IMPACT · what changes at scale
    Independent worship becomes the default rather than the exception for pilgrims with
    visual impairment, and the family is relieved of escort duty. The same ritual engine
    extends to other rites, other sites and other disabilities. Directly serves the Vision
    2030 commitment to an accessible Pilgrim Experience and to inclusion of people with
    disabilities.

    HOW WE WILL MEASURE IT
    Indicator        Share of participants completing all seven Tawaf circuits without
                     sighted assistance.
    Baseline → target  0% → [[ 70% ]] within 12 months.
    Method           Observed completion logged in-app, paired with a short post-ritual
                     interview conducted by the accessibility desk. Every pilot session,
                     reported quarterly.

A second indicator worth carrying if there is room: **count accuracy** — circuits announced by
the app against circuits observed by a human witness, per session. It is the claim the whole
product rests on and it is trivially measurable in a pilot.

---

## Slide 12 — Section 10 · Sustainability and scalability

**How it sustains itself**

    Who pays
    Not the pilgrim. The app is free and always will be — charging a person who is blind for
    access to a religious obligation is not a viable position in this room. Funding comes from
    the institutions whose mandate this already is: the General Presidency for the Affairs of
    the Grand Mosque and the Prophet's Mosque (which already distributes white canes and
    Braille Qur'ans), the Ministry of Hajj and Umrah through the Nusuk platform, KSCDR
    research grants, and Umrah operators who sell accessible packages.

    Revenue or funding model
    Hybrid. A grant funds the pilot and the ritual-accuracy validation; an institutional
    service contract funds operation and support thereafter. Licensing the ritual-guidance
    engine to Umrah operators as an accessible-package feature is the optional commercial
    layer. [[ Confirm which of these you actually want to pursue — pick one as primary. ]]

    Cost per unit / per user
    Marginal cost is near zero by construction: all inference runs on the pilgrim's own phone,
    so there is no per-user compute bill and no hardware to buy, ship or maintain. The only
    variable cost is the optional scene-description call, which only fires when the pilgrim
    asks. Cost is therefore fixed engineering and support, not cost per pilgrim.
    [[ SAR figures: derive fixed annual cost from one engineer + support, and state it as an
    annual programme cost rather than a per-user number. Do not invent a per-user SAR
    figure — the honest answer is "it does not scale with users," and that is the stronger
    answer anyway. ]]

    Path to break-even
    Not a break-even business in phase 1. One institutional contract covering the annual
    programme cost sustains it indefinitely, because delivery cost does not rise with the
    number of pilgrims.

**Path to scale**

    PHASE 1 · Pilot
    30–50 pilgrims with visual impairment performing Umrah in a low-season month, run with the
    General Presidency's accessibility desk at the Grand Mosque. Deliverables: measured count
    accuracy, an independence rate, and ritual logic signed off by a qualified scholar.

    PHASE 2 · Both Holy Mosques, kingdom-wide
    The constraint to solve first is positioning. ARKit odometry is a demonstration scaffold,
    not the production design — holding position over a 100 m+ circuit, seven times, needs to
    come from Makkah's own infrastructure rather than the phone's dead reckoning: Nusuk card
    gates and sensor scanners, the Grand Mosque geographic-coding system and Al-Maqsad's Haram
    map data, and the SDAIA / stc Nusk bracelet as the emergency-location channel. Integration,
    not reinvention.

    PHASE 3 · GCC and global
    Replication is cheap because there is no hardware, distribution is the App Store, and the
    ritual is identical everywhere. The same engine extends to other rituals and other
    disability groups — a haptic-only guidance track for deafblind pilgrims, a simplified
    one-instruction mode for cognitive disability, crowd-density and heat warnings that serve
    every pilgrim.

Acronyms, in case they come up: **SDAIA** is the Saudi Data and Artificial Intelligence
Authority; **stc** is Saudi Telecom Company; **Nusuk** is the Ministry of Hajj and Umrah's
official pilgrim platform and smart ID card; **Al-Maqsad** is the Makkah Valley Company app
holding Grand Mosque geographic data.

---

## Slide 13 — Section 11 · Safety, reliability and accessibility

**Safety**

    Guidance is advisory, never authoritative. It does not override on-site marshals and it
    does not rule on the validity of the rite — it assists the ritual, it does not judge it.
    Safety warnings interrupt everything, including du'a recitation.
    Obstacle warnings are ranged by LiDAR and spoken before the obstacle is reached.
    Audio is designed to leave ambient sound audible: in a dense crowd, hearing the crowd is
    a safety input, not noise. This is also why the hardware roadmap is bone-conduction
    glasses rather than earbuds.
    Emergency signalling is pilgrim-initiated only. Note that satellite SOS does not operate
    in Saudi Arabia, so any emergency path must use cellular, Wi-Fi and local Saudi channels —
    in production, the existing Nusk bracelet channel rather than a parallel one.

**Reliability**

    Everything safety-critical runs on the device and works with no network. Every cloud path
    has an on-device fallback. Voice uses a fixed grammar rather than a language model, so
    command recognition is deterministic and adds no latency.
    44 of 44 automated assertions pass across four ritual-logic simulations; six capabilities
    are verified on a physical device across approximately 20 trials.
    Known limits, stated plainly: sunlight degrades time-of-flight depth and outdoor tuning is
    still to be done; in a dense crowd the depth field reads as continuous rather than
    discrete, so obstacle ranking needs tuning; obstacle detection uses a general-purpose model
    (COCO), not a Hajj-specific dataset; and ARKit anchoring is a demonstration scaffold, not
    the production positioning design.

**Accessibility & ethics**

    Designed voice-first for the primary user, not retrofitted: VoiceOver-native, magic-tap
    entry, no screen use required, no literacy or braille requirement. English, Arabic and
    Urdu, with right-to-left Arabic throughout.
    Video never leaves the phone. At most one still frame is sent, and only when the pilgrim
    asks for it. This is a design commitment, not a setting.
    Family sharing is off by default, granted by the pilgrim and revocable by the pilgrim. The
    pilgrim is located when they ask to be found — the product does not track a disabled adult
    for anyone else's convenience.
    Handling of personal data follows the Personal Data Protection Law (PDPL); the on-device
    design means there is very little personal data to handle in the first place.
    Ritual accuracy is treated as non-negotiable and is validated by a qualified scholar, not
    generated by a model. [[ Say "to be validated in phase 1" unless this has actually been
    done — an unverified claim here is worse than an open commitment. ]]
    Language throughout the product and this deck is person-first: pilgrims with visual
    impairment, never "the blind."

---

## Slide 14 — What we need next · Thank you

There is a hidden "What we need next · 1 2 3" block on this slide in the template; if it
doesn't render in PowerPoint, add three numbered asks above the Thank you.

    1  Access to a pilot cohort and to the Mataf — 30–50 pilgrims with visual impairment,
       run through the General Presidency's existing accessibility desk. This is the single
       thing standing between a working prototype and evidence.

    2  Technical introduction to the Makkah positioning stack — Nusuk, the Grand Mosque
       geographic-coding system and Al-Maqsad, and the SDAIA / stc Nusk bracelet. Production
       positioning should ride this infrastructure, not the phone's own odometry.

    3  Scholarly validation of the ritual logic, and funding for the field trial —
       one engineer and one Arabic-language accessibility researcher for six months.

    Closing line
    Seven circuits, counted by the phone — so the pilgrim can keep their mind on the prayer.

    CONTACT
    Team lead  Sourav Sarkar
    Email      souravsarkar1729@gmail.com
    Phone      +966 56 524 4326

⚠️ **The email on the submitted poster is misspelled — it reads `souravsarkar1729@gmai.com`,
missing the "l" in gmail.** If that poster has gone to print, mail the organisers the
correction now; it is the address they would use to reach you.

---

## Keeping the deck consistent with the submitted poster

The judges will hold `KSCDR_Hackathon_134_SSA.pdf` and this deck at the same time. Facts must
match. Four places where the printed poster and the copy above diverge — decide each one:

1. **Name.** Poster says *Rafiq al-Umrah*. The deck now says the same. Don't reintroduce
   "AI Umrah Companion" anywhere.
2. **"Track and monitor."** The poster problem bullet reads *"family/authority unable to track
   and monitor."* I have deliberately not carried that into the deck. Same feature, different
   verb: "cannot be located, and the family has no way to reach them." A disability research
   centre reads *track and monitor a disabled adult* as surveillance — it is the one room
   where that lands badly. The deck's phrasing is not a contradiction of the poster, it is the
   same fact stated safely, and if a judge raises it you have the better answer ready.
3. **"Image-based navigation."** The poster uses it; the deck says *re-orientation using the
   Kaaba as a visual anchor*. The second is defensible under questioning, the first invites
   "so it's Google Street View?" — which has no Mataf coverage and would be a bad exchange.
4. **Statistics.** The poster carries two numbers (30 million pilgrims, 90,000 blind pilgrims)
   and drops the 43 million global blindness figure. The deck's problem paragraph uses all
   three and cites each. That is additive, not contradictory. Note the poster prints "90000" —
   if it can still be edited, make it "~90,000" and label it as an estimate, because it *is*
   an estimate (0.5% blindness prevalence × ~18 million pilgrims), not a published figure.

One substantive thing the poster states more bluntly than the deck: *"ARKit anchoring won't
hold across seven 100 m+ circuits."* That is an honest and strong admission and you should
keep it — but it means slide 7 must not read as though ARKit is the production design. The
copy above handles it by calling it a demonstration scaffold on slides 12 and 13. Be ready for
the obvious follow-up: *"so does your core mechanism actually work in the Mataf?"* The answer
is the phase-2 positioning plan — Nusuk gates, the Grand Mosque geographic-coding system, the
Nusk bracelet — and you should be able to give it in two sentences without notes.

## Before you submit — checklist

- **Fix the email typo** on the poster contact block (`gmai.com` → `gmail.com`) and, if the
  poster is already submitted, mail the organisers the correction.
- **Give Abdullah a real role line** on slide 3.
- **Confirm the family portal's real status** before labelling it PROTOTYPE anywhere.
- **The deck's own accessibility will be judged.** Alt text on every image, body text no
  smaller than 18–20 pt, never colour alone to carry meaning (status tags stay as words),
  and check contrast on the teal-on-white template text.
- **File name** should follow the organisers' convention, as the poster did:
  `KSCDR_Hackathon_###_TeamName`.
- **Every link checked from an incognito window**, including the TestFlight build.
- Numbers in double brackets on slides 11 and 12 are proposals, not facts. Set them
  deliberately; they are the ones a judge will probe.

## Language rules — apply to every slide

Person-first throughout: "pilgrims with visual impairment", never "the blind" or "blind
pilgrims". **Never write "track" or "monitor"** — write "locate the pilgrim when they ask to
be found" or "journey status". A dashboard described as tracking a disabled adult reads as
surveillance in the one room where that is guaranteed to be noticed. "LiDAR", not "Lidar".
Sentence case. No justified text.
