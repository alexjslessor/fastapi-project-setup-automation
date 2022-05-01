
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

