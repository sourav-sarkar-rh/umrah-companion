# AI Umrah Companion

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

## Stack decision (for the DEMO — see chat for rationale)
Native SwiftUI + ARKit + Vision/Core ML on iOS; thin Python FastAPI proxy for the cloud
LLM call (keeps API keys off the phone). Flutter remains the right call for the eventual
cross-platform product, but is pure overhead for a single-device demo where every hard
part is iOS-native anyway.
