"""Proxy tests — run with:  uv run --with pytest --with httpx pytest -q
Covers mock mode (no key needed) so CI/local always pass offline."""
from fastapi.testclient import TestClient

from app import app

client = TestClient(app)


def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_describe_orders_safety_first():
    r = client.post("/describe", json={
        "observations": [
            {"label": "person", "direction": "left", "distance_m": 1.1},
            {"label": "pillar", "direction": "ahead", "distance_m": 3.4},
        ],
        "language": "English",
        "circuit": 4,
    })
    assert r.status_code == 200
    body = r.json()
    # closest hazard is spoken before the landmark, and circuit is reported
    assert body["text"].lower().startswith("careful")
    assert "circuit 4 of seven" in body["text"].lower()


def test_describe_clear_path_when_empty():
    r = client.post("/describe", json={"observations": [], "language": "English"})
    assert r.status_code == 200
    assert "clear" in r.json()["text"].lower()


def test_circuit_only_answer():
    r = client.post("/describe", json={
        "observations": [], "language": "English",
        "question": "how many left?", "circuit": 6,
    })
    assert "circuit 6 of seven" in r.json()["text"].lower()
