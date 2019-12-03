import ConfigParser


def pgconfig(fn, section="postgres"):
    config = ConfigParser.ConfigParser()
    config.read(fn)
    secrets = {key: value for (key, value) in config.items(section)}
    return secrets

#if __name__ == "__main__":
#    print pgconfig("dbconf.ini")