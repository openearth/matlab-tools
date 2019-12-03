This file is for you to describe the lol application. Typically
you would include information such as the information below:

Installation and Setup
======================

Install ``lol`` using easy_install::

    easy_install lol

Make a config file as follows::

    paster make-config lol config.ini

Tweak the config file as appropriate and then setup the application::

    paster setup-app config.ini

Then you are ready to go.

    paster serve --reload ./development.ini