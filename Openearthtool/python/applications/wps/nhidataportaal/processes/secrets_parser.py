import configparser
import logging

def pgconfig(fn, section='postgres'):
    config = configparser.ConfigParser()
    config.read(fn)
    secrets = {key: value for (key, value) in config.items(section)}
    logging.info(secrets)
    return secrets

# if __name__ == "__main__":
#    print pgconfig("dbconf.ini")
