#!/bin/bash

# DIRECTORIES
# test folder in base dir outside of module.
base_dir_tests=tests
base_dir=backend
env_folder=.env

deps=$base_dir/deps
config=$base_dir/config
utils=$base_dir/utils
schemas=$base_dir/schemas
routers=$base_dir/routers
db=$base_dir/db

# FILES
# because our app is a python module, we need init file in every sub dir.
init=__init__.py
entry=entry.py
settings=settings.py
main=main.py
base_deps=base_deps.py
base_config=base_config.py
base_router=base_router.py
base_utils=base_utils.py
base_db=base_db.py
base_schema=base_schema.py

# NON-APPLICATION SPECIFIC FILES
# setup file for pytest.
setup_cfg=setup.cfg
# config file for pytest, in tests folder.
conftest=conftest.py
dockerfile=Dockerfile

startup=startup.sh 
gitignore=.gitignore 
dockerignore=.dockerignore
reqs=requirements.txt
# .env file local
env_file=.env.local



step_1_create_dirs() {
    # create ~/backend/ project folders
    mkdir -p $deps \
            $deps/v1 \
            $config \
            $utils \
            $schemas \
            $routers \
            $routers/v1 \
            $db
}
# ~/BACKEND FILES
step_2_create_dir_files_v1() {
    # ~/backend/...
    touch $deps/$init\
            $deps/$base_deps \
            $deps/v1/$init \
            $db/$init \
            $db/$base_db \
            $schemas/$init \
            $schemas/$base_schema \
            $config/$base_config \
            $config/$init \
            $utils/$init \
            $utils/$base_utils \
            $routers/$init \
            $routers/$base_router \
            $routers/v1/$init
}


# Dockerfile with uvicorn; this works on Digital Ocean
create_dockerfile_dgo() {
    # ~/Dockerfile at project root directory.
    touch $dockerfile
    printf \
'FROM python:3.9

WORKDIR /app

ADD requirements.txt .
RUN pip install --no-cache-dir --upgrade -r requirements.txt
# RUN pip install -vvv uvloop

ADD backend backend
ADD main.py .

# these both do the same thing
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "$PORT"]
# CMD uvicorn main:app --host 0.0.0.0 --port $PORT
' > $dockerfile
}



