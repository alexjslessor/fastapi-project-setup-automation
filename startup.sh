#!/bin/bash

init_env() {
    # grep -v '^#' .env/.env.local
    export $(grep -v '^#' .env/.env.local | xargs)
    env | grep ENV_NAME
}

# Start app with env vars
init_env
uvicorn main:app --reload --port $PORT

run_tests() {
    py.test -s tests/test_one.py
    py.test -s tests/test_two.py
}
run_docker_local_test() {
    docker build -t fastapi_app:latest .
    docker run --name test-container -p $PORT:$PORT fastapi_app:latest
}
