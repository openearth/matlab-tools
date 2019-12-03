import logging

from pylons import request, response, session, tmpl_context as c, url
from pylons.controllers.util import abort, redirect

from openearthtest.lib.base import BaseController, render

log = logging.getLogger(__name__)

class MyController(BaseController):

    def map(self):
	return render('/my.mako')
