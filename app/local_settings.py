import os

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'twitterpy',
        'USER': 'twitterpy',
        'PASSWORD': 'twitterpy',
        'HOST': 'db',
        'PORT': 5432,
    }
}

DJANGO_PATH = "/usr/src/twitterpy"
