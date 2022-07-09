
from .conftest import *

@pytest.mark.asyncio
class Test_Routers:

    async def test_example_router(self, test_client: AsyncClient):
        resp = await test_client.get("/")
        assert resp.status_code == HTTP_200_OK
        print(resp.json())
