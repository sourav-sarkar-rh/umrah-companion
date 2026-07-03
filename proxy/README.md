# Umrah Companion — Scene-Description Proxy

Thin cloud service the phone calls for open-ended scene reasoning. Keeps the LLM key
off the device; the phone sends structured on-device observations (+ optionally one JPEG
frame) and gets back one short spoken sentence.

## Run
```bash
cd proxy
uv sync
uv run uvicorn app:app --host 0.0.0.0 --port 8077   # 0.0.0.0 so the iPhone can reach it on your wifi
```
Health: `curl http://127.0.0.1:8077/health`

## Modes
- **mock** (default, no key): realistic canned guidance — the whole pipeline is demoable offline.
- **live**: copy `.env.example` → `.env`, add ONE key (Gemini recommended). Auto-detected.

## Example
```bash
curl -X POST http://127.0.0.1:8077/describe -H 'Content-Type: application/json' -d '{
  "observations":[{"label":"person","direction":"left","distance_m":1.1},
                  {"label":"pillar","direction":"ahead","distance_m":3.4}],
  "language":"English","circuit":4}'
# -> "Careful, person is close on your left. There is a pillar about 3.4 meters ahead.
#     You are on circuit 4 of seven."
```

When the iOS app runs on your phone, point it at `http://<your-mac-LAN-IP>:8077`.
