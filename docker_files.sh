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

CMD uvicorn main:app --host 0.0.0.0 --port $PORT
' > $dockerfile
}


