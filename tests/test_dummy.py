from services.api.main import app
from fastapi.testclient import TestClient

client = TestClient(app)


def test_root() -> None:
    r = client.get("/")
    assert r.status_code == 200
    assert r.json() == {"service": "MailAliasPlatform", "status": "ok"}
