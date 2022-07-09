
from .conftest import *

@pytest.mark.asyncio
class Test_Dependancies:

    async def test_example_dependancy(self):
        # this is for testing 
        assert len("abcd") > 1
