# Rafiq al-Umrah · رفيق العُمرة

**KSCDR AI Hackathon for People with Disabilities 2026 — submission `KSCDR_Hackathon_134`**
Track: Hajj & Umrah Services (Comprehensive Experience) · Category: Individuals
Team SSA — Sourav Sarkar, Abdullah Alhaidar

Voice-guided Tawaf and Sa'i for pilgrims with visual impairment. Runs on a phone the pilgrim
already owns; everything safety-critical runs on the device.

**Verified on device** (iPhone 16 Pro, ~20 trials): Tawaf circuit counting · circle guidance
(drift inward/outward) · obstacle detection with LiDAR range · voice commands in English,
Arabic and Urdu · Sa'i mode · du'a with safety interrupt.
44/44 automated assertions across four ritual-logic simulations — run them with no Xcode:

    cd ios && swiftc Sources/AR/TawafTracker.swift Tests/main.swift -o /tmp/tawafsim && /tmp/tawafsim

**Not built:** the family portal (companion booking, locate-on-request, SOS) and camera
relocalisation. No pilot with pilgrims who have visual impairment has been run yet.
See `PRODUCT.md` for per-feature status and `FUTURE.md` for the roadmap.

_The repository and app bundle still use the earlier working name "AI Umrah Companion"._

---

Voice-first mobile assistant that guides pilgrims **with disabilities** through Umrah/Hajj
rituals. On-device computer vision + AR spatial tracking (Tawaf lap counting) + cloud
multimodal LLM for scene reasoning. Originated as a disability-focused hackathon concept.

## Source docs
- `docs/AI Umrah Companion — Technical Architecture & Build Plan.pdf` — full architecture (15 sections, 4-phase build)
- Drive: "AI Umrah Companion — Hackathon Submission" — problem/solution/scope pitch

## Full vision vs. what we're building now
The architecture doc describes a multi-month, multi-person product with hard external
dependencies (custom Hajj CV dataset captured on-site, Nusuk/Tawakkalna/Nafath
integrations, in-Kingdom PDPL hosting, companion matching, emergency-signal
agreements with KSA authorities). **None of that is demoable solo from home.**

## Demo scope (the vertical slice we CAN build + test from home)
Target device: iPhone (Pro-class for LiDAR). Modality: **blind / low-vision**. Ritual: **Tawaf**.
Three capabilities, all testable in a living room:
1. **Voice loop** — speak → STT → LLM (ritual-aware system prompt) → spoken answer.
2. **Live scene description** — point camera → on-device object detection + depth →
   "chair ~2m ahead, person moving left-to-right" → spoken in the user's language.
3. **Tawaf lap counting** — ARKit visual-inertial tracking counts 7 circuits by walking
   loops around a table (the tracker doesn't need the real Kaaba to work).

## Explicitly deferred (not in the demo)
Custom Hajj object model, Android port, companion matching, KSA infra integrations,
emergency signal, in-Kingdom hosting, multi-language sign-language video, crowd feeds.

## Stack decision (for the demo)
Native SwiftUI + ARKit + Vision/Core ML on iOS; thin Python FastAPI proxy for the cloud
LLM call (keeps API keys off the phone). Flutter remains the right call for the eventual
cross-platform product, but is pure overhead for a single-device demo where every hard
part is iOS-native anyway.
