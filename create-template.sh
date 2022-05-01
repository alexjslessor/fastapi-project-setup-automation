#!/bin/bash

# DIRECTORIES
# test folder in base dir outside of module.
base_dir_tests=tests
base_dir=backend
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



step_1_create_dirs() {
    # create ~/backend/ project folders
    mkdir -p $deps \
            $config \
            $utils \
            $schemas \
            $routers \
            $db
}

# ~/BACKEND FILES
step_2_create_dir_files_v1() {
    # ~/backend/entry.py
    touch $base_dir/$entry
    #~/backend/settings.py
    touch $base_dir/$settings
    # ~/backend/...
    touch $deps/$init\
            $deps/$base_deps \
            $db/$init \
            $db/$base_db \
            $schemas/$init \
            $schemas/$base_schema \
            $config/$base_config \
            $config/$init \
            $utils/$init \
            $utils/$base_utils \
            $routers/$init \
            $routers/$base_router
}


# Dockerfile with uvicorn; this works on Digital Ocean
create_dockerfile_dgo() {
    # ~/Dockerfile at project root directory.
    touch $dockerfile
    printf \
"FROM python:3.9

WORKDIR /app

ADD requirements.txt .
RUN pip install --no-cache-dir --upgrade -r requirements.txt
# RUN pip install -vvv uvloop

ADD backend backend
ADD main.py .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]
" > $dockerfile
}



create_test_config() {
    # ~/tests
    mkdir $base_dir_tests
    touch $base_dir_tests/$init
    # ~/tests/conftest.py
    touch $base_dir_tests/$conftest

    touch $base_dir_tests/test_one.py $base_dir_tests/test_two.py
    # ~/setup.cfg
    touch $setup_cfg
    printf \
    "[coverage:run]
branch = True
# define paths to omit, comma separated
omit = */.virtualenvs/*,~/.virtualenvs,./backend/utils/*,./backend/config/*
[coverage:report]
show_missing = True
skip_covered = True
[coverage:html]
directory = tests/coverage_html_report
[tool:pytest]
addopts = 
    --cov backend/ 
    --cov-report html
    --verbose
    -p no:warnings
testpaths = 
    tests
filterwarnings = ignore::DeprecationWarning
    " > $setup_cfg
}





create_main_py() {
    # ~/main.py
    touch $main
    printf \
"from backend.entry import app

if __name__ == '__main__':
    app
    " > $main
}





create_startup_and_test_script() {
    # ~/startup.sh
    touch $startup
    printf \
"export SECRET='<hex hash>'
export MONGO_URI='<mongo uri>'
export WHICH_LOGGER=uvicorn
export ENV_NAME=development
export PORT=5000

uvicorn main:app --port $PORT --reload

run_tests() {
    py.test -s tests/test_one.py
    py.test -s tests/test_two.py
}
run_docker_local_test() {
    docker build -t fastapi_app:latest .
    docker run --name test-container -p 5000:5000 fastapi_app:latest
}
" > $startup
}



create_other_root_files() {
    # create root files
    touch $reqs $gitignore $dockerignore
}




main_init() {
step_1_create_dirs
step_2_create_dir_files_v1
create_main_py
create_test_config
create_startup_and_test_script
create_dockerfile_dgo
create_other_root_files
}


main_init
# rm -rf $base_dir $base_dir_tests && rm $reqs $main $startup $dockerfile $setup_cfg $gitignore $dockerignore
