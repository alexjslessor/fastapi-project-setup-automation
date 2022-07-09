
from asgi_lifespan import LifespanManager
from starlette.status import HTTP_200_OK
from httpx import AsyncClient
import pytest_asyncio
import pytest
import asyncio
from backend.entry import create_app
# from backend.settings import _BaseSettings, get_settings

# def get_settings_override():
    # return Settings(MONGO_URI="testing_mongo_uri")

app = create_app()

@pytest_asyncio.fixture(scope="session")
def event_loop():
    loop = asyncio.get_event_loop()
    yield loop
    loop.close()

##this is for testing routes
@pytest_asyncio.fixture
async def test_client():
    
    # app.dependency_overrides[get_settings] = get_settings_override

    async with LifespanManager(app):
        async with AsyncClient(app=app, base_url="https://app.io", timeout=30) as test_client:
            yield test_client