create_test_config() {    # ~/tests
    mkdir $base_dir_tests
    touch $base_dir_tests/$init
    # ~/tests/conftest.py
    # touch  $base_dir_tests/test_two.py
    # ~/setup.cfg
    touch $setup_cfg
    printf \
'[coverage:run]
branch = True
# define paths to omit, comma separated
omit = .venv/**,*/.virtualenvs/*,~/.virtualenvs

[coverage:report]
show_missing = True
skip_covered = True

[coverage:html]
directory = tests/coverage_html_report

[tool:pytest]
addopts = 
    ; directory to cover tests with
    --cov backend/ 
    ; coverage report type
    --cov-report html
    ; test result verbosity in the terminal
    --verbose
    ; mute sometimes useless warnings (not always a good idea)
    -p no:warnings
testpaths = 
    tests
filterwarnings = ignore::DeprecationWarning
    ' > $setup_cfg

printf \
'
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
' > $base_dir_tests/$conftest

printf \
'
from .conftest import *

@pytest.mark.asyncio
class Test_Dependancies:

    async def test_example_dependancy(self):
        # this is for testing 
        assert len("abcd") > 1
' > $base_dir_tests/test_deps.py

printf \
'
from .conftest import *

@pytest.mark.asyncio
class Test_Routers:

    async def test_example_router(self, test_client: AsyncClient):
        resp = await test_client.get("/")
        assert resp.status_code == HTTP_200_OK
        print(resp.json())
' > $base_dir_tests/test_routes.py
}

entry_gql() {
    touch $base_dir/$entry
    printf \
'from fastapi import FastAPI
from ariadne import QueryType, make_executable_schema
from ariadne.asgi import GraphQL

type_defs = """
    type Query {
        hello: String!
    }
"""

query = QueryType()

@query.field("hello")
def resolve_hello(*_):
    return "Hello world!"

schema = make_executable_schema(type_defs, query)

def create_app() -> FastAPI:
    app = FastAPI()
    app.mount("/graphql", GraphQL(schema, debug=True))

    @app.get("/")
    async def test_route():
        return {"message": "Hello World"}

    return app
' > $base_dir/$entry
}

entry_standard() {
    touch $base_dir/$entry
    printf \
'from fastapi import FastAPI, Request
from starlette.status import (HTTP_400_BAD_REQUEST)
from fastapi.responses import JSONResponse

class EnumException(Exception):
    def __init__(self, error_message: str):
        self.error_message = error_message

def create_app() -> FastAPI:
    app = FastAPI()

    @app.exception_handler(EnumException)
    async def enum_exception_handler(
        request: Request,
        exc: EnumException
        ) -> JSONResponse:
        """
        Custom http error response for enum param validation
        """
        return JSONResponse(
            status_code=HTTP_400_BAD_REQUEST,
            content={"error": f"{exc.error_message}"}
        )

    @app.get("/")
    async def test_route():
        return {"message": "Hello World"}

    return app
' > $base_dir/$entry
}


# ~/main.py
create_main_py() {
    touch $main
    printf \
"from backend.entry import create_app

app = create_app()

if __name__ == '__main__':
    app
" > $main
}


celery_create_main_py() {
    touch $main
    printf \
'from backend.entry import create_app

app = create_app()
celery = app.celery_app

def auto_reload_celery_worker():
    from watchgod import run_process
    import subprocess
    # app
    # celery
    def run_worker():
        subprocess.call(
            ["celery", "-A", "main.celery", "worker", "--loglevel=info"]
        )
    run_process("./backend", run_worker)

if __name__ == "__main__":
    auto_reload_celery_worker()

' > $main
}
# https://github.com/PacktPublishing/Building-Data-Science-Applications-with-FastAPI/blob/main/chapter8/broadcast/app.py


celery_create_compose() {
    printf \
"version: '3.7'

services:
  web:
    build:
      context: .
      dockerfile: ./Dockerfile
    volumes:
      - .:/app
    ports:
      - 5000:5000
    env_file:
      - .env/.dev.prod

   redis:
     # image: redis:6-alpine
     image: redis:latest
     container_name: redis
     ports:
       - 6379:6379

 celery_worker:
   build:
     context: .
     dockerfile: ./Dockerfile.api.docker
   image: celery_worker_1:latest
   command: celery -A main.celery worker --loglevel=info
   volumes:
     - .:/app
   env_file:
     - .env/.dev.local
   depends_on:
     - redis
     - web

 celery_beat:
   build:
     context: .
     dockerfile: ./Dockerfile.api.docker
   image: celery_beat_1:latest
   # command: rm -f './celerybeat.pid' && celery -A main.celery beat -l info
   command: celery -A main.celery beat -l info
   volumes:
     - .:/app
   env_file:
     - .env/.dev.local
   depends_on:
     - redis

 mongo_db:
   build:
     context: ./
     dockerfile: Dockerfile.mongo
   volumes:
     - $PWD/data_mongo:/data/db
     - $PWD/data_mongo:/var/www/html
   ports:
     - 27017:27017
   environment:
     MONGO_INITDB_ROOT_USERNAME: root
     MONGO_INITDB_ROOT_PASSWORD: 123
" > docker-compose.yaml
}
create_settings_py() {
    touch $base_dir/$settings
    printf \
"from functools import lru_cache
from pydantic import BaseSettings, AnyUrl, RedisDsn
from os import environ
from typing import List, Callable
import os.path

class _BaseSettings(BaseSettings):
    TITLE: str = 'Example App'
    DOCS_URL: str = '/docs'
    OPENAPI_URL: str = '/openapi'
    REDOC_URL: str = '/redoc'

    V1_PREFIX = '/'
    TAGS: List[str] = ['']
    CORS_ALLOW_CREDENTIALS: bool = True
    CORS_ALLOW_METHODS: List[str] = ['*']
    CORS_ALLOW_HEADERS: List[str] = ['*']
    CORS_ORIGINS: List[str] = ['*']

    TEST_ENDPOINT: str = f'api/v1/one'

    ENUM_ERROR = {'detail': 'Wrong Enum!'}
    FILE_TYPE_ERROR = 'Upload File Error: Incorrect File Type.'

    PORT: int = environ.get('PORT')
    MONGO_URI: str = environ.get('MONGO_URI')
    MONGO_DB_NAME: str = 'database'

    ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
    DATA_DIR = os.path.join(ROOT_DIR, 'data')

    CELERY_BROKER_URL: str = environ.get('CELERY_BROKER_URL')
    CELERY_RESULT_BACKEND: str = environ.get('CELERY_RESULT_BACKEND')
    WS_MESSAGE_QUEUE: str = environ.get('WS_MESSAGE_QUEUE')

    CELERY_BEAT_SCHEDULE: dict = {
        'task-name-one': {
            'task': 'task_name_one',
            'schedule': 5.0, # five seconds
        },
    }


class DevSettings(_BaseSettings):
    DEBUG: bool = True

class TestSettings(_BaseSettings):
    DEBUG: bool = True

class ProdSettings(_BaseSettings):
    pass


@lru_cache()
def get_settings() -> BaseSettings:
    config_dict = {
        'development': DevSettings,
        'production': ProdSettings,
        'testing': TestSettings
    }
    config_name: str = environ.get('ENV_NAME')

    assert config_name in list(config_dict.keys()), f'Invalid ENV_NAME, should be one of: {list(config_dict.keys())}'
    
    config_cls = config_dict[config_name]
    return config_cls()
" > $base_dir/$settings
}



# ~/startup.sh
create_startup_and_test_script() {
    touch $startup
    printf  \
"#!/bin/bash

base_settings() {
    # grep -v '^#' .env/.env.local
    export \$(grep -v '^#' .env/.env.local | xargs)
    env | grep ENV_NAME
}
run_tests() {
    base_settings
    export \$(grep -v '^#' .env/.env.testing | xargs)
    env | grep ENV_NAME

    py.test -s tests/test_deps.py
    py.test -s tests/test_routes.py
}
run_app_local_test() {
    docker build -t fastapi_app:latest .
    docker run --name test-container -p \$PORT:\$PORT fastapi_app:latest
}
run_mongodb_local() {
    docker run -d --name mongodb-docker -p 27017:27017 mongo:4.4
}
# Start app with env vars

base_settings
run_tests
#run_mongodb_local
uvicorn main:app --reload --port \$PORT
" > $startup

sudo chmod 755 $startup
}


create_requirements_txt() {
    printf \
"
fastapi
pydantic[email,dotenv]
uvicorn[standard]
python-multipart
httpx

# testing related
asgi-lifespan
pytest-asyncio
pytest-cov

# mongodb related
motor

# graphql
ariadne

# celery worker related
#celery
#redis
#flower
" > $reqs
}


create_other_root_files() {
    # create root files
    touch $dockerignore
}

create_gitignore() {
    printf \
"__pycache__
.env
.coverage
.pytest_cache
.vscode
" > $gitignore
}

create_env_files() {
    # create .env folder and files
    mkdir $env_folder
    local env_file_test=.env.testing
    local env_file_prod=.env.production

printf \
"SECRET=hex_hash
MONGO_URI=mongodb://localhost:27017
WHICH_LOGGER=uvicorn
ENV_NAME=development
PORT=5000
" > $env_folder/$env_file

printf \
"
MONGO_URI=mongodb://localhost:27017
ENV_NAME=testing
" > $env_folder/$env_file_test

printf \
"
SECRET=hex_hash
WHICH_LOGGER=uvicorn
MONGO_URI=atlas_uri
ENV_NAME=production
PORT=5000
" > $env_folder/$env_file_prod

}

# make_celery_app() {
# }
make_gql_app() {
    entry_gql
}
main_standard_app() {
    step_1_create_dirs
    step_2_create_dir_files_v1
    create_main_py
    entry_standard
    create_settings_py
    create_test_config
    create_startup_and_test_script
    create_dockerfile_dgo
    create_gitignore
    create_other_root_files
    create_requirements_txt
    create_env_files
}

# main_standard_app
rm -rf $base_dir $base_dir_tests $env_folder __pycache__ .coverage .pytest_cache && rm $reqs $main $startup $dockerfile $setup_cfg $gitignore $dockerignore


# print_eof() {
    # cat << EOF > ./sadasd.txt
    # rpcuser=user$(openssl rand -hex 32)
    # rpcpassword=pass$(openssl rand -hex 32)
    # rpcport=45453
    # EOF
# }


