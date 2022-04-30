#!/bin/bash

# DIRECTORIES
base_dir=backend
deps=$base_dir/deps
config=$base_dir/config
utils=$base_dir/utils
schemas=$base_dir/schemas
routers=$base_dir/routers
db=$base_dir/db
# FILES
init=__init__.py
base_deps=base_deps.py
base_config=base_config.py
base_router=base_router.py
base_utils=base_utils.py
base_db=base_db.py
base_schema=base_schema.py
# ROOT FILES
test_conf=setup.cfg

step_1_create_dirs() {
    # create ~/backend/ project folders
    mkdir -p $deps $config $utils $schemas $routers $db
}
step_2_create_dir_files_v1() {
    # create backend files 
    touch $base_dir/entry.py

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


create_dockerfile_dgo() {
    touch Dockerfile

    printf \
    "FROM python:3.9

WORKDIR /app

ADD requirements.txt .
RUN pip install --no-cache-dir --upgrade -r requirements.txt
# RUN pip install -vvv uvloop

ADD backend backend
ADD main.py .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]
" > Dockerfile
}

create_test_config() {
    mkdir tests
    touch tests/conftest.py
    touch $test_conf

    printf \
    "[coverage:run]
branch = True
# define paths to omit, comma separated
omit = */.virtualenvs/*,~/.virtualenvs,./backend/api/*,./backend/utils/*,./backend/config/*
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
    " > $test_conf
}

create_root_files() {
    # create root files
    touch main.py startup.sh .gitignore .dockerignore
}

# step_1_create_dirs
# step_2_create_dir_files_v1
# create_test_config
# create_dockerfile_dgo
# create_root_files
# rm -rf $base_dir tests && rm main.py startup.sh setup.cfg Dockerfile .gitignore .dockerignore