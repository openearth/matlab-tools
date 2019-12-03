import __builtin__, sys, imp

class Updater:

    def __init__(self):

        pass

    def start(self):
        mod = __builtin__.__import__('server')

        srv = mod.Server()
        srv._parent = self
        srv.start()

    def restart(self, root):

        for modname in sys.modules.keys():

            s = modname.split('.')

            try:
                file, pathname, description = imp.find_module(s[0])
            except:
                pathname = False

            if pathname and pathname.startswith(root):
                if sys.modules.has_key(modname):

                    try:
                        del(sys.modules[modname])
                    except:
                        pass

        self.start()

if __name__ == "__main__":
    Updater().start()