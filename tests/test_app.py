from fastapi.testclient import TestClient
import sys
from pathlib import Path

# Add src to path for test imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from src.main import app


client = TestClient(app)


def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"hello": "world"}
