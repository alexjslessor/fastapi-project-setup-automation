from functools import lru_cache
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
