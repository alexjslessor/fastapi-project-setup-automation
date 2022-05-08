from functools import lru_cache
from pydantic import BaseSettings, AnyUrl
from os import environ
from typing import List, Callable
import os.path

class _BaseSettings(BaseSettings):
    TITLE: str = 'Example'
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
    MONGO_URI: AnyUrl = environ.get('MONGO_URI')
    MONGO_DB_NAME: str = 'database'

class DevSettings(_BaseSettings):
    ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
    DATA_DIR = os.path.join(ROOT_DIR, 'data')

class ProdSettings(_BaseSettings):
    pass

class TestSettings(_BaseSettings):
    pass


@lru_cache()
def get_settings() -> BaseSettings:
    config_dict = {
        'development': DevSettings,
        'production': ProdSettings,
        'testing': TestSettings
    }
    config_name: str = environ.get('ENV_NAME', 'development')
    assert config_name != None, f'Set ENV_NAME variable: {list(config_dict.keys())}'
    config_cls = config_dict[config_name]
    return config_cls()
