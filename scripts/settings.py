INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'postorius',
    'hyperkitty',
]

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': '/var/lib/mailman-web/data/mailman-web.sqlite',
    }
}

SECRET_KEY = 'your-secret-key'
DEBUG = False
ALLOWED_HOSTS = ['example.com']
