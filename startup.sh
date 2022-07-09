#!/bin/bash

base_settings() {
    # grep -v '^#' .env/.env.local
    export $(grep -v '^#' .env/.env.local | xargs)
    env | grep ENV_NAME
}
run_tests() {
    base_settings
    export $(grep -v '^#' .env/.env.testing | xargs)
    env | grep ENV_NAME

    py.test -s tests/test_deps.py
    py.test -s tests/test_routes.py
}
run_app_local_test() {
    docker build -t fastapi_app:latest .
    docker run --name test-container -p $PORT:$PORT fastapi_app:latest
}
run_mongodb_local() {
    docker run -d --name mongodb-docker -p 27017:27017 mongo:4.4
}
# Start app with env vars

base_settings
run_tests
#run_mongodb_local
uvicorn main:app --reload --port $PORT
