# Umrah Companion — iOS demo app

Native SwiftUI + ARKit. Blind/low-vision × Tawaf slice. Everything on-device except
one optional cloud call (scene description) that goes to the `../proxy` service.

## What it does (demo flow)
1. **Mark the Kaaba** — point at your table, tap. ARKit raycasts and pins the center.
2. **Walk 7 circuits** — the app counts each counter-clockwise loop from your motion
   (`TawafTracker`), announces "circuit N of seven", and fills the on-screen ring.
3. **Live guidance** — LiDAR + Vision detect nearby people and speak a distance warning.
4. **Ask what's around me** — push-to-talk → sends one frame + observations to the
   cloud proxy → Claude describes the scene → spoken back.

## Build & run (after Xcode is installed)
```bash
brew install xcodegen
cd ios
xcodegen generate          # creates UmrahCompanion.xcodeproj from project.yml
open UmrahCompanion.xcodeproj
```
In Xcode:
1. Select the **UmrahCompanion** target ▸ **Signing & Capabilities** ▸ set **Team** to
   your personal Apple ID (free account is fine for running on your own device).
2. Plug in the iPhone (16 Pro), select it as the run destination, press ▶.
   - First run: on the phone, **Settings ▸ General ▸ VPN & Device Management** ▸ trust
     your developer certificate.
3. **Must be a real device** — ARKit/camera/LiDAR do not work in the Simulator.

## Point it at the proxy
1. Start the proxy on your Mac: `cd ../proxy && uv run uvicorn app:app --host 0.0.0.0 --port 8077`
2. Get your Mac's LAN IP: `ipconfig getifaddr en0`
3. Edit `Sources/App/UmrahCompanionApp.swift` → set `proxyURL` to `http://<that-ip>:8077`.
   (Phone and Mac must be on the same wifi. Works in mock mode with no API key;
   add an `ANTHROPIC_API_KEY` to `../proxy/.env` for live scene descriptions.)

## Demo tips
- Use a normally furnished room — ARKit needs visual texture to track. A bare room
  with a plain floor will drift and miscount.
- Walk slowly and smoothly for the first circuit so tracking locks in.
- Turn on **VoiceOver** (triple-click side button) to show the blind-user experience.

## Known first-pass TODOs (tune on device)
- Circuit geometry tuned for a table-sized radius; verify the 2π sweep threshold live.
- Person detection uses Vision's human detector; drop in a YOLO Core ML model later
  for richer labels (see `SceneVision.observations`).
- Center-mark raycast falls back to `.estimatedPlane`; if the table isn't detected,
  aim at the floor beside it.
