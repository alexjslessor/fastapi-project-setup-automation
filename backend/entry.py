from fastapi import FastAPI

def create_app() -> FastAPI:
    app = FastAPI()

    @app.get('/')
    async def test_route():
        return {'message': 'Hello World'}

    return app
