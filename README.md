
![readme/1631651917229.jpg](readme/1631651917229.jpg)


This is a bash script for the creation of large FastAPI projects.


Depending on how you want to deploy your app, there are minor variations in how you may structure it.

There are two ways to initalize your application for deployment in docker.
1. Using the application factory pattern
2. Using Gunicorn.

Each method of Deployment will be in its own branch.

FastAPI is a flexible framework. There isn't any right/wrong setup. This is a general setup that I have using in production systems for quite sometime.

```
.
├── .gitignore
├── .dockerignore
├── startup.sh
├── requirements.txt
├── README.md
├── main.py
├── Dockerfile
├── setup.cfg
├── tests
│   ├── test_two.py
│   ├── test_one.py
│   ├── __init__.py
│   └── conftest.py
└── backend
    ├── entry.py
    ├── settings.py
    ├── utils
    │   ├── __init__.py
    │   └── base_utils.py
    ├── schemas
    │   ├── __init__.py
    │   └── base_schema.py
    ├── routers
    │   ├── __init__.py
    │   └── base_router.py
    ├── deps
    │   ├── __init__.py
    │   └── base_deps.py
    ├── db
    │   ├── __init__.py
    │   └── base_db.py
    └── config
        ├── __init__.py
        └── base_config.py
```



## __virtualenvwrapper__

```sh
source virtualenvwrapper.sh

# make new env
mkvirtualenv template-env

# wipe all non-default packages in env
wipeenv

# deactivate env
deactivate

# list all envs
lsvirtualenv

# delete env
rmvirtualenv env-name
```

<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>


# Unit Test Setup

Run Tests: `py.test -s`

```bash
├── setup.cfg 'Contains pytest settings.'
├── tests 'Pytest folder structured as a python package.'
│   ├── test_two.py 'Same as test_one.py.'
│   ├── test_one.py 'Each test file imports from .conftest.py.'
│   ├── __init__.py 'init file as our tests are structured as a python package.'
│   └── conftest.py 'Configuration for our tests pytest fixtures.'
└── backend
    ├── entry.py 'Imported by tests/conftest.py.' 
    ├── settings.py
    ├── utils
    ├── ...
```
## Overview

There are generally two types of code that we will be writing tests for.
1. Dependency callables.
2. Routes or our HTTP endpoints that will have dependancy callables injected into them.

__Dependancies are just regular Python functions__ that are "injected" into our routes via FastAPI's `Depends` class.


## conftest.py
The conftest.py file is the configuration file for out testing package.
All of our individual testing files, as denoted by the suffix `test_`, will import it in order to gain some common configuration.

---

## Test Driven Development
Test-driven development is a software development process relying on the following:
- Software requirements being converted to test cases before software is fully developed.
- tracking all software development by repeatedly testing the software against all test cases



<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>

# Setup .env and settings.py
```sh
.env/
|── .env.local 'Specifies env variables for local development.'
└── startup.sh 'Initializes local environment variables.'
```
Environment variables are variables that lives outside of the Python code, in the operating system, and can be read by your Python code (or by other programs as well).

__Benefits to the .env setup in this course.__
- Clear separation of local and production environment variables.
- We can quickly and easily set new vaiables in a single place in our code.



`settings.py File Requirements:`

Our app needs to be setup to use env vars. There are many ways to do this but this is my setup.


We DO:
- Want to have all env vars read from operating system. 
- Want to inject environment variables externally.

We DO NOT:
- Want `settings.py` to read from a local .env file.
- Want to hardcode env variables in our `settings.py` file.
- Want to commit sensitive credentials to source control.


`@lru_cache()`

- Modifies the function it decorates to return the same value that was returned the first time, instead of computing it again, executing the code of the function every time.

- In the case of our dependency get_settings(), the function doesn't even take any arguments, so it always returns the same value.


__Documentation Reference:__
- https://fastapi.tiangolo.com/advanced/settings/?h=envir
- https://pydantic-docs.helpmanual.io/usage/settings/
- https://docs.python.org/3/library/functools.html#functools.lru_cache



<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>


# Python requirements:

Python dependancies for environment.
```bash
pip freeze > requirements.txt
```


# Large Application Structure

https://fastapi.tiangolo.com/tutorial/bigger-applications/?h=applica

- ~/backend/entry.py
    - https://fastapi.tiangolo.com/tutorial/bigger-applications/?h=applica#import-fastapi



