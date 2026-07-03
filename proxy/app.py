"""AI Umrah Companion — cloud scene-description proxy.

Why this exists: the iPhone never ships an LLM API key and never streams video.
The phone runs on-device detection, then POSTs ONE still frame + the structured
observations here. This service adds the ritual-aware system prompt, calls a
multimodal LLM, and returns one short spoken-style sentence.

Providers: gemini (default) | openai | anthropic | mock (no key needed).
Select with env PROVIDER; key via <PROVIDER>_API_KEY. With no key it runs in
MOCK mode so the whole pipeline is demoable offline.

Run:  uv run uvicorn app:app --host 0.0.0.0 --port 8000 --reload
"""
from __future__ import annotations

import base64
import os

import httpx
from fastapi import FastAPI
from pydantic import BaseModel, Field

from dotenv import load_dotenv
from prompts import SYSTEM_PROMPT, mock_description

load_dotenv()  # load proxy/.env so the LLM key is picked up no matter how uvicorn is started

PROVIDER = os.getenv("PROVIDER", "").lower() or "auto"
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-2.5-flash")
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o")
ANTHROPIC_MODEL = os.getenv("ANTHROPIC_MODEL", "claude-sonnet-5")

app = FastAPI(title="AI Umrah Companion Proxy", version="0.1.0")


class Observation(BaseModel):
    label: str
    direction: str = "ahead"          # left | ahead | right
    distance_m: float | None = None


class DescribeRequest(BaseModel):
    observations: list[Observation] = Field(default_factory=list)
    language: str = "English"
    circuit: int | None = None        # current Tawaf circuit, if known
    question: str | None = None       # optional open-ended user question
    image_b64: str | None = None      # single JPEG frame, base64 (no data: prefix)


class DescribeResponse(BaseModel):
    text: str
    provider: str
    model: str | None = None


def _resolve_provider() -> str:
    """Pick a provider based on available keys unless one is forced."""
    if PROVIDER != "auto":
        return PROVIDER
    if os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY"):
        return "gemini"
    if os.getenv("OPENAI_API_KEY"):
        return "openai"
    if os.getenv("ANTHROPIC_API_KEY"):
        return "anthropic"
    return "mock"


def _user_text(req: DescribeRequest) -> str:
    obs = "; ".join(
        f"{o.label} {o.direction}"
        + (f" at {o.distance_m:.1f}m" if o.distance_m is not None else "")
        for o in req.observations
    ) or "no objects detected on device"
    lines = [f"On-device observations: {obs}.", f"Reply language: {req.language}."]
    if req.circuit is not None:
        lines.append(f"Current Tawaf circuit: {req.circuit} of 7.")
    if req.question:
        lines.append(f'Pilgrim asked: "{req.question}"')
    else:
        lines.append("Describe the scene for the pilgrim in one or two short spoken sentences.")
    return "\n".join(lines)


async def _call_gemini(req: DescribeRequest, user_text: str) -> str:
    key = os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY")
    url = (
        f"https://generativelanguage.googleapis.com/v1beta/models/"
        f"{GEMINI_MODEL}:generateContent?key={key}"
    )
    parts: list[dict] = [{"text": user_text}]
    if req.image_b64:
        parts.append({"inline_data": {"mime_type": "image/jpeg", "data": req.image_b64}})
    payload = {
        "systemInstruction": {"parts": [{"text": SYSTEM_PROMPT}]},
        "contents": [{"role": "user", "parts": parts}],
        "generationConfig": {"temperature": 0.4, "maxOutputTokens": 120},
    }
    async with httpx.AsyncClient(timeout=20) as c:
        r = await c.post(url, json=payload)
        r.raise_for_status()
        data = r.json()
    return data["candidates"][0]["content"]["parts"][0]["text"].strip()


async def _call_openai(req: DescribeRequest, user_text: str) -> str:
    key = os.getenv("OPENAI_API_KEY")
    content: list[dict] = [{"type": "text", "text": user_text}]
    if req.image_b64:
        content.append(
            {"type": "image_url",
             "image_url": {"url": f"data:image/jpeg;base64,{req.image_b64}"}}
        )
    payload = {
        "model": OPENAI_MODEL,
        "max_tokens": 120,
        "temperature": 0.4,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": content},
        ],
    }
    async with httpx.AsyncClient(timeout=20) as c:
        r = await c.post(
            "https://api.openai.com/v1/chat/completions",
            headers={"Authorization": f"Bearer {key}"},
            json=payload,
        )
        r.raise_for_status()
        data = r.json()
    return data["choices"][0]["message"]["content"].strip()


async def _call_anthropic(req: DescribeRequest, user_text: str) -> str:
    key = os.getenv("ANTHROPIC_API_KEY")
    content: list[dict] = [{"type": "text", "text": user_text}]
    if req.image_b64:
        content.insert(0, {
            "type": "image",
            "source": {"type": "base64", "media_type": "image/jpeg", "data": req.image_b64},
        })
    payload = {
        "model": ANTHROPIC_MODEL,
        "max_tokens": 120,
        "system": [{"type": "text", "text": SYSTEM_PROMPT,
                    "cache_control": {"type": "ephemeral"}}],
        "messages": [{"role": "user", "content": content}],
    }
    async with httpx.AsyncClient(timeout=20) as c:
        r = await c.post(
            "https://api.anthropic.com/v1/messages",
            headers={"x-api-key": key, "anthropic-version": "2023-06-01"},
            json=payload,
        )
        r.raise_for_status()
        data = r.json()
    return data["content"][0]["text"].strip()


@app.get("/health")
async def health() -> dict:
    return {"status": "ok", "provider": _resolve_provider()}


@app.post("/describe", response_model=DescribeResponse)
async def describe(req: DescribeRequest) -> DescribeResponse:
    provider = _resolve_provider()
    obs = [o.model_dump() for o in req.observations]
    try:
        if provider == "gemini":
            return DescribeResponse(text=await _call_gemini(req, _user_text(req)),
                                    provider=provider, model=GEMINI_MODEL)
        if provider == "openai":
            return DescribeResponse(text=await _call_openai(req, _user_text(req)),
                                    provider=provider, model=OPENAI_MODEL)
        if provider == "anthropic":
            return DescribeResponse(text=await _call_anthropic(req, _user_text(req)),
                                    provider=provider, model=ANTHROPIC_MODEL)
    except Exception as e:  # graceful degrade — never leave the pilgrim without a reply
        return DescribeResponse(
            text=mock_description(obs, req.language, req.circuit) + f" (offline fallback)",
            provider="mock", model=f"fallback-after-{provider}-error:{type(e).__name__}",
        )
    # provider == "mock"
    return DescribeResponse(
        text=mock_description(obs, req.language, req.circuit),
        provider="mock", model=None,
    )
