import os
import glob
def inplace_change(filename, old_string, new_string):
    # Safely read the input filename using 'with'
    with open(filename) as f:
      s = f.read()
      if old_string not in s:
#          print '"{old_string}" not found in {filename}.'.format(**locals())
          return

    # Safely write the changed content, if found in the file
    with open(filename, 'w') as f:
#        print 'Changing "{old_string}" to "{new_string}" in {filename}'.format(**locals())
        s = s.replace(old_string, new_string)
        f.write(s)

def make_clean_file(rawFile,cleanFile):
    # Safely read the input filename using 'with'
    with open(rawFile) as f:
      s = f.read()

    waitlines = ''
    foundClassDef = False
    foundStaticMethods = False
    seekingFunction = True
    # Safely write the changed content, if found in the file
    with open(cleanFile, 'w') as f:
        for item in s.split("\n"):
            if not foundClassDef: #Before or after class definition
                if'classdef' in item:
                    foundClassDef = True 
                    f.write(item+'\n')
                    f.write(waitlines)
                else:
                     waitlines = waitlines + '\t' + item +'\n'
            else:
                if not foundStaticMethods:
#                     f.write(item+'\n')                   
                  
                     if 'methods (Static)' in item:
                         f.write(item+'\n')   
                         foundStaticMethods = True
                         
                else:
                    if seekingFunction:
                        if ("function" in item) and not (
                        ("'function'" in item)  or
                        (".function" in item) or 
                        ('%' in item) or 
                        ('error(' in item)
                        ):
                            # This line is the fucntion definition. Remove the semicolon at the end if it exists
                            if item[-1] == ';':
                                item=item[0:-1]
                            f.write(item+'\n')
                            seekingFunction = False
                    else:
                        if '%' in item:
                            f.write(item+'\n')   
                        else: 
                            f.write('        end\n\n')
                            seekingFunction = True
        f.write('    end\nend\n')
                        
                            
 
                
def make_rest_file(matPath,docuPath,dirname,filesToExclude):
    print('Making ' + os.path.join(docuPath,dirname+'_auto.rst'))
    with open(os.path.join(docuPath,dirname+'_auto.rst'),'w') as f:
        f.write(dirname + '\n=========\n')
        f.write('.. automodule:: '+dirname+'\n')
        
        for filename in os.listdir(os.path.join(matPath,dirname)):
            if not filename in filesToExclude:
                f.write(filename + '\n---------\n')
                f.write('.. autoclass:: '+os.path.splitext(filename)[0]+'\n')
                f.write('    :members:\n')

        f.write('Indices and tables\n')
        f.write('---------\n')
        f.write('* :ref:`genindex`\n')
        f.write('* :ref:`modindex`\n')
        f.write('* :ref:`search`\n')



def mainCleanup(matPath,docuPath):
 

  
  foldersToExclude = [
      'External',
      'Web',
      'Test',
      
  ]
  filesToExclude = [
      'testModel.m',
      'ImproveGrid.m',
      'MeshSizeTools.m',
      'interpModeldata.m',
      'testInterpDataSubset.m',
      'digitizeFig.m'
      'getCoordinates.m'
  ]
  fullPathsToExclude = []
  for fol in foldersToExclude:
      fullPathsToExclude.append(os.path.join(matPath,fol))
      

  #Create directories and rest files  
  dirs = list(set(os.path.dirname(mFile) for  mFile in glob.glob(os.path.join(matPath,'*\*.m'))))
  for dirname in dirs:
      if not os.path.split(dirname)[1] in foldersToExclude:
          newDirname = dirname.replace(matPath,docuPath)
          
          make_rest_file(matPath,docuPath,os.path.split(dirname)[1],filesToExclude)
    
    #      print(newDirname)
          if not os.path.exists(newDirname):
              os.makedirs(newDirname)
              


  for oldFile in glob.glob(os.path.join(matPath,'*\*.m')):
      if not ((os.path.split(oldFile)[0] in fullPathsToExclude) or 
          (os.path.split(oldFile)[1] in filesToExclude)):


          cleanFile =  oldFile.replace(matPath,docuPath)
    
          make_clean_file(oldFile,cleanFile)
          inplace_change(cleanFile,"methods (Access = 'private')","methods (Access = private)")
          
          
if __name__ == "__main__":
  matPath = 'C:\Users\THL\Documents\MATLAB\matlabSystemNew'
  docuPath = 'K:\EXCHANGE\THL\sphinx_docu\IMDCMatlabSphinxDocu'
  mainCleanup(matPath,docuPath) 
#     print    os.path.dirname(mFile)
#      print    os.path.basename(mFile)
#      print    mFile.replace(matPath,docuPath)
      
  
#  print os.path.dirname(pathname)
#      print os.path.basename(pathname)
#  for root, dirs, files in os.walk(matPath):
#      for dirname in dirs:
#          if (not 'External' in dirname) and (not 'Input_Output' in dirname):
#              if any(filename.endswith(".m") for filename in os.listdir(os.path.join(root,dirname))):
#                  make_rest_file(matPath,docuPath,dirname)
#                  if not os.path.exists(os.path.join(docuPath,dirname)):
#                      os.makedirs(os.path.join(docuPath,dirname))
#                  for filename in os.listdir(os.path.join(root,dirname)):
#                      if filename.endswith(".m"):
#                        print(filename)
#                        make_clean_file(os.path.join(matPath,dirname,filename),os.path.join(docuPath,dirname,filename))
#                        inplace_change(os.path.join(docuPath,dirname,filename),"methods (Access = 'private')","methods (Access = private)")

