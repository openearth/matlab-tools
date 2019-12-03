import ConfigParser

# Extend ConfigParser + return dictionary
class ConfigParser(ConfigParser.ConfigParser):
    def as_dict(self):
        d = dict(self._sections)
        for k in d:
            d[k] = dict(self._defaults, **d[k])
            d[k].pop('__name__', None)
        return d

# Wrapper
def config2dict(config_path):
    c=ConfigParser()
    c.read(config_path)
    return c.as_dict()
