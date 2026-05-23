import os
import requests


def test_live_health_endpoint():
    app_url = os.getenv("APP_URL", "http://localhost:8080")
    response = requests.get(f"{app_url}/health", timeout=10)

    assert response.status_code == 200
    assert response.json()["status"] == "healthy"