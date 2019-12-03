"""View handlers package.
"""

def includeme(config):
    """Add the application's view handlers.
    """
    config.add_handler("home", "/", "layar.handlers.main:Main",
                       action="index")
    config.add_handler("main", "/{action}", "layar.handlers.main:Main",
        path_info=r"/(?!favicon\.ico|robots\.txt|w3c)")
