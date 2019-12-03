from pyramid.i18n import get_localizer, TranslationStringFactory

def add_renderer_globals(event):
    request = event['request']
    if request:
        event['_'] = request.translate
        event['localizer'] = request.localizer

tsf = TranslationStringFactory('sealevel')

def add_localizer(event):
    request = event.request
    localizer = get_localizer(request)
    def auto_translate(*args, **kwargs):
        return localizer.translate(tsf(*args, **kwargs))
    request.localizer = localizer
    request.translate = auto_translate
