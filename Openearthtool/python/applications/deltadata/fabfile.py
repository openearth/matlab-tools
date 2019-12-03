from fabric.api import run, env, local
env.hosts = ['fedor@dtvirt5']
env.app = 'deltadata'
env.code_root = '/var/lib/wsgi/{}'.format(env.app)
def test():
    """Run the tests"""
    local('bin/test')
def push():
    """Checkin code"""
    local('svn ci -m"checked in by fabric"')

def fetch():
    """Fetch tags"""

def checkout():
    """Checkout a specfic version."""

def backup():
    """Make a fresh backup."""

def stop_app():
    """Stop the application."""

def update_app():
    """Run buildout."""

def start_app():
    """Restart the application process"""

def reload_webserver():
    """Reload the webserver configuration if it's still okay."""

def deploy():
    """Full deploy of a new version."""
    test()
    push()
    fetch()
    backup()
    stop_app()
    checkout()
    update_app()
    start_app()
    reload_webserver()
