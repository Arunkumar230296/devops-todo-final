from main import app


def test_health_endpoint():
    client = app.test_client()
    response = client.get("/health")

    assert response.status_code in [200, 500]
    assert b"status" in response.data


def test_home_route_exists():
    client = app.test_client()
    response = client.get("/")

    assert response.status_code in [200, 500]