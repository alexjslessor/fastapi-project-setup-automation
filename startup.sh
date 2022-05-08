export SECRET='<hex hash>'
export MONGO_URI='<mongo uri>'
export WHICH_LOGGER=uvicorn
export ENV_NAME=development
export PORT=5000

uvicorn main:app --port  --reload

run_tests() {
    py.test -s tests/test_one.py
    py.test -s tests/test_two.py
}
run_docker_local_test() {
    docker build -t fastapi_app:latest .
    docker run --name test-container -p 5000:5000 fastapi_app:latest
}
