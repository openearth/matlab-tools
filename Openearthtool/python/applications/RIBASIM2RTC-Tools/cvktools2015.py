import os

bs = "\\"

def path2fol(path):
    pf = path.strip(bs)[:].rfind(bs)
    return path[:pf+1], path[pf+1:].strip(bs)

def setws(setpath = 0):    
    global bs
    """set workspace, a folder element is created. Use .path or .fp to get the right workspace path"""    
    if not setpath:
        setpath = os.getcwd()
    ws = path2fol(setpath)
    
    return ws

class folder():
    """ a folder class, returning folder name and path. If the full path doesn't exist, it is created.
    folder.listdir() returns the files in the folder"""
    global bs    
    
    def __init__(self, path = 0, printscrn = 0):
        if not path:
            path = os.getcwd()
        self.path, self.name = path2fol(path)
        self.fp = self.path + self.name + bs
        if not printscrn:
            self.pscrn = 0
        else: 
            self.pscrn = 1
        self.mkdir()
        
    def __str__(self):
        return self.fp
    
    def mkdir(self):
        if not os.path.exists(self.fp):
            os.makedirs(self.fp)
            if self.pscrn:
                print ("directory created", self.fp)
        else:
            if self.pscrn:
                print ("directory existed", self.fp)

    def listdir(self):
        return os.listdir(self.fp)
    